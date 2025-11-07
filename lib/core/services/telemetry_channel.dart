import 'dart:async';
import '../models/app_event.dart';
import '../models/agent_intent.dart';
import '../models/agent_session.dart';
import '../models/discipline_contract.dart';

/// Central event bus for agent telemetry and domain events
class TelemetryChannel {
  static final TelemetryChannel _instance = TelemetryChannel._internal();
  factory TelemetryChannel() => _instance;
  TelemetryChannel._internal();

  final _controller = StreamController<AppEvent>.broadcast();
  Stream<AppEvent> get stream => _controller.stream;

  /// Emit an event
  void emit(AppEvent event) {
    _controller.add(event);
  }

  /// Convenience methods
  void intentSuggested(AgentIntent intent) {
    emit(IntentSuggested(intent));
  }

  void intentAccepted(AgentIntent intent) {
    emit(IntentAccepted(intent));
  }

  void intentDismissed(String intentId) {
    emit(IntentDismissed(intentId));
  }

  void sessionStarted(AgentSession session) {
    emit(SessionStarted(session));
  }

  void sessionUpdated(AgentSession session) {
    emit(SessionUpdated(session));
  }

  void sessionEnded(String sessionId, {required bool completed}) {
    emit(SessionEnded(sessionId, completed: completed));
  }

  void contractSigned(DisciplineContract contract) {
    emit(ContractSigned(contract));
  }

  void contractViolated(String contractId) {
    emit(ContractViolated(contractId));
  }

  void metricChanged(String key, dynamic value) {
    emit(MetricChanged(key, value));
  }

  void dispose() {
    _controller.close();
  }
}

