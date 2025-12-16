import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

// AJOUT: Pour la détection web et Firebase
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:birthday_reminder/core/themes/app_themes.dart';
import 'package:birthday_reminder/core/utils/notification_utils.dart';

import 'package:birthday_reminder/data/datasources/local/database_helper.dart';
import 'package:birthday_reminder/data/datasources/local/birthday_local_datasource.dart';
// AJOUT: Imports pour Firebase
import 'package:birthday_reminder/data/datasources/birthday_data_source.dart';
import 'package:birthday_reminder/data/datasources/remote/firebase_birthday_datasource.dart';

import 'package:birthday_reminder/data/repositories/birthday_repository_impl.dart';
import 'package:birthday_reminder/domain/repositories/birthday_repository.dart';
import 'package:birthday_reminder/domain/usecases/get_birthdays_usecase.dart';
import 'package:birthday_reminder/domain/usecases/add_birthday_usecase.dart';
import 'package:birthday_reminder/domain/usecases/delete_birthday_usecase.dart';
import 'package:birthday_reminder/domain/usecases/schedule_notification_usecase.dart';

import 'package:birthday_reminder/presentation/bloc/birthday_bloc.dart';
import 'package:birthday_reminder/presentation/bloc/birthday_event.dart';
import 'package:birthday_reminder/presentation/pages/home_page.dart';
import 'package:birthday_reminder/presentation/pages/add_birthday_page.dart';
import 'package:birthday_reminder/presentation/pages/settings_page.dart';
import 'package:birthday_reminder/data/models/birthday_model.dart';
import 'package:birthday_reminder/presentation/pages/login_page.dart';

// AJOUT: Options Firebase (sera généré par flutterfire configure)
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // AJOUT: Logique différente pour web/mobile
  if (kIsWeb) {
    // ============ WEB: FIREBASE ============
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialisé avec succès pour le web');

      // AJOUT IMPORTANT: Configurer la persistance
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
      print('Persistance LOCAL configurée pour le web');

      // AJOUT: Vérifier l'état d'authentification au démarrage
      final currentUser = FirebaseAuth.instance.currentUser;
      print('Utilisateur actuel au démarrage: ${currentUser?.email ?? "Aucun"}');

      // AJOUT: Log supplémentaire pour suivre les changements d'auth
      FirebaseAuth.instance.authStateChanges().listen((user) {
        print('[AUTH LISTENER] Changement détecté: ${user?.email ?? "null"} à ${DateTime.now()}');
      });

    } catch (e) {
      print('Erreur d\'initialisation Firebase: $e');
    }
  } else {
    // ============ MOBILE: HIVE/SQLITE ============
    try {
      await Hive.initFlutter();
      Hive.registerAdapter(BirthdayModelAdapter());
      await Hive.openBox<BirthdayModel>('birthdays');
      await DatabaseHelper.ensureInitialized();
      await NotificationUtils.initialize();
      print('Hive/SQLite initialisé avec succès pour le mobile');
    } catch (e) {
      print('Erreur d\'initialisation Hive: $e');
      // Réessayer
      await Hive.initFlutter();
      Hive.registerAdapter(BirthdayModelAdapter());
      await Hive.openBox<BirthdayModel>('birthdays');
    }
  }

  runApp(const MyApp());
}

// ============ VERSION FINALE CORRIGÉE DE MyApp ============
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        if (!kIsWeb)
          RepositoryProvider<DatabaseHelper>(
            create: (context) => DatabaseHelper(),
          ),
        RepositoryProvider<BirthdayRepository>(
          create: (context) {
            BirthdayDataSource dataSource;

            if (kIsWeb) {
              dataSource = FirebaseBirthdayDataSource();
            } else {
              final databaseHelper = context.read<DatabaseHelper>();
              dataSource = BirthdayLocalDataSourceImpl(databaseHelper);
            }

            return BirthdayRepositoryImpl(dataSource: dataSource);
          },
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<BirthdayBloc>(
            create: (context) {
              final repository = context.read<BirthdayRepository>();

              final bloc = BirthdayBloc(
                getBirthdaysUseCase: GetBirthdaysUseCase(repository: repository),
                addBirthdayUseCase: AddBirthdayUseCase(repository: repository),
                deleteBirthdayUseCase: DeleteBirthdayUseCase(repository: repository),
                scheduleNotificationUseCase: ScheduleNotificationUseCase(repository: repository),
              );

              Future.microtask(() => bloc.add(LoadBirthdaysEvent()));

              return bloc;
            },
          ),
        ],
        child: MaterialApp(
          title: 'Birthday Reminder',
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: ThemeMode.system,
          // MODIFICATION IMPORTANTE: Pas de StreamBuilder ici
          home: kIsWeb ? const _WebAuthWrapper() : const HomePage(),
          debugShowCheckedModeBanner: false,
          routes: {
            '/home': (context) => const HomePage(),
            '/add-birthday': (context) => const AddBirthdayPage(),
            '/settings': (context) => const SettingsPage(),
            '/login': (context) => const LoginPage(),
          },
        ),
      ),
    );
  }
}

// NOUVELLE CLASSE: Wrapper pour l'authentification web
// Placée à l'intérieur des providers pour avoir accès au contexte
class _WebAuthWrapper extends StatelessWidget {
  const _WebAuthWrapper();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // AJOUT: Logs détaillés pour diagnostic
        print('=== DÉBUT Auth Stream ===');
        print('État connexion: ${snapshot.connectionState}');
        print('Utilisateur présent: ${snapshot.hasData}');
        print('Email: ${snapshot.data?.email ?? "null"}');
        print('Erreur: ${snapshot.error}');
        print('Timestamp: ${DateTime.now().millisecondsSinceEpoch}');
        print('=== FIN Auth Stream ===');

        // État de chargement
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Si l'utilisateur est connecté
        if (snapshot.hasData && snapshot.data != null) {
          print('✅ Utilisateur connecté, affichage HomePage');

          // Vérifiez que le Bloc est disponible
          try {
            final bloc = context.read<BirthdayBloc>();
            print('Bloc disponible dans HomePage: $bloc');
          } catch (e) {
            print('⚠️ Attention: $e');
          }

          return const HomePage();
        }

        // Si l'utilisateur n'est pas connecté
        print('🔴 Utilisateur non connecté, affichage LoginPage');
        return const LoginPage();
      },
    );
  }
}