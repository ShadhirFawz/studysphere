import 'package:flutter_riverpod/flutter_riverpod.dart';

final assignmentSelectionProvider = StateProvider<Set<String>>((ref) {
  return {};
});

final isSelectionModeProvider = StateProvider<bool>((ref) {
  return false;
});
