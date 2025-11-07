import 'agent_intent.dart';
import 'agent_session.dart';
import 'discipline_contract.dart';

/// Domain events for agent telemetry and state updates
abstract class AppEvent {
  final DateTime timestamp;
  AppEvent({DateTime? timestamp}) : timestamp = timestamp ?? DateTime.now();
}

class IntentSuggested extends AppEvent {
  final AgentIntent intent;
  IntentSuggested(this.intent, {super.timestamp});
}

class IntentAccepted extends AppEvent {
  final AgentIntent intent;
  IntentAccepted(this.intent, {super.timestamp});
}

class IntentDismissed extends AppEvent {
  final String intentId;
  IntentDismissed(this.intentId, {super.timestamp});
}

class SessionStarted extends AppEvent {
  final AgentSession session;
  SessionStarted(this.session, {super.timestamp});
}

class SessionUpdated extends AppEvent {
  final AgentSession session;
  SessionUpdated(this.session, {super.timestamp});
}

class SessionEnded extends AppEvent {
  final String sessionId;
  final bool completed;
  SessionEnded(this.sessionId, {required this.completed, super.timestamp});
}

class ContractSigned extends AppEvent {
  final DisciplineContract contract;
  ContractSigned(this.contract, {super.timestamp});
}

class ContractViolated extends AppEvent {
  final String contractId;
  ContractViolated(this.contractId, {super.timestamp});
}

class MetricChanged extends AppEvent {
  final String metricKey;
  final dynamic value;
  MetricChanged(this.metricKey, this.value, {super.timestamp});
}

