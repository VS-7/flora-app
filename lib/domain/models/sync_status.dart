enum SyncState {
  synced, // Sincronizado com o servidor
  pending, // Pendente de sincronização
  conflict, // Conflito entre versão local e remota
}

class SyncStatus {
  final String entityId;
  final String entityType;
  final SyncState state;
  final DateTime lastSyncTime;
  final DateTime lastLocalUpdate;
  final int version;

  SyncStatus({
    required this.entityId,
    required this.entityType,
    required this.state,
    required this.lastSyncTime,
    required this.lastLocalUpdate,
    required this.version,
  });

  Map<String, dynamic> toMap() {
    return {
      'entity_id': entityId,
      'entity_type': entityType,
      'state': state.name,
      'last_sync_time': lastSyncTime.toIso8601String(),
      'last_local_update': lastLocalUpdate.toIso8601String(),
      'version': version,
    };
  }

  factory SyncStatus.fromMap(Map<String, dynamic> map) {
    return SyncStatus(
      entityId: map['entity_id'],
      entityType: map['entity_type'],
      state: SyncState.values.firstWhere(
        (e) => e.name == map['state'],
        orElse: () => SyncState.pending,
      ),
      lastSyncTime: DateTime.parse(map['last_sync_time']),
      lastLocalUpdate: DateTime.parse(map['last_local_update']),
      version: map['version'],
    );
  }

  SyncStatus copyWith({
    String? entityId,
    String? entityType,
    SyncState? state,
    DateTime? lastSyncTime,
    DateTime? lastLocalUpdate,
    int? version,
  }) {
    return SyncStatus(
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      state: state ?? this.state,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastLocalUpdate: lastLocalUpdate ?? this.lastLocalUpdate,
      version: version ?? this.version,
    );
  }
}
