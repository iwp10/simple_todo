import 'package:go_router/go_router.dart';
import 'package:simple_todo/feature/add_task/presentation/add_task_page.dart';
import 'package:simple_todo/feature/edit_task/presentation/edit_task_page.dart';
import 'package:simple_todo/feature/home/presentation/home_page.dart';
import 'package:simple_todo/shared/models/task.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/add-task',
      builder: (context, state) => const AddTaskPage(),
    ),
    GoRoute(
      path: '/edit-task',
      builder: (context, state) {
        final task = state.extra as Task?;
        if (task == null) {
          return const HomePage();
        }

        return EditTaskPage(task: task);
      },
    ),
  ],
);
