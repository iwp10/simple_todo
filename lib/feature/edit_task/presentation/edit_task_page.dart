import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_todo/shared/models/task.dart';

class EditTaskPage extends StatefulWidget {
  const EditTaskPage({super.key, required this.task});

  final Task task;

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _saveTask(BuildContext context) {
    final newTitle = _titleController.text.trim();
    if (newTitle.isEmpty) {
      return;
    }

    widget.task.title = newTitle;
    widget.task.save();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Task')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                hintText: 'Enter your task',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _saveTask(context),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
