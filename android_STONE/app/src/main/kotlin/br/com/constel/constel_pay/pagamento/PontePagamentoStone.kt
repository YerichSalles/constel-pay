package br.com.constel.constel_pay.pagamento

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import stone.application.StoneStart
import stone.utils.Stone

/**
 * Cobranca no terminal pela Stone.
 *
 * A cobranca NAO usa o `TransactionProvider` do SDK: usa o deep link do
 * aplicativo de pagamento da Stone (`payment-app://pay`), no MESMO protocolo
 * validado no app irmao `autoatendimento` (`Stone/Payment.java#onPayment` e
 * `#handleDeepLinkResponse`). O app abre o aplicativo de pagamento, o cliente
 * conclui na maquininha, e a resposta volta como um novo Intent no esquema
 * declarado em `return_scheme`.
 *
 * Contrato confirmado no app irmao (NAO inventar parametros além destes):
 * - Envio: `return_scheme`, `amount`, `editable_amount`, `transaction_type`,
 *   `installment_type` (fora do débito), `installment_count` (se >1 parcela).
 *   NÃO enviar `order_id` — está deliberadamente comentado no código-fonte
 *   original; incluí-lo aqui antes fez a Stone recusar a transação com "id
 *   inválido" antes mesmo de abrir a tela de cobrança.
 * - Retorno: só `code`, `brand`, `authorization_code`, `atk`. Não existe
 *   `card_last_digits` nem motivo de recusa (`reason`/`message`) — a Stone não
 *   devolve isso por este mecanismo.
 *
 * Nao existe codigo de ativacao aqui: quem e credenciado na Stone e o
 * aplicativo de pagamento instalado no aparelho, fora do Constel Pay (o app
 * irmao lê `codAtivacao` do canal mas nunca o usa na chamada Stone). O SDK e
 * iniciado apenas para os recursos de maquininha (impressao, proximo passo).
 *
 * Como a resposta chega em outro Intent, o [MethodChannel.Result] precisa
 * sobreviver entre chamadas. Ele fica aqui, em campo de instancia, respondido
 * EXATAMENTE UMA VEZ. Diferente do app legado (que guardava isso num campo
 * estatico sobrescrito a cada chamada — resolvia o Result errado sob
 * concorrência), aqui é por instância e com timeout: se a Stone rejeitar a
 * transação ANTES de abrir a tela de cobrança (ex.: parâmetro inválido), ela
 * pode nunca disparar o retorno — sem o timeout abaixo, a trava ficava presa
 * até a Activity ser destruída, e toda tentativa seguinte falhava com
 * "terminal em andamento".
 */
class PontePagamentoStone(private val activity: Activity) {

    private var pendente: MethodChannel.Result? = null
    private var metodoPendente: Int = 0
    private var chamadaAtual = 0
    private val handler = Handler(Looper.getMainLooper())
    private var tarefaTimeout: Runnable? = null

    /** Prepara o SDK. Necessario para os recursos de maquininha (impressao). */
    fun iniciarSdk() {
        StoneStart.init(activity.applicationContext)
        Stone.setAppName(NOME_APP)
    }

    fun iniciarPagamento(chamada: MethodCall, resposta: MethodChannel.Result) {
        // Uma cobranca por vez. Aceitar a segunda deixaria o cliente diante de
        // duas telas de pagamento para a mesma comanda.
        if (pendente != null) {
            resposta.error(
                "EM_ANDAMENTO",
                "Ja existe um pagamento em andamento neste terminal.",
                null,
            )
            return
        }

        val chaveIdempotencia = chamada.argument<String>("chaveIdempotencia").orEmpty()
        val valorCentavos = chamada.argument<Int>("valorCentavos") ?: 0
        val tipoTransacao = chamada.argument<Int>("tipoTransacao") ?: 0
        val parcelas = chamada.argument<Int>("parcelas") ?: 1

        val tipo = TIPOS[tipoTransacao]
        if (tipo == null || valorCentavos <= 0 || chaveIdempotencia.isEmpty()) {
            resposta.error(
                "TERMINAL_INDISPONIVEL",
                "Dados invalidos para a cobranca no terminal.",
                null,
            )
            return
        }

        pendente = resposta
        metodoPendente = tipoTransacao
        chamadaAtual++
        agendarTimeout(chamadaAtual)
        try {
            activity.startActivity(montarIntent(valorCentavos, tipo, parcelas))
        } catch (erro: ActivityNotFoundException) {
            // Aplicativo de pagamento da Stone ausente: nada foi cobrado.
            responder { it.error("TERMINAL_INDISPONIVEL", MENSAGEM_SEM_APP, null) }
        }
    }

