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
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                    const SizedBox(height: 12),
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
                child: visibleTasks.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
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
                                  allTasks.isEmpty
                                      ? 'No tasks yet'
                                      : 'No matching tasks',
                                  style: textTheme.headlineSmall,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  allTasks.isEmpty
                                      ? 'Tap the + button to create your first task.'
                                      : 'Try a different search term.',
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
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: visibleTasks.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final task = visibleTasks[index];
                          return Card(
                            child: ListTile(
                              leading: Checkbox(
                                value: task.isCompleted,
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
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: task.isCompleted
                                      ? Theme.of(context).colorScheme.onSurfaceVariant
                                      : null,
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
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
