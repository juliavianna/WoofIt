import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class StompService {
  StompClient? _client;

  void conectar({
    required String url,
    required List<String> filas,
    required void Function(String fila, Map<String, dynamic> payload) onEvento,
  }) {
    _client = StompClient(
      config: StompConfig(
        url: url,
        login: 'guest',
        passcode: 'guest',
        onConnect: (frame) {
          for (final fila in filas) {
            _client!.subscribe(
              destination: '/queue/$fila',
              callback: (frame) {
                if (frame.body != null) {
                  onEvento(fila, jsonDecode(frame.body!));
                }
              },
            );
          }
        },
        onDisconnect: (_) => print('[STOMP] Desconectado'),
        onStompError: (f) => print('[STOMP] Erro: ${f.body}'),
        onWebSocketError: (e) => print('[STOMP] WebSocket erro: $e'),
      ),
    );
    _client!.activate();
  }

  void desconectar() {
    _client?.deactivate();
  }
}