/// One row of the audit trail every state-changing admin action writes to:
/// actor, timestamp, and what happened (before/after state is carried in
/// [note] for this mock implementation rather than a structured diff).
class AuditLogEntry {
  AuditLogEntry({
    required this.action,
    required this.actor,
    this.targetLabel = '',
    this.note,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  final String action;
  final String actor;
  final String targetLabel;
  final String? note;
  final DateTime timestamp;
}
