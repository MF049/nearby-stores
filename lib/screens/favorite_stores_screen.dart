import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';

class FavoriteStoresScreen extends StatelessWidget {
  const FavoriteStoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Stores'),
      ),
      body: Consumer<StoreProvider>(
        builder: (context, storeProvider, child) {
          final favoriteStores = storeProvider.favoriteStores;
          
          if (favoriteStores.isEmpty) {
            return const Center(
              child: Text('No favorite stores yet'),
            );
          }

          return ListView.builder(
            itemCount: favoriteStores.length,
            itemBuilder: (context, index) {
              final store = favoriteStores[index];
              return ListTile(
                title: Text(store.name),
                subtitle: Text(store.address),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    Provider.of<StoreProvider>(context, listen: false)
                        .toggleFavorite(store);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
} 