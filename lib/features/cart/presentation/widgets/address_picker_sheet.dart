import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// Resultado del selector de dirección.
class AddressResult {
  final String address;
  final double latitude;
  final double longitude;

  const AddressResult({
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

/// Bottom sheet con mapa interactivo para seleccionar dirección de entrega.
///
/// Usa OpenStreetMap (gratis, sin API key).
/// El usuario puede:
/// - Tocar el mapa para mover el pin
/// - Usar "Mi ubicación" para GPS
/// - Ver la dirección resuelta automáticamente
/// - Escribir/editar la dirección manualmente
class AddressPickerSheet extends StatefulWidget {
  final String? initialAddress;
  final double? initialLat;
  final double? initialLng;

  const AddressPickerSheet({
    super.key,
    this.initialAddress,
    this.initialLat,
    this.initialLng,
  });

  /// Muestra el bottom sheet y retorna el resultado.
  static Future<AddressResult?> show(
    BuildContext context, {
    String? initialAddress,
    double? initialLat,
    double? initialLng,
  }) {
    return showModalBottomSheet<AddressResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddressPickerSheet(
        initialAddress: initialAddress,
        initialLat: initialLat,
        initialLng: initialLng,
      ),
    );
  }

  @override
  State<AddressPickerSheet> createState() => _AddressPickerSheetState();
}

class _AddressPickerSheetState extends State<AddressPickerSheet> {
  // Default: Maracay, Venezuela
  static const _defaultLat = 10.2442;
  static const _defaultLng = -67.5957;

  late final MapController _mapCtrl;
  late final TextEditingController _addressCtrl;
  late LatLng _selectedPoint;
  bool _isLocating = false;
  bool _isResolving = false;

  @override
  void initState() {
    super.initState();
    _mapCtrl = MapController();
    _addressCtrl = TextEditingController(text: widget.initialAddress ?? '');
    _selectedPoint = LatLng(
      widget.initialLat ?? _defaultLat,
      widget.initialLng ?? _defaultLng,
    );
  }

  @override
  void dispose() {
    _mapCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  /// Reverse geocode using Nominatim (free, no key).
  Future<void> _reverseGeocode(LatLng point) async {
    setState(() => _isResolving = true);
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=${point.latitude}&lon=${point.longitude}&format=json&addressdetails=1',
      );
      final resp = await http.get(url, headers: {
        'User-Agent': 'ALONZO-App/1.0',
        'Accept-Language': 'es',
      });
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final display = data['display_name'] as String? ?? '';
        if (display.isNotEmpty && mounted) {
          _addressCtrl.text = display;
        }
      }
    } catch (_) {
      // Silently fail — user can type manually
    } finally {
      if (mounted) setState(() => _isResolving = false);
    }
  }

  /// Get current location via GPS.
  Future<void> _getCurrentLocation() async {
    setState(() => _isLocating = true);
    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Permiso de ubicación denegado')),
            );
          }
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Habilita la ubicación en los ajustes del dispositivo'),
            ),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final point = LatLng(position.latitude, position.longitude);
      setState(() => _selectedPoint = point);
      _mapCtrl.move(point, 16);
      await _reverseGeocode(point);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener ubicación: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() => _selectedPoint = point);
    _reverseGeocode(point);
  }

  void _confirm() {
    final address = _addressCtrl.text.trim();
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe o selecciona una dirección')),
      );
      return;
    }
    Navigator.of(context).pop(AddressResult(
      address: address,
      latitude: _selectedPoint.latitude,
      longitude: _selectedPoint.longitude,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: [
          // ── Handle ──
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 20),
                const SizedBox(width: 8),
                Text(
                  'SELECCIONAR DIRECCIÓN',
                  style: theme.textTheme.labelLarge?.copyWith(letterSpacing: 2),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // ── Map ──
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapCtrl,
                  options: MapOptions(
                    initialCenter: _selectedPoint,
                    initialZoom: 14,
                    onTap: _onMapTap,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.alonzo.alonzoapp',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedPoint,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_pin,
                            color: Colors.black,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // ── My location button ──
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: GestureDetector(
                    onTap: _isLocating ? null : _getCurrentLocation,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _isLocating
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location, size: 20),
                    ),
                  ),
                ),

                // ── Resolving indicator ──
                if (_isResolving)
                  Positioned(
                    top: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Buscando dirección...',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Address input + confirm ──
          Container(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottomPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200, width: 0.5),
              ),
            ),
            child: Column(
              children: [
                // Address text field
                TextFormField(
                  controller: _addressCtrl,
                  maxLines: 2,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Escribe tu dirección aquí...',
                    prefixIcon: const Icon(Icons.edit_location_alt_outlined, size: 18),
                    suffixIcon: _addressCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 16),
                            onPressed: () {
                              _addressCtrl.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black, width: 1.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),

                // Coordinates info
                Text(
                  '${_selectedPoint.latitude.toStringAsFixed(5)}, ${_selectedPoint.longitude.toStringAsFixed(5)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade500,
                    fontFamily: 'monospace',
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 12),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addressCtrl.text.trim().isNotEmpty ? _confirm : null,
                    child: const Text('CONFIRMAR DIRECCIÓN'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
