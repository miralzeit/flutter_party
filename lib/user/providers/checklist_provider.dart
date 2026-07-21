import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/checklist_api_service.dart';

final checklistApiServiceProvider = Provider<ChecklistApiService>((ref) {
  return ChecklistApiService();
});

final checklistTasksProvider = StateProvider<List<ChecklistTask>>((ref) => []);
