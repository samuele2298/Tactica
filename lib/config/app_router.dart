import 'package:go_router/go_router.dart';
import '../screens/main_menu_screen.dart';
import '../screens/game_modes/classic_screen.dart';
import '../screens/game_modes/simultaneous_screen.dart';
import '../screens/game_modes/coop_screen.dart';
import '../screens/game_modes/nebel_screen.dart';
import '../screens/game_modes/guess_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Main Menu (Home)
    GoRoute(
      path: '/',
      builder: (context, state) => const MainMenuScreen(),
    ),
    
    // Classic Tic Tac Toe (il nostro gioco esistente)
    GoRoute(
      path: '/classic',
      builder: (context, state) => const ClassicScreen(),
    ),
    
    // Simultaneous Tic Tac Toe
    GoRoute(
      path: '/simultaneous',
      builder: (context, state) => const SimultaneousScreen(),
    ),
    
    // Co-op Tic Tac Toe
    GoRoute(
      path: '/coop',
      builder: (context, state) => const CoopScreen(),
    ),
    
    // Nebel Tic Tac Toe
    GoRoute(
      path: '/nebel',
      builder: (context, state) => const NebelScreen(),
    ),
    
    // Guess & Match Tic Tac Toe
    GoRoute(
      path: '/guess',
      builder: (context, state) => const GuessScreen(),
    ),
  ],
);