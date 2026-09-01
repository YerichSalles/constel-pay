package br.com.constel.constel_pay.nfc

import android.app.Activity
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.MethodChannel
import stone.application.interfaces.StoneCallbackInterface
import br.com.stone.posandroid.providers.PosMifareProvider

/**
 * Leitura do codigo de atendimento pela antena NFC da maquininha Stone.
 *
 * Base funcional confirmada no app irmao `autoatendimento`
 * (`Stone/Payment.java#LerMifare/CancelarMifare`): `PosMifareProvider(context)`
 * -> `setConnectionCallback` -> `execute()`; sucesso ativa o cartao e le o
 * UUID (`activateCard()` + `getCardUUID()`); encerramento sempre cancela e
 * desliga a antena (`cancel(true)` + `powerOff()`).
 *
 * Corrigido aqui em relacao ao legado (que tinha os mesmos problemas do
 * pagamento por deep link, ja resolvidos em `PontePagamentoStone`):
 * - [MethodChannel.Result] por INSTANCIA, guardado ANTES de chamar o
 *   provider, respondido EXATAMENTE UMA VEZ — nunca um campo estatico
 *   resolvido depois da chamada errada.
 * - Sem `throw` depois de já ter respondido.
 * - Erros voltam por `result.error(codigo, ...)` com codigos fixos
 *   (`SEM_LEITOR`, `TEMPO_ESGOTADO`, `CANCELADO`, `ERRO_LEITURA`) — nunca por
 *   comparacao de string de mensagem.
 * - `powerOff()` garantido em TODOS os caminhos: sucesso, erro, timeout,
 *   cancelamento e `onDestroy` da Activity.
 */
class PonteNfcStone(private val activity: Activity) {

    private var pendente: MethodChannel.Result? = null
    private var provider: PosMifareProvider? = null
    private var chamadaAtual = 0
    private val handler = Handler(Looper.getMainLooper())
    private var tarefaTimeout: Runnable? = null

    fun ler(resposta: MethodChannel.Result) {
        // Uma leitura por vez: aceitar a segunda deixaria dois callbacks
        // competindo pela mesma antena.
        if (pendente != null) {
            resposta.error(
                "EM_ANDAMENTO",
                "Ja existe uma leitura por NFC em andamento.",
                null,
            )
            return
        }
        pendente = resposta
        chamadaAtual++
        agendarTimeout(chamadaAtual)
        try {
            iniciarLeitura()
        } catch (erro: Exception) {
            encerrarProvider()
            responder { it.error("SEM_LEITOR", MENSAGEM_SEM_LEITOR, null) }
        }
    }

    fun cancelar(resposta: MethodChannel.Result) {
        encerrarProvider()
        responder { it.error("CANCELADO", "Leitura por NFC cancelada.", null) }
        resposta.success(null)
    }

    /** Activity destruida com leitura pendente: desliga a antena sempre. */
    fun encerrar() {
        encerrarProvider()
        responder { it.error("CANCELADO", "Leitura por NFC cancelada.", null) }
    }

    private fun iniciarLeitura() {
        val novoProvider = PosMifareProvider(activity)
        provider = novoProvider
        novoProvider.setConnectionCallback(object : StoneCallbackInterface {
            override fun onSuccess() {
                try {
                    novoProvider.activateCard()
                    val identificador = bytesToHex(novoProvider.cardUUID)
                    encerrarProvider()
                    responder { it.success(mapOf("identificador" to identificador)) }
                } catch (erro: Exception) {
                    encerrarProvider()
                    responder { it.error("ERRO_LEITURA", MENSAGEM_ERRO_LEITURA, null) }
                }
            }

            override fun onError() {
                encerrarProvider()
                responder { it.error("ERRO_LEITURA", MENSAGEM_ERRO_LEITURA, null) }
            }
        })
        novoProvider.execute()
    }

    /**
     * Sem isto, uma leitura sem sucesso nem erro nunca dispara callback e a
     * ponte fica travada indefinidamente — mesmo raciocínio do timeout do
     * pagamento por deep link.
     */
    private fun agendarTimeout(minhaChamada: Int) {
        tarefaTimeout?.let { handler.removeCallbacks(it) }
        val tarefa = Runnable {
            if (chamadaAtual == minhaChamada) {
                encerrarProvider()
                responder { it.error("TEMPO_ESGOTADO", MENSAGEM_TEMPO_ESGOTADO, null) }
            }
        }
        tarefaTimeout = tarefa
        handler.postDelayed(tarefa, TIMEOUT_MS)
    }

    /** Cancela e desliga a antena — chamado em TODO caminho de saída. */
    private fun encerrarProvider() {
        provider?.let {
            it.cancel(true)
            it.powerOff()
        }
        provider = null
    }

    /** Responde uma única vez e libera a trava da leitura. */
    private fun responder(acao: (MethodChannel.Result) -> Unit) {
        val resultado = pendente ?: return
        pendente = null
        tarefaTimeout?.let { handler.removeCallbacks(it) }
        tarefaTimeout = null
        acao(resultado)
    }

    private fun bytesToHex(bytes: ByteArray): String =
        bytes.joinToString("") { "%02X".format(it) }

    private companion object {
        const val TIMEOUT_MS = 90_000L

        const val MENSAGEM_SEM_LEITOR =
            "Este terminal nao tem leitor NFC disponivel."
        const val MENSAGEM_ERRO_LEITURA =
            "Nao foi possivel ler o cartao. Aproxime novamente."
        const val MENSAGEM_TEMPO_ESGOTADO =
            "Tempo esgotado aguardando o cartao."
    }
}
