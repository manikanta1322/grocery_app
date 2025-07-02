import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:grocery_app/providers/address_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({super.key});

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  // 1. Label is now a state variable for the SegmentedButton
  String _selectedLabel = 'Home';
  final List<String> _labelOptions = ['Home', 'Work', 'Other'];

  // Form field controllers
  late final TextEditingController _addressLine1Controller;
  late final TextEditingController _areaController;
  late final TextEditingController _cityController;
  late final TextEditingController _postalCodeController;

  // Map related state
  final MapController _mapController = MapController();
  bool _isLoading = false;
  final LatLng _defaultPosition = const LatLng(51.509865, -0.118092); // London
  late LatLng _currentMapCenter;

  @override
  void initState() {
    super.initState();
    _addressLine1Controller = TextEditingController();
    _areaController = TextEditingController();
    _cityController = TextEditingController();
    _postalCodeController = TextEditingController();
    _currentMapCenter = _defaultPosition;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _determinePosition();
    });
  }

  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    setState(() => _isLoading = true);

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Location services are disabled. Please enable it.')));
      }
      setState(() => _isLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied.')));
        }
        setState(() => _isLoading = false);
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Location permissions are permanently denied.')));
      }
      setState(() => _isLoading = false);
      return;
    } 

    try {
      final position = await Geolocator.getCurrentPosition();
      final currentLatLng = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _currentMapCenter = currentLatLng;
        _mapController.move(currentLatLng, 17.0);
      });
      await _getAddressFromLatLng(currentLatLng);
    } catch (e) {
      print("Error getting location: $e");
    } finally {
       if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    setState(() => _isLoading = true);
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}');

    try {
      final response = await http.get(url, headers: {'User-Agent': 'com.example.riverpod_app'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['address'];
        if (address != null) {
          _addressLine1Controller.text = '${address['house_number'] ?? ''} ${address['road'] ?? ''}'.trim();
          _areaController.text = address['suburb'] ?? '';
          _cityController.text = address['city'] ?? address['town'] ?? address['village'] ?? '';
          _postalCodeController.text = address['postcode'] ?? '';
        }
      }
    } catch (e) {
      print("Error fetching address: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newAddress = Address(
        // 2. Get label from the state variable now
        label: _selectedLabel,
        addressLine1: _addressLine1Controller.text,
        area: _areaController.text,
        city: _cityController.text,
        postalCode: _postalCodeController.text,
      );
      ref.read(addressProvider.notifier).addAddress(newAddress);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Add New Address'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _isLoading ? null : _determinePosition,
            tooltip: 'Get Current Location',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: AbsorbPointer(
              // Disable form interaction while loading
              absorbing: _isLoading,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMapView(),
                  const SizedBox(height: 24),

                  // --- Label Selector Section ---
                  Text('Label as', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<String>(
                      segments: _labelOptions.map((label) {
                        return ButtonSegment<String>(
                          value: label,
                          label: Text(label),
                          icon: Icon(
                            label == 'Home' ? Icons.home_outlined
                                : label == 'Work' ? Icons.work_outline
                                : Icons.location_on_outlined,
                          ),
                        );
                      }).toList(),
                      selected: {_selectedLabel},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _selectedLabel = newSelection.first;
                        });
                      },
                      style: SegmentedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- Address Details Section ---
                  Text('Address Details', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _addressLine1Controller,
                    labelText: 'Door No. / Building Name',
                  ),
                  const SizedBox(height: 16),
                  _buildTextFormField(
                    controller: _areaController,
                    labelText: 'Area / Street',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextFormField(
                          controller: _cityController,
                          labelText: 'City',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextFormField(
                          controller: _postalCodeController,
                          labelText: 'Postal Code',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // --- Save Button ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save_alt_outlined),
                      label: const Text('Save Address'),
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget for beautifully styled TextFormFields
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
      validator: (v) => v!.isEmpty ? 'This field is required' : null,
    );
  }

  // Helper widget for a more attractive map view
  Widget _buildMapView() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: SizedBox(
        height: 250,
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentMapCenter,
                initialZoom: 15.0,
                onPositionChanged: (position, hasGesture) {
                  if (hasGesture) {
                    _currentMapCenter = position.center!;
                  }
                },
                onMapEvent: (event) {
                  if (event is MapEventMoveEnd) {
                    _getAddressFromLatLng(_currentMapCenter);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.riverpod_app', // IMPORTANT: Change this
                ),
              ],
            ),
            const Center(
              child: Icon(Icons.location_pin, color: Colors.red, size: 50),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}