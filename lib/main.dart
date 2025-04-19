import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/store_provider.dart';
import 'screens/store_list_screen.dart';
import 'screens/favorite_stores_screen.dart';
import 'screens/add_store_screen.dart';
import 'screens/store_distance_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StoreProvider(),
      child: MaterialApp(
        title: 'Store Locator',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const StoreListScreen(),
    const FavoriteStoresScreen(),
    const AddStoreScreen(),
    const StoreDistanceScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load stores when app starts
    Future.microtask(() =>
        Provider.of<StoreProvider>(context, listen: false).loadStores());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Stores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_business),
            label: 'Add Store',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Distance',
          ),
        ],
      ),
    );
  }
} 