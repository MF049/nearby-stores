import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/store_provider.dart';
import '../providers/auth_provider.dart';
import '../models/store.dart';
import 'login_screen.dart';
import 'favorite_stores_screen.dart';
import 'store_distance_screen.dart';

class StoreListScreen extends StatefulWidget {
  const StoreListScreen({Key? key}) : super(key: key);

  @override
  State<StoreListScreen> createState() => _StoreListScreenState();
}

class _StoreListScreenState extends State<StoreListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<StoreProvider>(context, listen: false).loadStores()
    );
  }

  Future<void> _addSampleStores() async {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    
    await storeProvider.addStore(Store(
      id: '1',
      name: 'Supermarket A',
      address: '123 Main St, City',
      latitude: 40.7128,
      longitude: -74.0060,
    ));
    
    await storeProvider.addStore(Store(
      id: '2',
      name: 'Grocery Store B',
      address: '456 Park Ave, City',
      latitude: 40.7143,
      longitude: -73.9956,
    ));
    
    await storeProvider.addStore(Store(
      id: '3',
      name: 'Market C',
      address: '789 Broadway, City',
      latitude: 40.7112,
      longitude: -74.0024,
    ));
  }

  Future<void> _addToFavorites(Store store) async {
    final storeProvider = Provider.of<StoreProvider>(context, listen: false);
    await storeProvider.addToFavorites(store);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${store.name} added to favorites')),
      );
    }
  }

  void _logout() {
    Provider.of<AuthProvider>(context, listen: false).logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeProvider = Provider.of<StoreProvider>(context);
    final stores = storeProvider.stores;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Stores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const FavoriteStoresScreen()),
              );
            },
            tooltip: 'View Favorites',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: storeProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : stores.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No stores available'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _addSampleStores,
                        child: const Text('Add Sample Stores'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: stores.length,
                  itemBuilder: (context, index) {
                    final store = stores[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: ListTile(
                        title: Text(store.name),
                        subtitle: Text(store.address),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.star_border, color: Colors.amber),
                              onPressed: () => _addToFavorites(store),
                              tooltip: 'Add to Favorites',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddStoreDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddStoreDialog extends StatefulWidget {
  const AddStoreDialog({Key? key}) : super(key: key);

  @override
  State<AddStoreDialog> createState() => _AddStoreDialogState();
}

class _AddStoreDialogState extends State<AddStoreDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      final storeProvider = Provider.of<StoreProvider>(context, listen: false);
      
      final store = Store(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        address: _addressController.text,
        latitude: double.parse(_latitudeController.text),
        longitude: double.parse(_longitudeController.text),
      );
      
      await storeProvider.addStore(store);
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${store.name} added successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Store'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Store Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter store name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _latitudeController,
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter latitude';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _longitudeController,
                decoration: const InputDecoration(labelText: 'Longitude'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter longitude';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
