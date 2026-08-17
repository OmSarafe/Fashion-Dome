import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapAddressSelection {
  const MapAddressSelection({required this.location, required this.address});

  final LatLng location;
  final String address;
}

class MapAddressPickerPage extends StatefulWidget {
  const MapAddressPickerPage({super.key, this.initialLocation});

  final LatLng? initialLocation;

  @override
  State<MapAddressPickerPage> createState() => _MapAddressPickerPageState();
}

class _MapAddressPickerPageState extends State<MapAddressPickerPage> {
  static const _greenwich = LatLng(51.4826, -0.0077);
  late LatLng _selectedLocation;
  GoogleMapController? _mapController;
  bool _isFindingAddress = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation ?? _greenwich;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose delivery location')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: widget.initialLocation == null ? 11 : 16,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('delivery-location'),
                position: _selectedLocation,
              ),
            },
            onTap: (location) {
              setState(() => _selectedLocation = location);
            },
            onMapCreated: (controller) => _mapController = controller,
            mapToolbarEnabled: false,
            zoomControlsEnabled: false,
            zoomGesturesEnabled: true,
            scrollGesturesEnabled: true,
            myLocationButtonEnabled: false,
            padding: const EdgeInsets.only(top: 90, bottom: 170),
          ),
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(
                      Icons.touch_app_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Tap the map to place your delivery pin',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 162,
            child: Column(
              children: [
                _MapControlButton(
                  icon: Icons.add,
                  tooltip: 'Zoom in',
                  onPressed: () => _mapController?.animateCamera(
                    CameraUpdate.zoomIn(),
                  ),
                ),
                const SizedBox(height: 8),
                _MapControlButton(
                  icon: Icons.remove,
                  tooltip: 'Zoom out',
                  onPressed: () => _mapController?.animateCamera(
                    CameraUpdate.zoomOut(),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 14,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Selected · ${_selectedLocation.latitude.toStringAsFixed(5)}, '
                            '${_selectedLocation.longitude.toStringAsFixed(5)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _isFindingAddress ? null : _useLocation,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _isFindingAddress
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check),
                      label: Text(
                        _isFindingAddress
                            ? 'Finding address...'
                            : 'Use this location',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _useLocation() async {
    setState(() => _isFindingAddress = true);
    try {
      final placemarks = await placemarkFromCoordinates(
        _selectedLocation.latitude,
        _selectedLocation.longitude,
      ).timeout(const Duration(seconds: 8));
      final formattedAddress =
          placemarks.isEmpty ? '' : _formatAddress(placemarks.first);
      final address = formattedAddress.isEmpty
          ? _coordinateFallbackAddress()
          : formattedAddress;
      if (!mounted) return;
      Navigator.of(context).pop(
        MapAddressSelection(location: _selectedLocation, address: address),
      );
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pop(
        MapAddressSelection(
          location: _selectedLocation,
          address: _coordinateFallbackAddress(),
        ),
      );
    } finally {
      if (mounted) setState(() => _isFindingAddress = false);
    }
  }

  String _formatAddress(Placemark place) {
    final parts = <String?>[
      place.street,
      place.subLocality,
      place.locality,
      place.administrativeArea,
      place.postalCode,
      place.country,
    ];
    final uniqueParts = <String>[];
    for (final part in parts) {
      final value = part?.trim() ?? '';
      if (value.isNotEmpty && !uniqueParts.contains(value)) {
        uniqueParts.add(value);
      }
    }
    return uniqueParts.join(', ');
  }

  String _coordinateFallbackAddress() {
    return 'Selected location: '
        '${_selectedLocation.latitude.toStringAsFixed(5)}, '
        '${_selectedLocation.longitude.toStringAsFixed(5)}';
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        icon: Icon(icon),
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
