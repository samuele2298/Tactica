import 'package:go_router/go_router.dart';
import '../screens/main_menu_screen.dart';
import '../screens/play_setup_screen.dart';
import '../screens/play_game_screen.dart';
import '../screens/play_results_screen.dart';
import '../screens/learn_screen.dart';
import '../screens/learning_module_screen.dart';
import '../screens/classroom_screen.dart';
// import '../screens/learn_screen.dart';
// import '../screens/classroom_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Main Menu (Home)
    GoRoute(
      path: '/',
      builder: (context, state) => const MainMenuScreen(),
    ),
    
    // Sezione Gioca - Dilemma del Prigioniero
    GoRoute(
      path: '/play',
      builder: (context, state) => const PlaySetupScreen(),
    ),
    GoRoute(
      path: '/play/game',
      builder: (context, state) => const PlayGameScreen(),
    ),
    GoRoute(
      path: '/play/results',
      builder: (context, state) => const PlayResultsScreen(),
    ),
    
    // Sezione Impara
    GoRoute(
      path: '/impara',
      builder: (context, state) => const LearnScreen(),
    ),
    
    // Moduli di apprendimento
    GoRoute(
      path: '/impara/modulo/:moduleId',
      builder: (context, state) => LearningModuleScreen(
        moduleId: state.pathParameters['moduleId']!,
      ),
    ),
    
    // Sezione Classe  
    GoRoute(
      path: '/classroom',
      builder: (context, state) => const ClassroomScreen(),
    ),
    GoRoute(
      path: '/classroom/create',
      builder: (context, state) => const ClassroomScreen(), // Per ora usa la stessa schermata
    ),
  ],
);