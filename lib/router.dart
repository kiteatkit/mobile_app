import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/mode_select_page.dart';
import 'pages/player_login_page.dart';
import 'pages/coach_login_page.dart';
import 'pages/player_dashboard_page.dart';
import 'models/player.dart';
import 'models/group.dart';
import 'pages/group_view_page.dart';
import 'pages/player_profile_page.dart';
import 'pages/player_stats_page.dart';
import 'pages/coach_dashboard_page.dart';

final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) =>
          const ModeSelectPage(),
    ),
    GoRoute(
      path: '/login/player',
      builder: (BuildContext context, GoRouterState state) =>
          const PlayerLoginPage(),
    ),
    GoRoute(
      path: '/login/coach',
      builder: (BuildContext context, GoRouterState state) =>
          const CoachLoginPage(),
    ),
    GoRoute(
      path: '/dashboard/player',
      builder: (BuildContext context, GoRouterState state) {
        final player = state.extra as Player;
        return PlayerDashboardPage(player: player);
      },
    ),
    GoRoute(
      path: '/dashboard/coach',
      builder: (BuildContext context, GoRouterState state) =>
          const CoachDashboardPage(),
    ),
    GoRoute(
      path: '/group-view',
      builder: (BuildContext context, GoRouterState state) {
        if (state.extra is Map<String, dynamic>) {
          final extra = state.extra as Map<String, dynamic>;
          final group = extra['group'] as Group;
          final isPlayerMode = extra['isPlayerMode'] as bool? ?? false;
          return GroupViewPage(group: group, isPlayerMode: isPlayerMode);
        } else {
          final group = state.extra as Group;
          return GroupViewPage(group: group, isPlayerMode: false);
        }
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (BuildContext context, GoRouterState state) {
        final player = state.extra as Player;
        return PlayerProfilePage(player: player);
      },
    ),
    GoRoute(
      path: '/stats',
      builder: (BuildContext context, GoRouterState state) {
        final player = state.extra as Player;
        return PlayerStatsPage(player: player);
      },
    ),
  ],
);
