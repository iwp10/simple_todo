import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:simple_todo/shared/models/task.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _saveTask(BuildContext context) {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      return;
    }

    final tasksBox = Hive.box<Task>('tasks');
    tasksBox.add(
      Task(
        title: title,
        createdAt: DateTime.now(),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              autofocus: true,
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                hintText: 'Enter your task',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _saveTask(context),
              child: const Text('Save Task'),
            ),
          ],
        ),
      ),
    );
  }
}
