import 'package:bloodinsight/core/config/environment.dart';
import 'package:bloodinsight/core/config/routes.dart';
import 'package:bloodinsight/core/connectivity_status.dart';
import 'package:bloodinsight/core/gemini_api.dart';
import 'package:bloodinsight/core/notification_service.dart';
import 'package:bloodinsight/core/styles/assets.dart';
import 'package:bloodinsight/core/styles/theme.dart';
import 'package:bloodinsight/features/auth/logic/auth_cubit.dart';
import 'package:bloodinsight/firebase_options.dart';
import 'package:bloodinsight/shared/services/auth_service.dart';
import 'package:bloodinsight/shared/services/bloodwork_service.dart';
import 'package:bloodinsight/shared/services/facility_service.dart';
import 'package:bloodinsight/shared/services/insights_service.dart';
import 'package:bloodinsight/shared/services/reminder_service.dart';
import 'package:bloodinsight/shared/services/user_profile_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final router = await createRouter();

  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);

  // Connectivity status
  final connectionStatus = ConnectionStatus();
  await connectionStatus.checkConnection();
  GetIt.instance.registerSingleton<ConnectionStatus>(connectionStatus);

  // Notification service
  final notifications = NotificationService();
  await notifications.init();
  GetIt.instance.registerSingleton<NotificationService>(notifications);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top],
  );

  runApp(MainApp(router: router));
}

class MainApp extends StatelessWidget {
  const MainApp({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    precacheImages(context);
    FlutterNativeSplash.remove();

    return MultiProvider(
      providers: [
        Provider(
          create: (context) => AuthService(
            firebaseAuth: FirebaseAuth.instance,
          ),
        ),
        Provider(
          create: (context) => ProfileService(),
        ),
        Provider(
          create: (context) => BloodworkService(
            db: FirebaseFirestore.instance,
            auth: context.read(),
          ),
        ),
        Provider(
          create: (context) => FacilityService(),
        ),
        Provider(
          create: (context) => ReminderService(
            db: FirebaseFirestore.instance,
            auth: context.read(),
            notifications: GetIt.I<NotificationService>(),
          ),
        ),
        Provider(
          create: (context) => InsightsService(
            gemini: GeminiAPI(apiKey: Environment.geminiAPI),
            bloodworkService: context.read(),
            profileService: context.read(),
            auth: context.read(),
          ),
        ),
        BlocProvider(
          create: (context) => AuthCubit(
            authService: context.read(),
            profileService: context.read(),
          ),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        title: 'BloodInsight',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

void precacheImages(BuildContext context) {
  for (final image in AppImages.images) {
    precacheImage(AssetImage(image), context);
  }
}
