// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../providers/store_provider.dart';
// import '../../widgets/store_list_item.dart';

// class AllStoresScreen extends StatefulWidget {
//   const AllStoresScreen({Key? key}) : super(key: key);

//   @override
//   _AllStoresScreenState createState() => _AllStoresScreenState();
// }

// class _AllStoresScreenState extends State<AllStoresScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Load stores when the screen initializes
//     Future.microtask(() {
//       Provider.of<StoreProvider>(context, listen: false).loadStores();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<StoreProvider>(
//       builder: (context, storeProvider, child) {
//         if (storeProvider.isLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (storeProvider.error != null) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   'Error: ${storeProvider.error}',
//                   style: const TextStyle(color: Colors.red),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: () {
//                     storeProvider.loadStores();
//                   },
//                   child: const Text('Try Again'),
//                 ),
//               ],
//             ),
//           );
//         }

//         if (storeProvider.stores.isEmpty) {
//           return const Center(
//             child: Text('No stores available'),
//           );
//         }

//         return ListView.builder(
//           padding: const EdgeInsets.symmetric(vertical: 8),
//           itemCount: storeProvider.stores.length,
//           itemBuilder: (context, index) {
//             final store = storeProvider.stores[index];
//             return StoreListItem(
//               store: store,
//               onTap: () {
//                 // Navigate to store details or handle tap
//               },
//             );
//           },
//         );
//       },
//     );
//   }
// }