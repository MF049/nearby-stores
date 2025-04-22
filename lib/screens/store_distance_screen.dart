import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/store.dart';
import '../providers/location_provider.dart';

class StoreDistanceScreen extends StatefulWidget {
  final Store store;

  const StoreDistanceScreen({
    Key? key,
    required this.store,
  }) : super(key: key);

  @override
  State<StoreDistanceScreen> createState() => _StoreDistanceScreenState();
}

class _StoreDistanceScreenState extends State<StoreDistanceScreen> {
  double? _distance;
  bool _isLoading = false;
  String? _errorMessage;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndCalculateDistance();
  }

  Future<void> _getCurrentLocationAndCalculateDistance() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get current location
      final locationProvider =
          Provider.of<LocationProvider>(context, listen: false);
      await locationProvider.getCurrentLocation();
      _currentPosition = locationProvider.currentPosition;

      if (_currentPosition == null) {
        throw Exception('Could not determine current location');
      }

      // Calculate distance via API
      await _calculateDistanceViaAPI();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to calculate distance: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _calculateDistanceViaAPI() async {
    try {
      final response = await http.get(Uri.parse(
          //if running locally, replace with your machines ip addreess; command on cmd: ipconfig
          'http://192.168.1.199:5000/api/distance?'
          //'start_lat=${_currentPosition!.latitude}&' //gets a constant location while in development
          //'start_lon=${_currentPosition!.longitude}&' //cannot be used with API
          'start_lat=30.030858&'
          'start_lon=31.209591&'
          'end_lat=${widget.store.latitude}&'
          'end_lon=${widget.store.longitude}'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _distance = data['distance']; // Assuming API returns {distance: x.xx}
          _isLoading = false;
        });
      } else {
        throw Exception(
            'API request failed with status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API call failed: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.store.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store details card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.store.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.store.address,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Store Coordinates: ${widget.store.latitude.toStringAsFixed(6)}, ${widget.store.longitude.toStringAsFixed(6)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (_currentPosition != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Your Location: ${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Distance card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Distance from your location:',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _errorMessage != null
                            ? Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              )
                            : _distance != null
                                ? Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.directions_car,
                                            size: 32,
                                            color: Colors.blue,
                                          ),
                                          const SizedBox(width: 16),
                                          Text(
                                            '${_distance!.toStringAsFixed(2)} km',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Route via API calculation',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  )
                                : const Text('Distance not available'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Refresh button
            Center(
              child: ElevatedButton.icon(
                onPressed: _getCurrentLocationAndCalculateDistance,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Distance'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
