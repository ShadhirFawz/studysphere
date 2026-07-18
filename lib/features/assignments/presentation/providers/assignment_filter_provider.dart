import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/assignment_model.dart';
import 'assignment_provider.dart';

class AssignmentFilterState {
  static const Object _unset = Object();

  final String? searchQuery;
  final List<AssignmentPriority> priorities;
  final List<AssignmentStatus> statuses;
  final List<String> courses;
  final List<AssignmentType> types;
  final List<AssignmentDifficulty> difficulties;
  final String? sortBy;
  final bool sortAscending;

  const AssignmentFilterState({
    this.searchQuery,
    this.priorities = const [],
    this.statuses = const [],
    this.courses = const [],
    this.types = const [],
    this.difficulties = const [],
    this.sortBy,
    this.sortAscending = true,
  });

  AssignmentFilterState copyWith({
    String? searchQuery,
    List<AssignmentPriority>? priorities,
    List<AssignmentStatus>? statuses,
    List<String>? courses,
    List<AssignmentType>? types,
    List<AssignmentDifficulty>? difficulties,
    Object? sortBy = _unset,
    bool? sortAscending,
  }) {
    return AssignmentFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      priorities: priorities ?? this.priorities,
      statuses: statuses ?? this.statuses,
      courses: courses ?? this.courses,
      types: types ?? this.types,
      difficulties: difficulties ?? this.difficulties,
      sortBy: identical(sortBy, _unset) ? this.sortBy : sortBy as String?,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  bool get hasActiveFilters {
    return priorities.isNotEmpty ||
        statuses.isNotEmpty ||
        courses.isNotEmpty ||
        types.isNotEmpty ||
        difficulties.isNotEmpty ||
        (searchQuery != null && searchQuery!.isNotEmpty);
  }

  int get activeFilterCount {
    int count = 0;
    if (priorities.isNotEmpty) count++;
    if (statuses.isNotEmpty) count++;
    if (courses.isNotEmpty) count++;
    if (types.isNotEmpty) count++;
    if (difficulties.isNotEmpty) count++;
    if (searchQuery != null && searchQuery!.isNotEmpty) count++;
    return count;
  }

  List<AssignmentModel> apply(
    List<AssignmentModel> assignments, {
    int Function(AssignmentModel)? progressGetter,
  }) {
    var filtered = assignments;

    // Apply filters
    if (priorities.isNotEmpty) {
      filtered = filtered
          .where((a) => priorities.contains(a.priority))
          .toList();
    }

    if (statuses.isNotEmpty) {
      filtered = filtered.where((a) => statuses.contains(a.status)).toList();
    }

    if (courses.isNotEmpty) {
      filtered = filtered.where((a) => courses.contains(a.course)).toList();
    }

    if (types.isNotEmpty) {
      filtered = filtered.where((a) => types.contains(a.type)).toList();
    }

    if (difficulties.isNotEmpty) {
      filtered = filtered
          .where((a) => difficulties.contains(a.difficulty))
          .toList();
    }

    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final query = searchQuery!.toLowerCase();
      filtered = filtered
          .where(
            (a) =>
                a.title.toLowerCase().contains(query) ||
                a.course.toLowerCase().contains(query) ||
                a.description.toLowerCase().contains(query) ||
                a.type.name.toLowerCase().contains(query) ||
                a.status.name.toLowerCase().contains(query),
          )
          .toList();
    }

    // Apply sorting
    if (sortBy != null) {
      switch (sortBy) {
        case 'title':
          filtered.sort((a, b) => a.title.compareTo(b.title));
          break;
        case 'dueDate':
          filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));
          break;
        case 'priority':
          filtered.sort((a, b) => a.priority.index.compareTo(b.priority.index));
          break;
        case 'progress':
          if (progressGetter != null) {
            filtered.sort(
              (a, b) => progressGetter(a).compareTo(progressGetter(b)),
            );
          }
          break;
        case 'estimatedHours':
          filtered.sort((a, b) => a.estimatedHours.compareTo(b.estimatedHours));
          break;
        case 'status':
          filtered.sort((a, b) => a.status.index.compareTo(b.status.index));
          break;
      }

      if (!sortAscending) {
        filtered = filtered.reversed.toList();
      }
    }

    return filtered;
  }
}

final assignmentFilterProvider = StateProvider<AssignmentFilterState>((ref) {
  return const AssignmentFilterState();
});

final filteredAssignmentsProvider = Provider<AsyncValue<List<AssignmentModel>>>(
  (ref) {
    final assignmentsAsync = ref.watch(assignmentsProvider);

    return assignmentsAsync.when(
      data: (assignments) {
        final filter = ref.watch(assignmentFilterProvider);
        final filtered = filter.apply(assignments);
        return AsyncValue.data(filtered);
      },
      loading: () => const AsyncValue.loading(),
      error: (error, stack) => AsyncValue.error(error, stack),
    );
  },
);
