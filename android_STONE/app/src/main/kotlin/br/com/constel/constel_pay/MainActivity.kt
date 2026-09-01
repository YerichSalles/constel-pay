package br.com.constel.constel_pay

import android.content.Intent
import android.os.Bundle
import br.com.constel.constel_pay.nfc.PonteNfcStone
import br.com.constel.constel_pay.pagamento.PontePagamentoStone
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Build da adquirente STONE.
 *
 * A Activity so registra o canal e repassa os eventos de ciclo de vida: toda a
 * logica de cobranca fica em [PontePagamentoStone]. O nome do canal e o MESMO
 * de qualquer outra build — o lado Dart nunca deduz a adquirente por ele.
 */
class MainActivity : FlutterActivity() {

    private val ponte by lazy { PontePagamentoStone(this) }
    private val ponteNfc by lazy { PonteNfcStone(this) }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        ponte.iniciarSdk()
        // O app pode ter sido reaberto ja com a resposta do pagamento.
        ponte.tratarRespostaDeepLink(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CANAL)
            .setMethodCallHandler { chamada, resposta ->
                when (chamada.method) {
                    "iniciarPagamento" -> ponte.iniciarPagamento(chamada, resposta)
                    else -> resposta.notImplemented()
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CANAL_NFC)
            .setMethodCallHandler { chamada, resposta ->
                when (chamada.method) {
                    "lerNfc" -> ponteNfc.ler(resposta)
                    "cancelarNfc" -> ponteNfc.cancelar(resposta)
                    else -> resposta.notImplemented()
                }
            }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        ponte.tratarRespostaDeepLink(intent)
    }

    override fun onDestroy() {
        // Uma cobranca ou leitura pendente sem resposta nao pode morrer em
        // silencio: o Dart precisa saber que o desfecho ficou INDETERMINADO.
        ponte.encerrar()
        ponteNfc.encerrar()
        super.onDestroy()
    }

    private companion object {
        const val CANAL = "com.constelpay.pagamento"
        const val CANAL_NFC = "com.constelpay.nfc"
    }
}