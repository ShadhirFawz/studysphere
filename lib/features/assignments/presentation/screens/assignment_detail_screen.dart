import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/models/assignment_model.dart';
import '../providers/assignment_progress_provider.dart';
import '../widgets/priority_chip.dart';
import '../widgets/status_chip.dart';
import '../widgets/assignment_attachment_card.dart';

class AssignmentDetailScreen extends ConsumerWidget {
  final AssignmentModel assignment;

  const AssignmentDetailScreen({super.key, required this.assignment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressService = ref.watch(assignmentProgressProvider);

    final progress = progressService.calculateProgress(assignment);

    return Scaffold(
      appBar: AppBar(
        title: Text(assignment.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push('/edit-assignment', extra: assignment);
            },
            tooltip: 'Edit Assignment',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeader(context, progress),
            const SizedBox(height: 16),

            // Course Info
            _buildInfoRow(
              icon: Icons.school,
              label: 'Course',
              value: assignment.course,
            ),
            const SizedBox(height: 8),

            // Type & Difficulty
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    icon: Icons.category,
                    label: 'Type',
                    value: _capitalize(assignment.type.name),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoRow(
                    icon: Icons.speed,
                    label: 'Difficulty',
                    value: _capitalize(assignment.difficulty.name),
                    valueColor: _getDifficultyColor(assignment.difficulty),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Priority & Status
            Row(
              children: [
                Expanded(
                  child: _buildChipRow(
                    icon: Icons.flag,
                    label: 'Priority',
                    widget: PriorityChip(priority: assignment.priority),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildChipRow(
                    icon: Icons.task_alt,
                    label: 'Status',
                    widget: StatusChip(status: assignment.status),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Due Date & Estimated Hours
            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: 'Due Date',
                    value: DateFormat(
                      'MMM dd, yyyy',
                    ).format(assignment.dueDate.toDate()),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoRow(
                    icon: Icons.access_time,
                    label: 'Est. Hours',
                    value: '${assignment.estimatedHours.toStringAsFixed(1)}h',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Multi-Day Info
            if (assignment.isMultiDay)
              _buildInfoRow(
                icon: Icons.date_range,
                label: 'Start Date',
                value: DateFormat(
                  'MMM dd, yyyy',
                ).format(assignment.startDate.toDate()),
              ),
            const SizedBox(height: 16),

            // Progress Section
            _buildProgressSection(progress),
            const SizedBox(height: 20),

            // Description
            if (assignment.description.isNotEmpty) ...[
              const Text(
                'Description',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  assignment.description,
                  style: const TextStyle(height: 1.5),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Checklist Section
            if (assignment.checklist.isNotEmpty) ...[
              _buildChecklistSection(),
              const SizedBox(height: 16),
            ],

            // Tags Section
            if (assignment.tags.isNotEmpty) ...[
              _buildTagsSection(),
              const SizedBox(height: 16),
            ],

            // Attachments Section
            if (assignment.attachments.isNotEmpty) ...[
              _buildAttachmentsSection(),
              const SizedBox(height: 16),
            ],

            // Notes Section
            if (assignment.notes.isNotEmpty) ...[
              const Text(
                'Notes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  assignment.notes,
                  style: const TextStyle(height: 1.5),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Created/Updated Info
            _buildMetadataSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int progress) {
    final isCompleted = assignment.status == AssignmentStatus.completed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isCompleted ? Colors.green.shade400 : Colors.blue.shade400,
            isCompleted ? Colors.green.shade700 : Colors.blue.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.assignment,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$progress% Complete',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            color: Colors.white,
            minHeight: 6,
          ),
          const SizedBox(height: 8),
          Text(
            _getProgressStatus(progress),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor ?? Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildChipRow({
    required IconData icon,
    required String label,
    required Widget widget,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        widget,
      ],
    );
  }

  Widget _buildProgressSection(int progress) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text(
                '$progress%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _progressColor(progress),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress / 100,
            color: _progressColor(progress),
            backgroundColor: Colors.grey.shade200,
            minHeight: 6,
          ),
          const SizedBox(height: 8),
          // Show additional info based on assignment type
          if (assignment.isMultiDay) ...[
            Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  'Progress calculated from start to due date',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  'Single day task',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChecklistSection() {
    final completed = assignment.checklist
        .where((item) => item.completed)
        .length;
    final total = assignment.checklist.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Checklist',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$completed/$total',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: assignment.checklist.map((item) {
              return ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
                leading: Icon(
                  item.completed
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: item.completed ? Colors.green : Colors.grey.shade400,
                  size: 20,
                ),
                title: Text(
                  item.title,
                  style: TextStyle(
                    decoration: item.completed
                        ? TextDecoration.lineThrough
                        : null,
                    color: item.completed
                        ? Colors.grey.shade600
                        : Colors.black87,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: assignment.tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getTagColor(tag.name).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                tag.name,
                style: TextStyle(
                  color: _getTagColor(tag.name),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attachments',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...assignment.attachments.map((attachment) {
          return AssignmentAttachmentCard(attachment: attachment);
        }),
      ],
    );
  }

  Widget _buildMetadataSection() {
    return Column(
      children: [
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Created: ${DateFormat('MMM dd, yyyy • h:mm a').format(assignment.createdAt.toDate())}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
            Text(
              'Updated: ${DateFormat('MMM dd, yyyy • h:mm a').format(assignment.updatedAt.toDate())}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
      ],
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Color _progressColor(int progress) {
    if (progress >= 100) return Colors.green;
    if (progress >= 60) return Colors.orange;
    return Colors.blue;
  }

  String _getProgressStatus(int progress) {
    if (progress >= 100) return '🎉 Completed!';
    if (progress >= 60) return '👍 Making good progress';
    if (progress >= 30) return '⏳ In progress';
    return '📋 Just getting started';
  }

  Color _getDifficultyColor(AssignmentDifficulty difficulty) {
    switch (difficulty) {
      case AssignmentDifficulty.easy:
        return Colors.green;
      case AssignmentDifficulty.medium:
        return Colors.orange;
      case AssignmentDifficulty.hard:
        return Colors.red;
    }
  }

  Color _getTagColor(String tag) {
    final List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
      Colors.amber,
    ];
    final index = tag.hashCode.abs() % colors.length;
    return colors[index];
  }
}
