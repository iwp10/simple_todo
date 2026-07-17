import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:simple_todo/shared/models/task.dart';

enum TaskFilter { all, active, completed }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  TaskFilter _selectedFilter = TaskFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tasksBox = Hive.box<Task>('tasks');

    return ValueListenableBuilder<Box<Task>>(
      valueListenable: tasksBox.listenable(),
      builder: (context, box, _) {
        final allTasks = box.values.toList();
        final normalizedQuery = _searchQuery.trim().toLowerCase();

        final searchFilteredTasks = normalizedQuery.isEmpty
            ? allTasks
            : allTasks.where((task) {
                return task.title.toLowerCase().contains(normalizedQuery);
              }).toList();

        final visibleTasks = searchFilteredTasks.where((task) {
          switch (_selectedFilter) {
            case TaskFilter.active:
              return !task.isCompleted;
            case TaskFilter.completed:
              return task.isCompleted;
            case TaskFilter.all:
              return true;
          }
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Simple Todo'),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/add-task'),
            tooltip: 'Add Task',
            child: const Icon(Icons.add_rounded),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    children: [
                      TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search tasks',
                        prefixIcon: const Icon(Icons.search_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<TaskFilter>(
                      segments: const [
                        ButtonSegment<TaskFilter>(
                          value: TaskFilter.all,
                          label: Text('All'),
                          icon: Icon(Icons.list_rounded),
                        ),
                        ButtonSegment<TaskFilter>(
                          value: TaskFilter.active,
                          label: Text('Active'),
                          icon: Icon(Icons.radio_button_unchecked_rounded),
                        ),
                        ButtonSegment<TaskFilter>(
                          value: TaskFilter.completed,
                          label: Text('Completed'),
                          icon: Icon(Icons.check_circle_rounded),
                        ),
                      ],
                      selected: {_selectedFilter},
                      onSelectionChanged: (selection) {
                        setState(() {
                          _selectedFilter = selection.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: allTasks.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 96),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 320),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.checklist_rounded,
                                  size: 72,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No tasks yet',
                                  style: textTheme.headlineSmall,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap the + button to create your first task.',
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : visibleTasks.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 8, 24, 96),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 320),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off_rounded,
                                      size: 72,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No matching tasks',
                                      style: textTheme.headlineSmall,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Try a different search term or change the filter.',
                                      style: textTheme.bodyLarge?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
                        itemCount: visibleTasks.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final task = visibleTasks[index];
                          final isCompleted = task.isCompleted;
                          final cardColor = isCompleted
                              ? Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
                              : Theme.of(context).colorScheme.surface;

                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            color: cardColor,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                leading: Checkbox(
                                  value: isCompleted,
                                  onChanged: (value) {
                                    if (value == null) {
                                      return;
                                    }

                                    task.isCompleted = value;
                                    task.save();
                                  },
                                ),
                                title: Text(
                                  task.title,
                                  style: TextStyle(
                                    decoration: isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: isCompleted
                                        ? Theme.of(context).colorScheme.onSurfaceVariant
                                        : null,
                                    fontWeight: isCompleted ? FontWeight.w500 : FontWeight.w600,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      tooltip: 'Edit task',
                                      onPressed: () => context.push('/edit-task', extra: task),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded),
                                      tooltip: 'Delete task',
                                      onPressed: () async {
                                        final shouldDelete = await showDialog<bool>(
                                          context: context,
                                          builder: (dialogContext) => AlertDialog(
                                            title: const Text('Delete task?'),
                                            content: Text(
                                              'Delete "${task.title}"?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(dialogContext).pop(false),
                                                child: const Text('Cancel'),
                                              ),
                                              FilledButton.tonal(
                                                onPressed: () => Navigator.of(dialogContext).pop(true),
                                                child: const Text('Delete'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (shouldDelete == true) {
                                          task.delete();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              ],
            ),
          ),
        );
      },
    );
  }
}
