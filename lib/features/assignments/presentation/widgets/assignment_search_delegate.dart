import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/assignment_model.dart';
import '../providers/assignment_provider.dart';
import 'assignment_card.dart';

class AssignmentSearchDelegate extends SearchDelegate<AssignmentModel?> {
  final WidgetRef ref;

  AssignmentSearchDelegate(this.ref)
    : super(
        searchFieldLabel: 'Search assignments...',
        keyboardType: TextInputType.text,
      );

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = '';
          }
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final assignmentsAsync = ref.watch(assignmentsProvider);

    return assignmentsAsync.when(
      data: (assignments) {
        final results = _filterAssignments(assignments);
        return _buildResultsList(results);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final assignmentsAsync = ref.watch(assignmentsProvider);

    return assignmentsAsync.when(
      data: (assignments) {
        final suggestions = _getSuggestions(assignments);
        return _buildSuggestionsList(suggestions);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  List<AssignmentModel> _filterAssignments(List<AssignmentModel> assignments) {
    if (query.isEmpty) return assignments;

    final q = query.toLowerCase();
    return assignments
        .where(
          (a) =>
              a.title.toLowerCase().contains(q) ||
              a.course.toLowerCase().contains(q) ||
              a.description.toLowerCase().contains(q) ||
              a.type.name.toLowerCase().contains(q) ||
              a.status.name.toLowerCase().contains(q),
        )
        .toList();
  }

  List<AssignmentModel> _getSuggestions(List<AssignmentModel> assignments) {
    if (query.isEmpty) return [];

    final q = query.toLowerCase();
    return assignments
        .where(
          (a) =>
              a.title.toLowerCase().contains(q) ||
              a.course.toLowerCase().contains(q),
        )
        .take(5)
        .toList();
  }

  Widget _buildResultsList(List<AssignmentModel> results) {
    if (results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No assignments found', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: AssignmentCard(assignment: results[index]),
        );
      },
    );
  }

  Widget _buildSuggestionsList(List<AssignmentModel> suggestions) {
    if (suggestions.isEmpty && query.isNotEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No matching assignments found',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    if (suggestions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Search for assignments by title, course, or description',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final assignment = suggestions[index];
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getTypeIcon(assignment.type),
              size: 18,
              color: Colors.blue.shade700,
            ),
          ),
          title: Text(
            assignment.title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            '${assignment.course} • ${assignment.status.name}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          trailing: const Icon(Icons.search, size: 18, color: Colors.grey),
          onTap: () {
            query = assignment.title;
            showResults(context);
          },
        );
      },
    );
  }

  IconData _getTypeIcon(AssignmentType type) {
    switch (type) {
      case AssignmentType.homework:
        return Icons.home_work;
      case AssignmentType.lab:
        return Icons.science;
      case AssignmentType.quiz:
        return Icons.quiz;
      case AssignmentType.presentation:
        return Icons.present_to_all;
      case AssignmentType.project:
        return Icons.folder_sharp;
      case AssignmentType.exam:
        return Icons.assignment;
      case AssignmentType.custom:
        return Icons.add_task;
    }
  }
}
