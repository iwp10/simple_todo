import 'package:go_router/go_router.dart';
import 'package:simple_todo/feature/add_task/presentation/add_task_page.dart';
import 'package:simple_todo/feature/home/presentation/home_page.dart';

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
  ],
);
