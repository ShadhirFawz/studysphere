import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/assignment_model.dart';
import '../../data/models/assignment_checklist_item.dart';
import '../providers/assignment_provider.dart';
import '../providers/assignment_progress_provider.dart';
import '../providers/assignment_status_provider.dart';
import '../widgets/priority_chip.dart';
import '../widgets/status_chip.dart';
import '../widgets/assignment_attachment_card.dart';

class AssignmentDetailScreen extends ConsumerStatefulWidget {
  final AssignmentModel assignment;

  const AssignmentDetailScreen({super.key, required this.assignment});

  @override
  ConsumerState<AssignmentDetailScreen> createState() =>
      _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState
    extends ConsumerState<AssignmentDetailScreen> {
  late AssignmentModel _assignment;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _assignment = widget.assignment;
    // Auto-update status on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoUpdateStatus();
    });
  }

  Future<void> _autoUpdateStatus() async {
    try {
      await updateAssignmentStatus(ref, _assignment);
      // Refresh the assignment data
      final repo = ref.read(assignmentRepositoryProvider);
      final updated = await repo.getAssignmentById(_assignment.id);
      if (updated != null && mounted) {
        setState(() {
          _assignment = updated;
        });
      }
    } catch (e) {
      // Silently fail - status will update on next load
    }
  }

  Future<void> _toggleChecklistItem(AssignmentChecklistItem item) async {
    final shouldComplete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          item.completed ? "Mark as Incomplete?" : "Mark as Completed?",
        ),
        content: Text(
          item.completed
              ? 'Are you sure you want to mark "${item.title}" as incomplete?'
              : 'Are you sure you want to mark "${item.title}" as completed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(item.completed ? "Mark Incomplete" : "Mark Complete"),
          ),
        ],
      ),
    );

    if (shouldComplete != true) return;

    setState(() => _isUpdating = true);

    try {
      final updatedChecklist = _assignment.checklist.map((e) {
        if (e.id == item.id) {
          return e.copyWith(completed: !e.completed);
        }
        return e;
      }).toList();

      final updatedAssignment = _assignment.copyWith(
        checklist: updatedChecklist,
        updatedAt: Timestamp.now(),
      );

      final repo = ref.read(assignmentRepositoryProvider);
      await repo.updateAssignment(updatedAssignment);

      setState(() {
        _assignment = updatedAssignment;
        _isUpdating = false;
      });

      // Auto-update status after checklist change
      await _autoUpdateStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              item.completed
                  ? 'Item marked as incomplete'
                  : 'Item marked as completed! 🎉',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: item.completed ? Colors.orange : Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isUpdating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progressService = ref.watch(assignmentProgressProvider);
    final progress = progressService.calculateProgress(_assignment);

    // Get auto-calculated status
    final autoStatus = ref.watch(autoAssignmentStatusProvider(_assignment));

    // Use auto-status for display if not manually set
    final displayStatus = ref.watch(shouldAutoUpdateStatusProvider(_assignment))
        ? autoStatus
        : _assignment.status;

    // Update local assignment status if different from display status
    if (_assignment.status != displayStatus && !_isUpdating) {
      setState(() {
        _assignment = _assignment.copyWith(status: displayStatus);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_assignment.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push('/edit-assignment', extra: _assignment);
            },
            tooltip: 'Edit Assignment',
          ),
        ],
      ),
      body: _isUpdating
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, progress, displayStatus),
                  const SizedBox(height: 16),

                  // Status Info Row
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        displayStatus,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getStatusColor(
                          displayStatus,
                        ).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getStatusIcon(displayStatus),
                          color: _getStatusColor(displayStatus),
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status: ${_getStatusDisplayText(displayStatus)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(displayStatus),
                                ),
                              ),
                              if (ref.watch(
                                shouldAutoUpdateStatusProvider(_assignment),
                              ))
                                Text(
                                  'Auto-updated based on dates',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Course Info
                  _buildInfoRow(
                    icon: Icons.school,
                    label: 'Course',
                    value: _assignment.course,
                  ),
                  const SizedBox(height: 8),

                  // Type & Difficulty
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoRow(
                          icon: Icons.category,
                          label: 'Type',
                          value: _capitalize(_assignment.type),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoRow(
                          icon: Icons.speed,
                          label: 'Difficulty',
                          value: _capitalize(_assignment.difficulty.name),
                          valueColor: _getDifficultyColor(
                            _assignment.difficulty,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Priority & Status (using display status)
                  Row(
                    children: [
                      Expanded(
                        child: _buildChipRow(
                          icon: Icons.flag,
                          label: 'Priority',
                          widget: PriorityChip(priority: _assignment.priority),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildChipRow(
                          icon: Icons.task_alt,
                          label: 'Status',
                          widget: StatusChip(status: displayStatus),
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
                          ).format(_assignment.dueDate.toDate()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildInfoRow(
                          icon: Icons.access_time,
                          label: 'Est. Hours',
                          value:
                              '${_assignment.estimatedHours.toStringAsFixed(1)}h',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Multi-Day Info
                  if (_assignment.isMultiDay)
                    _buildInfoRow(
                      icon: Icons.date_range,
                      label: 'Start Date',
                      value: DateFormat(
                        'MMM dd, yyyy',
                      ).format(_assignment.startDate.toDate()),
                    ),
                  const SizedBox(height: 16),

                  // Progress Section
                  _buildProgressSection(progress),
                  const SizedBox(height: 20),

                  // Description
                  if (_assignment.description.isNotEmpty) ...[
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _assignment.description,
                        style: const TextStyle(height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Checklist Section
                  if (_assignment.checklist.isNotEmpty) ...[
                    _buildChecklistSection(),
                    const SizedBox(height: 16),
                  ],

                  // Tags Section
                  if (_assignment.tags.isNotEmpty) ...[
                    _buildTagsSection(),
                    const SizedBox(height: 16),
                  ],

                  // Attachments Section
                  if (_assignment.attachments.isNotEmpty) ...[
                    _buildAttachmentsSection(),
                    const SizedBox(height: 16),
                  ],

                  // Notes Section
                  if (_assignment.notes.isNotEmpty) ...[
                    const Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _assignment.notes,
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

  Widget _buildHeader(
    BuildContext context,
    int progress,
    AssignmentStatus status,
  ) {
    final isCompleted = status == AssignmentStatus.completed;

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
                      _assignment.title,
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

  // ... (rest of the methods remain the same with minor updates)

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
          if (_assignment.isMultiDay) ...[
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
    final completed = _assignment.checklist
        .where((item) => item.completed)
        .length;
    final total = _assignment.checklist.length;

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
            children: _assignment.checklist.map((item) {
              return ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
                leading: GestureDetector(
                  onTap: () => _toggleChecklistItem(item),
                  child: Icon(
                    item.completed
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: item.completed ? Colors.green : Colors.grey.shade400,
                    size: 22,
                  ),
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
                trailing: IconButton(
                  icon: Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Colors.grey.shade400,
                  ),
                  onPressed: () {
                    _showItemDetailDialog(item);
                  },
                  tooltip: 'View details',
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Future<void> _showItemDetailDialog(AssignmentChecklistItem item) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status: ${item.completed ? "✅ Completed" : "⏳ Pending"}',
              style: TextStyle(
                color: item.completed ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ID: ${item.id.substring(0, 8)}...',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _toggleChecklistItem(item);
            },
            child: Text(item.completed ? 'Mark Incomplete' : 'Mark Complete'),
          ),
        ],
      ),
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
          children: _assignment.tags.map((tag) {
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
        ..._assignment.attachments.map((attachment) {
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
              'Created: ${DateFormat('MMM dd, yyyy • h:mm a').format(_assignment.createdAt.toDate())}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
            Text(
              'Updated: ${DateFormat('MMM dd, yyyy • h:mm a').format(_assignment.updatedAt.toDate())}',
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

  // ============================================
  // Status Helper Methods
  // ============================================

  Color _getStatusColor(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.draft:
        return Colors.grey;
      case AssignmentStatus.pending:
        return Colors.orange;
      case AssignmentStatus.inProgress:
        return Colors.blue;
      case AssignmentStatus.submitted:
        return Colors.teal;
      case AssignmentStatus.completed:
        return Colors.green;
      case AssignmentStatus.cancelled:
        return Colors.red;
      case AssignmentStatus.overdue:
        return Colors.deepOrange;
    }
  }

  IconData _getStatusIcon(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.draft:
        return Icons.drafts;
      case AssignmentStatus.pending:
        return Icons.pending;
      case AssignmentStatus.inProgress:
        return Icons.play_circle;
      case AssignmentStatus.submitted:
        return Icons.send;
      case AssignmentStatus.completed:
        return Icons.check_circle;
      case AssignmentStatus.cancelled:
        return Icons.cancel;
      case AssignmentStatus.overdue:
        return Icons.warning;
    }
  }

  String _getStatusDisplayText(AssignmentStatus status) {
    switch (status) {
      case AssignmentStatus.draft:
        return '📝 Draft';
      case AssignmentStatus.pending:
        return '⏳ Pending';
      case AssignmentStatus.inProgress:
        return '🔄 In Progress';
      case AssignmentStatus.submitted:
        return '📤 Submitted';
      case AssignmentStatus.completed:
        return '✅ Completed';
      case AssignmentStatus.cancelled:
        return '❌ Cancelled';
      case AssignmentStatus.overdue:
        return '⚠️ Overdue';
    }
  }
}
