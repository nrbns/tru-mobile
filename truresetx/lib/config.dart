// Simple runtime config for local endpoints. Values can be overridden with
// --dart-define when running Flutter, for example:
// flutter run --dart-define=RAG_ENDPOINT=https://... --dart-define=SOCKET_URL=http://10.0.2.2:3000

class Config {
  static const String ragEndpoint = String.fromEnvironment('RAG_ENDPOINT',
      defaultValue: 'http://127.0.0.1:54321/query_rag');
  static const String socketUrl = String.fromEnvironment('SOCKET_URL',
      defaultValue: 'http://10.0.2.2:3000');
}
