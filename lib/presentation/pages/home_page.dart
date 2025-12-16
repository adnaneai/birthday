import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// AJOUT: Import pour Firebase et détection web
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/widgets/custom_app_bar.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart';
import '../widgets/upcoming_birthdays.dart';
import '../bloc/birthday_bloc.dart';
import '../bloc/birthday_event.dart';
import '../bloc/birthday_state.dart';
// DOIT ÊTRE PRÉSENT DANS LES DEUX FICHIERS :
import '../../../domain/entities/birthday_entity.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // AJOUT IMPORTANT: addPostFrameCallback pour éviter signOut() automatique
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<BirthdayBloc>();
        print('[HomePage] PostFrame: Bloc accessible');
      } catch (e) {
        print('[HomePage] ⚠️ PostFrame: Bloc non disponible: $e');
        // NE JAMAIS faire FirebaseAuth.instance.signOut() ici !
      }
    });

    // AJOUT: Vérifications pour le web (UNIQUEMENT sur web)
    if (kIsWeb) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        print('[HomePage] Build - Utilisateur connecté: ${user?.email ?? "null"}');
      } catch (e) {
        print('[HomePage] ⚠️ Impossible d\'accéder à Firebase sur mobile: $e');
      }

      // Vérification du Bloc
      try {
        final bloc = context.read<BirthdayBloc>();
        print('[HomePage] Bloc disponible: $bloc');
      } catch (e) {
        print('[HomePage] ⚠️ Bloc non disponible: $e');
      }
    }

    return Scaffold(
      // AJOUT: Utiliser AppBar au lieu de CustomAppBar pour le web
      appBar: kIsWeb ? _buildWebAppBar(context) : CustomAppBar(
        title: 'Birthday Reminder',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-birthday');
        },
        child: const Icon(Icons.add),
      ),
      drawer: _buildDrawer(context),
    );
  }

  // AJOUT: AppBar spécifique pour le web
  AppBar _buildWebAppBar(BuildContext context) {
    User? user;

    // IMPORTANT: Récupérer l'utilisateur UNIQUEMENT sur web
    if (kIsWeb) {
      try {
        user = FirebaseAuth.instance.currentUser;
      } catch (e) {
        print('[AppBar] Erreur Firebase: $e');
      }
    }

    return AppBar(
      title: const Text('Birthday Reminder'),
      actions: [
        // Affichage de l'utilisateur connecté UNIQUEMENT sur web
        if (kIsWeb && user != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Text(
                  user.email!.split('@')[0],
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    user.email![0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
        // Bouton de déconnexion UNIQUEMENT pour le web
        if (kIsWeb)
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () async {
              try {
                print('[HomePage] Déconnexion manuelle demandée');
                await FirebaseAuth.instance.signOut();
                print('✅ Déconnexion réussie');
                // La navigation sera gérée par le StreamBuilder dans main.dart
              } catch (e) {
                print('❌ Erreur de déconnexion: $e');
              }
            },
          ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            Navigator.pushNamed(context, '/settings');
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    // AJOUT: Vérification si le Bloc est disponible
    try {
      context.read<BirthdayBloc>();
    } catch (e) {
      print('[HomePage] ⚠️ Bloc non accessible: $e');

      // Fallback pour le web: écran simple sans Bloc
      if (kIsWeb) {
        return _buildWebFallback(context);
      }
    }

    // Version normale avec BlocConsumer (fonctionne pour web ET mobile)
    return BlocConsumer<BirthdayBloc, BirthdayState>(
      listener: (context, state) {
        if (state is BirthdayError) {
          print('[HomePage] Erreur Bloc: ${state.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        print('[HomePage] État du Bloc: ${state.runtimeType}');

        if (state is BirthdayLoading) {
          return const LoadingWidget(message: 'Chargement des anniversaires...');
        } else if (state is BirthdayLoaded) {
          return _buildContent(context, state.birthdays);
        } else if (state is BirthdayError) {
          return ErrorDisplayWidget(
            message: state.message,
            onRetry: () {
              context.read<BirthdayBloc>().add(LoadBirthdaysEvent());
            },
          );
        }

        // État initial ou autre
        return _buildInitialState(context);
      },
    );
  }

  // AJOUT: État initial/fallback
  Widget _buildInitialState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cake, size: 64, color: Colors.blue),
          const SizedBox(height: 20),
          Text(
            kIsWeb ? 'Bienvenue sur Birthday Reminder!' : 'Aucun anniversaire enregistré',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          // Affichage info connexion UNIQUEMENT sur web
          if (kIsWeb) ...[
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    'Connecté en tant que: ${snapshot.data!.email}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Les données sont synchronisées avec Firebase',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              try {
                context.read<BirthdayBloc>().add(LoadBirthdaysEvent());
              } catch (e) {
                print('Impossible de charger: $e');
              }
            },
            child: const Text('Charger les anniversaires'),
          ),
        ],
      ),
    );
  }

  // AJOUT: Fallback spécifique pour le web
  Widget _buildWebFallback(BuildContext context) {
    User? user;

    // Récupérer l'utilisateur UNIQUEMENT sur web
    if (kIsWeb) {
      try {
        user = FirebaseAuth.instance.currentUser;
      } catch (e) {
        print('[Fallback] Erreur Firebase: $e');
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_sync, size: 80, color: Colors.blue),
          const SizedBox(height: 20),
          const Text(
            'Version Web',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // Afficher info utilisateur UNIQUEMENT sur web
          if (kIsWeb && user != null) ...[
            Text(
              'Connecté: ${user.email}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Le système de gestion d\'anniversaires\nest synchronisé avec Firebase',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              // Essayer de recharger le Bloc
              try {
                context.read<BirthdayBloc>().add(LoadBirthdaysEvent());
              } catch (e) {
                print('Bloc inaccessible: $e');
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Actualiser'),
          ),
        ],
      ),
    );
  }

  // VOTRE CODE EXISTANT POUR LE CONTENU
  Widget _buildContent(BuildContext context, List<BirthdayEntity> birthdays) {
    final upcomingBirthdays = birthdays
        .where((birthday) => birthday.daysUntilNextBirthday <= 30)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.cake,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Vue d\'ensemble',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        context,
                        'Total',
                        birthdays.length.toString(),
                        Icons.people,
                      ),
                      _buildStatCard(
                        context,
                        'À venir (30j)',
                        upcomingBirthdays.length.toString(),
                        Icons.event_available,
                      ),
                      _buildStatCard(
                        context,
                        'Aujourd\'hui',
                        birthdays
                            .where((b) => b.daysUntilNextBirthday == 0)
                            .length
                            .toString(),
                        Icons.today,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          UpcomingBirthdaysWidget(birthdays: upcomingBirthdays),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Actions rapides',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.5,
                    children: [
                      _buildQuickAction(
                        context,
                        'Ajouter un anniversaire',
                        Icons.add_circle,
                        Colors.green,
                            () {
                          Navigator.pushNamed(context, '/add-birthday');
                        },
                      ),
                      _buildQuickAction(
                        context,
                        'Voir tous',
                        Icons.list,
                        Colors.blue,
                            () {
                          Navigator.pushNamed(context, '/list-birthdays');
                        },
                      ),
                      _buildQuickAction(
                        context,
                        'Paramètres',
                        Icons.settings,
                        Colors.orange,
                            () {
                          Navigator.pushNamed(context, '/settings');
                        },
                      ),
                      _buildQuickAction(
                        context,
                        'Aide',
                        Icons.help,
                        Colors.purple,
                            () {
                          // Naviguer vers l'aide
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // VOTRE CODE EXISTANT POUR LES MÉTHODES AUXILIAIRES
  Widget _buildStatCard(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      ) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildQuickAction(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // AJOUT: Drawer adapté pour le web (CORRIGÉ)
  Drawer _buildDrawer(BuildContext context) {
    User? user;

    // IMPORTANT: Récupérer l'utilisateur UNIQUEMENT sur web
    if (kIsWeb) {
      try {
        user = FirebaseAuth.instance.currentUser;
      } catch (e) {
        print('[Drawer] Erreur Firebase: $e');
      }
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.cake,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Birthday Reminder',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                // CORRECTION: Afficher email UNIQUEMENT sur web avec utilisateur
                if (kIsWeb && user != null)
                  Text(
                    user.email!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  )
                else
                  const Text(
                    'Ne ratez aucun anniversaire',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Accueil'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Tous les anniversaires'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/list-birthdays');
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              Navigator.pop(context);
              // Naviguer vers les paramètres de notification
            },
          ),
          const Divider(),
          if (kIsWeb) ...[
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Mon compte'),
              onTap: () {
                Navigator.pop(context);
                // Naviguer vers gestion de compte
              },
            ),
          ],
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Aide'),
            onTap: () {
              Navigator.pop(context);
              // Naviguer vers l'aide
            },
          ),
          // Bouton déconnexion UNIQUEMENT sur web
          if (kIsWeb) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                print('[Drawer] Déconnexion demandée');
                try {
                  await FirebaseAuth.instance.signOut();
                } catch (e) {
                  print('Erreur déconnexion: $e');
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}