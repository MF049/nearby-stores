import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:store_finder/models/store.dart';
import 'package:store_finder/providers/auth_provider.dart';
import 'package:store_finder/providers/location_provider.dart';
import 'package:store_finder/providers/store_provider.dart';
import 'package:store_finder/screens/favorite_stores_screen.dart';
import 'package:store_finder/screens/login_screen.dart';
import 'package:store_finder/screens/signup_screen.dart';
import 'package:store_finder/screens/store_distance_screen.dart';
import 'package:store_finder/screens/home_screen.dart';
import 'package:store_finder/screens/store_list.dart';
import 'package:store_finder/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbService = DatabaseService.instance;
  if (await dbService.isDatabaseEmpty()) {
    await dbService.initializeDatabase();
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StoreProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isAuthenticated) {
      return const StoreListScreen();
    } else {
      return const LoginScreen();
      //return const HomeScreen();
    }
  }
}