    /**
     * Sem isto, uma transação recusada pela Stone ANTES de abrir a tela de
     * cobrança (parâmetro inválido, app não credenciado etc.) nunca dispara o
     * deep link de retorno, e a ponte ficaria travada indefinidamente. Fica um
     * pouco abaixo do timeout do lado Dart (`tempoLimitePagamentoNativo`) para
     * que seja o nativo — que sabe o motivo real — a responder primeiro.
     */
    private fun agendarTimeout(minhaChamada: Int) {
        tarefaTimeout?.let { handler.removeCallbacks(it) }
        val tarefa = Runnable {
            if (chamadaAtual == minhaChamada) {
                responder { it.error("INDETERMINADO", MENSAGEM_INDETERMINADO, null) }
            }
        }
        tarefaTimeout = tarefa
        handler.postDelayed(tarefa, TIMEOUT_MS)
    }

    /**
     * Resposta do aplicativo da Stone. `code == "0"` e a unica confirmacao de
     * aprovacao; qualquer outro codigo e desfecho negativo, nunca sucesso.
     * A Stone não devolve motivo de recusa por este mecanismo — não inventar
     * um.
     */
    fun tratarRespostaDeepLink(intent: Intent?) {
        val uri = intent?.data ?: return
        if (uri.host != "pay-response") return
        if (pendente == null) return

        val codigo = uri.getQueryParameter("code").orEmpty()
        if (codigo != CODIGO_APROVADO) {
            responder {
                it.success(mapOf("status" to "recusado", "adquirente" to ADQUIRENTE))
            }
            return
        }

        val bandeira = uri.getQueryParameter("brand").orEmpty()
        val autorizacao = uri.getQueryParameter("authorization_code").orEmpty()
        // `atk`: identificador da transacao devolvido pela Stone. Sem uso
        // definido no payload da fatura ainda — capturado so para diagnostico.
        val atk = uri.getQueryParameter("atk").orEmpty()
        responder {
            it.success(
                mapOf(
                    "status" to "aprovado",
                    // PIX volta sem bandeira; cartao traz a bandeira do emissor.
                    "bandeira" to bandeira.ifEmpty { if (metodoPendente == PIX) "PIX" else "" },
                    "codigoAutorizacao" to autorizacao,
                    "nsu" to autorizacao,
                    "adquirente" to ADQUIRENTE,
                    "tokenTransacao" to atk,
                ),
            )
        }
    }

    /**
     * Activity destruida com cobranca pendente: o desfecho e desconhecido, e
     * tratar como recusa poderia levar a uma segunda cobranca.
     */
    fun encerrar() {
        if (pendente == null) return
        responder { it.error("INDETERMINADO", MENSAGEM_INDETERMINADO, null) }
    }

    /**
     * Envio confirmado no app irmão (`Payment.java#onPayment`). NÃO enviar
     * `order_id`: está comentado no código-fonte original e a Stone rejeita a
     * transação quando ele está presente.
     */
    private fun montarIntent(valorCentavos: Int, tipo: String, parcelas: Int): Intent {
        val uri = Uri.Builder()
            .scheme("payment-app")
            .authority("pay")
            .appendQueryParameter("return_scheme", ESQUEMA_RETORNO)
            .appendQueryParameter("amount", valorCentavos.toString())
            // O valor vem do consumo lido: o cliente nao edita.
            .appendQueryParameter("editable_amount", "0")
            .appendQueryParameter("transaction_type", tipo)
            .apply {
                if (tipo != DEBITO) {
                    appendQueryParameter(
                        "installment_type",
                        if (parcelas > 1) "MERCHANT" else "NONE",
                    )
                }
                if (parcelas > 1) {
                    appendQueryParameter("installment_count", parcelas.toString())
                }
            }
            .build()

        return Intent(Intent.ACTION_VIEW, uri)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    }

    /** Responde uma unica vez e libera a trava da cobranca. */
    private fun responder(acao: (MethodChannel.Result) -> Unit) {
        val resultado = pendente ?: return
        pendente = null
        tarefaTimeout?.let { handler.removeCallbacks(it) }
        tarefaTimeout = null
        acao(resultado)
    }

    private companion object {
        const val NOME_APP = "Constel Pay"
        const val ESQUEMA_RETORNO = "constel_pay_pagamento"
        const val ADQUIRENTE = "Stone"
        const val CODIGO_APROVADO = "0"
        const val DEBITO = "DEBIT"
        const val PIX = 230
        const val TIMEOUT_MS = 150_000L // 2m30s — abaixo do timeout do Dart (3min)

        /** Os mesmos codigos usados como especie da forma no retaguarda. */
        val TIPOS = mapOf(
            110 to "CREDIT",
            120 to DEBITO,
            PIX to "PIX",
        )

        const val MENSAGEM_SEM_APP =
            "O aplicativo de pagamento da Stone nao esta instalado neste terminal."
        const val MENSAGEM_INDETERMINADO =
            "Não foi possível confirmar o pagamento no terminal. Verifique a maquininha antes de tentar novamente."
    }
}