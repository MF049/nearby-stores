import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../models/store.dart';

class StoreListScreen extends StatefulWidget {
  const StoreListScreen({super.key});

  @override
  State<StoreListScreen> createState() => _StoreListScreenState();
}

class _StoreListScreenState extends State<StoreListScreen> {
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNearbyStores();
  }

  Future<void> _fetchNearbyStores() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await Provider.of<StoreProvider>(context, listen: false).fetchNearbyStores();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Stores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchNearbyStores,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: $_error',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchNearbyStores,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Consumer<StoreProvider>(
                  builder: (context, storeProvider, child) {
                    final stores = storeProvider.stores;

                    if (stores.isEmpty) {
                      return const Center(
                        child: Text('No stores found nearby'),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: _fetchNearbyStores,
                      child: ListView.builder(
                        itemCount: stores.length,
                        itemBuilder: (context, index) {
                          final store = stores[index];
                          return StoreListTile(store: store);
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

class StoreListTile extends StatelessWidget {
  final Store store;

  const StoreListTile({
    super.key,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: ListTile(
        title: Text(store.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(store.address),
            if (store.distance != null && store.direction != null)
              Text(
                '${store.distance!.toStringAsFixed(2)} km ${store.direction}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            store.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: store.isFavorite ? Colors.red : null,
          ),
          onPressed: () {
            Provider.of<StoreProvider>(context, listen: false)
                .toggleFavorite(store);
          },
        ),
      ),
    );
  }
} 