import 'package:bloodinsight/features/auth/data/auth_state.dart';
import 'package:bloodinsight/features/auth/logic/auth_cubit.dart';
import 'package:bloodinsight/features/auth/presentation/login_page.dart';
import 'package:bloodinsight/features/auth/presentation/signup_page.dart';
import 'package:bloodinsight/features/bloodwork/presentation/add_bloodwork_page.dart';
import 'package:bloodinsight/features/bloodwork/presentation/bloodwork_details_page.dart';
import 'package:bloodinsight/features/bloodwork/presentation/bloodwork_history_page.dart';
import 'package:bloodinsight/features/dashboard/presentation/dashboard_page.dart';
import 'package:bloodinsight/features/get_started/presentation/get_started_page.dart';
import 'package:bloodinsight/features/insights/presentation/insights_page.dart';
import 'package:bloodinsight/features/map/presentation/map_page.dart';
import 'package:bloodinsight/features/reminders/presentation/add_reminder.dart';
import 'package:bloodinsight/features/reminders/presentation/reschedule_reminder.dart';
import 'package:bloodinsight/features/user_profile/data/user_profile_model.dart';
import 'package:bloodinsight/features/user_profile/presentation/edit_user_profile_page.dart';
import 'package:bloodinsight/features/user_profile/presentation/user_profile_page.dart';
import 'package:bloodinsight/shared/widgets/scaffold_navbar.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getInitialRoute() async {
  final prefs = await SharedPreferences.getInstance();
  final isFirstTime = prefs.getBool('isFirstTime') ?? true;

  return isFirstTime ? '/get-started' : '/login';
}

Future<GoRouter> createRouter() async {
  final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'rootNav');
  final tabNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'tabNav');

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: await getInitialRoute(),
    redirect: (context, state) async {
      final route = state.uri.toString();
      final authCubit = BlocProvider.of<AuthCubit>(context);
      final isLoggedIn = authCubit.state is SignedInState;
      final isLoggingIn = route == '/login';

      final exclusionRoutes = ['/get-started', '/sign-up'];
      if (exclusionRoutes.contains(route)) {
        return null;
      }

      if (isLoggedIn && isLoggingIn) {
        return '/dashboard';
      } else if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/get-started',
        builder: (context, state) => const GetStartedPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
        routes: [
          GoRoute(
            path: '/edit',
            builder: (context, state) => EditProfilePage(
              profile: state.extra! as UserProfile,
            ),
          ),
        ],
      ),
      ShellRoute(
        navigatorKey: tabNavigatorKey,
        builder: (context, state, child) => ScaffoldWithNavBar(
          location: state.uri.toString(),
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/insights',
            builder: (context, state) => const InsightsPage(),
          ),
          GoRoute(
            path: '/map',
            builder: (context, state) => const MapPage(),
          ),
          GoRoute(
            path: '/bloodwork',
            builder: (context, state) => const BloodworkHistoryPage(),
            routes: [
              GoRoute(
                parentNavigatorKey: rootNavigatorKey,
                path: '/add',
                builder: (context, state) => const AddBloodworkPage(),
              ),
              GoRoute(
                parentNavigatorKey: rootNavigatorKey,
                path: '/:id/edit',
                builder: (context, state) => AddBloodworkPage(
                  bloodworkId: state.pathParameters['id'],
                ),
              ),
              GoRoute(
                parentNavigatorKey: rootNavigatorKey,
                path: '/:id',
                builder: (context, state) => BloodworkDetailsPage(
                  bloodworkId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/reminder/add',
        builder: (context, state) => const AddReminderPage(),
      ),
      GoRoute(
        path: '/reminder/reschedule/:id',
        builder: (context, state) {
          final reminderId = state.pathParameters['id']!;
          return RescheduleReminderPage(reminderId: reminderId);
        },
      ),
    ],
  );
}
