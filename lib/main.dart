import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_finder/models/store.dart';
import 'package:store_finder/riverpod/auth_provider.dart';
import 'package:store_finder/screens/favorite_stores_screen.dart';
import 'package:store_finder/screens/login_screen.dart';
import 'package:store_finder/screens/signup_screen.dart';
import 'package:store_finder/screens/store_distance_screen.dart';
import 'package:store_finder/screens/home_screen.dart';
import 'package:store_finder/screens/store_list.dart';
import 'package:store_finder/services/database_service.dart';

// Simple providers for backwards compatibility during transition
final authProvider = Provider<AuthNotifier>((ref) => throw UnimplementedError());
final storeProvider = Provider((ref) => throw UnimplementedError());
final locationProvider = Provider((ref) => throw UnimplementedError());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbService = DatabaseService.instance;
  if (await dbService.isDatabaseEmpty()) {
    await dbService.initializeDatabase();
  }
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Store Finder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/favorite-stores': (context) => const FavoriteStoresScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle dynamic routes like store-distance with parameters
        if (settings.name == '/store-distance') {
          final Store store = settings.arguments as Store;
          return MaterialPageRoute(
            builder: (context) => StoreDistanceScreen(store: store),
          );
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

     if (authState.isAuthenticated) {
      return const StoreListScreen();
    } else {
      return const LoginScreen();
    }
  }
}
