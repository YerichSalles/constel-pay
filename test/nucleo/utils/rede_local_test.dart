import 'package:constel_pay/nucleo/utils/rede_local.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('hostRedeLocal aceita loopback e faixas privadas', () {
    expect(hostRedeLocal('localhost'), isTrue);
    expect(hostRedeLocal('LOCALHOST'), isTrue);
    expect(hostRedeLocal('127.0.0.1'), isTrue);
    expect(hostRedeLocal('::1'), isTrue);
    expect(hostRedeLocal('[::1]'), isTrue);
    expect(hostRedeLocal('10.0.0.5'), isTrue);
    expect(hostRedeLocal('192.168.1.100'), isTrue);
    expect(hostRedeLocal('172.16.0.1'), isTrue);
    expect(hostRedeLocal('172.31.255.254'), isTrue);
    expect(hostRedeLocal('169.254.10.10'), isTrue);
    expect(hostRedeLocal('fe80::1'), isTrue);
    expect(hostRedeLocal('fd12:3456::1'), isTrue);
  });

  test('hostRedeLocal rejeita hosts públicos', () {
    expect(hostRedeLocal('constel.cloud'), isFalse);
    expect(hostRedeLocal('8.8.8.8'), isFalse);
    expect(hostRedeLocal('172.15.0.1'), isFalse);
    expect(hostRedeLocal('172.32.0.1'), isFalse);
    expect(hostRedeLocal('192.169.0.1'), isFalse);
    expect(hostRedeLocal('2001:4860:4860::8888'), isFalse);
    expect(hostRedeLocal(''), isFalse);
    expect(hostRedeLocal('999.168.1.1'), isFalse);
  });
}
