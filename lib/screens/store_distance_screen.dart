import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';

class StoreDistanceScreen extends StatelessWidget {
  const StoreDistanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Distance to Stores'),
      ),
      body: Consumer<StoreProvider>(
        builder: (context, storeProvider, child) {
          final favoriteStores = storeProvider.favoriteStores;

          if (favoriteStores.isEmpty) {
            return const Center(
              child: Text('No favorite stores to calculate distance'),
            );
          }

          return ListView.builder(
            itemCount: favoriteStores.length,
            itemBuilder: (context, index) {
              final store = favoriteStores[index];
              return FutureBuilder<Map<String, dynamic>>(
                future: storeProvider.getDistanceToStore(store),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text(store.name),
                      subtitle: const Text('Calculating distance...'),
                      trailing: const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return ListTile(
                      title: Text(store.name),
                      subtitle: Text('Error: ${snapshot.error}'),
                      trailing: const Icon(Icons.error, color: Colors.red),
                    );
                  }

                  final data = snapshot.data!;
                  final straightDistance = data['straight_distance'] as double;
                  final sphericalDistance = data['spherical_distance'] as double;
                  final direction = data['direction'] as String;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            store.address,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Direct Distance:',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    '${straightDistance.toStringAsFixed(2)} km',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Road Distance:',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    '${sphericalDistance.toStringAsFixed(2)} km',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Direction:',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    direction,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
} 