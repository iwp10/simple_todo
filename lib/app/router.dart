import 'package:go_router/go_router.dart';
import 'package:simple_todo/feature/splash/presentation/splash_page.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),
  ],
);
