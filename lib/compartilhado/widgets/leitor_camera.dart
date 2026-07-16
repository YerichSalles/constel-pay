import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Lê códigos de barras pela câmera, para totens Android sem leitor de
/// hardware. É a mesma entrada do leitor keyboard wedge: entrega o código lido
/// e quem chama decide o que fazer.
///
/// A câmera só é aberta enquanto [ativo]. Fora disso o widget mostra o
/// [reserva] e a câmera fica parada — deixá-la ligada o atendimento inteiro
/// seria desperdício de bateria, aquecimento e exposição desnecessária.
class LeitorCamera extends StatefulWidget {
  const LeitorCamera({
    super.key,
    required this.aoLer,
    required this.reserva,
    this.ativo = true,
    this.altura = 176,
  });

  /// Chamado com o código lido.
  final ValueChanged<String> aoLer;

  /// Exibido quando a câmera está parada ou indisponível.
  final Widget reserva;

  final bool ativo;
  final double altura;

  @override
  State<LeitorCamera> createState() => _LeitorCameraState();
}

class _LeitorCameraState extends State<LeitorCamera> {
  /// `noDuplicates` evita que a mesma comanda seja consultada dezenas de vezes
  /// enquanto o cliente segura o código na frente da câmera. Só os formatos
  /// usados em comanda são procurados, para o reconhecimento não gastar tempo
  /// com QR e afins.
  late final MobileScannerController _controlador = MobileScannerController(
    autoStart: false,
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.itf,
    ],
  );
  bool _iniciado = false;

  @override
  void initState() {
    super.initState();
    if (widget.ativo) _ligar();
  }

  @override
  void didUpdateWidget(LeitorCamera anterior) {
    super.didUpdateWidget(anterior);
    if (widget.ativo == anterior.ativo) return;
    widget.ativo ? _ligar() : _desligar();
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  /// Falhas ao ligar/desligar (permissão negada, câmera ocupada) não podem
  /// derrubar a tela: o `errorBuilder` já mostra o aviso ao operador.
  Future<void> _ligar() async {
    try {
      await _controlador.start();
      if (mounted) setState(() => _iniciado = true);
    } catch (_) {
      if (mounted) setState(() => _iniciado = false);
    }
  }

  Future<void> _desligar() async {
    try {
      await _controlador.stop();
    } catch (_) {
      // Já estava parada.
    }
    if (mounted) setState(() => _iniciado = false);
  }

  void _aoDetectar(BarcodeCapture captura) {
    if (!widget.ativo) return;
    for (final codigo in captura.barcodes) {
      final valor = codigo.rawValue?.trim() ?? '';
      if (valor.isNotEmpty) {
        widget.aoLer(valor);
        return;
      }
    }
  }

  Widget _aviso(String mensagem) {
    return ColoredBox(
      color: const Color(0xFF12141A),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            mensagem,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: .82),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: widget.altura,
        width: double.infinity,
        child: !_iniciado
            ? widget.reserva
            : MobileScanner(
                controller: _controlador,
                onDetect: _aoDetectar,
                fit: BoxFit.cover,
                placeholderBuilder: (_, __) => widget.reserva,
                errorBuilder: (_, erro, __) => _aviso(
                  erro.errorCode == MobileScannerErrorCode.permissionDenied
                      ? 'Sem permissão de câmera. Libere o acesso nas '
                          'configurações do Android.'
                      : 'Câmera indisponível.',
                ),
              ),
      ),
    );
  }
}
