import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:birthday_reminder/core/themes/app_themes.dart';
import 'package:birthday_reminder/core/utils/notification_utils.dart';

import 'package:birthday_reminder/data/datasources/local/database_helper.dart';
import 'package:birthday_reminder/data/datasources/local/birthday_local_datasource.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialiser Hive une seule fois
    await Hive.initFlutter();

    await Hive.deleteBoxFromDisk('birthdays');

    // Utiliser ensureInitialized de DatabaseHelper
    await DatabaseHelper.ensureInitialized();

  } catch (e) {
    print('Erreur Hive: $e');
    // Réessayer
    await Hive.initFlutter();
    await DatabaseHelper.ensureInitialized();
  }

  // Initialiser les notifications
  await NotificationUtils.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // AJOUT: Provider pour DatabaseHelper
        RepositoryProvider<DatabaseHelper>(
          create: (context) => DatabaseHelper(),
        ),
        RepositoryProvider<BirthdayRepository>(
          create: (context) => BirthdayRepositoryImpl(
            localDataSource: BirthdayLocalDataSourceImpl(
              context.read<DatabaseHelper>(), // MODIF: Passer DatabaseHelper
            ),
          ),
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

              // Charger les anniversaires au démarrage
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
          home: const HomePage(),
          debugShowCheckedModeBanner: false,
          routes: {
            '/home': (context) => const HomePage(),
            '/add-birthday': (context) => const AddBirthdayPage(),
            '/settings': (context) => const SettingsPage(),
          },
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/add-birthday':
                return MaterialPageRoute(builder: (_) => const AddBirthdayPage());
              case '/settings':
                return MaterialPageRoute(builder: (_) => const SettingsPage());
              default:
                return MaterialPageRoute(builder: (_) => const HomePage());
            }
          },
        ),
      ),
    );
  }
}