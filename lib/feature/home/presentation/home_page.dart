import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:simple_todo/shared/models/task.dart';
import 'package:simple_todo/shared/services/settings_service.dart';

enum TaskFilter { all, active, completed }

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
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

        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            title: const Text('Simple Todo'),
            actions: [
              TextButton.icon(
                onPressed: () async {
                  final currentThemeMode = ref.read(themeModeControllerProvider);
                  final nextThemeMode = currentThemeMode == ThemeMode.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
                  await ref.read(themeModeControllerProvider.notifier).changeThemeMode(nextThemeMode);
                },
                icon: Icon(
                  isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                ),
                label: Text(isDarkMode ? 'Dark' : 'Light'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
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
                child: visibleTasks.isEmpty
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
