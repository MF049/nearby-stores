import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../models/store.dart';
import 'store_distance_screen.dart';

class FavoriteStoresScreen extends StatefulWidget {
  const FavoriteStoresScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteStoresScreen> createState() => _FavoriteStoresScreenState();
}

class _FavoriteStoresScreenState extends State<FavoriteStoresScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<StoreProvider>(context, listen: false).loadFavoriteStores()
    );
  }

  Future<void> _removeFromFavorites(Store store) async {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    await storeProvider.removeFromFavorites(store.id);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${store.name} removed from favorites')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    final favoriteStores = storeProvider.favoriteStores;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Stores'),
      ),
      body: storeProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoriteStores.isEmpty
              ? const Center(child: Text('No favorite stores yet'))
              : ListView.builder(
                  itemCount: favoriteStores.length,
                  itemBuilder: (context, index) {
                    final store = favoriteStores[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(store.name),
                        subtitle: Text(store.address),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeFromFavorites(store),
                              tooltip: 'Remove from Favorites',
                            ),
                            IconButton(
                              icon: const Icon(Icons.location_on, color: Colors.blue),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => StoreDistanceScreen(store: store),
                                  ),
                                );
                              },
                              tooltip: 'View Distance',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
