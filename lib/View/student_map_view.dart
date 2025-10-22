import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import '../../Utils/app_colors.dart';

class StudentMapView extends StatefulWidget {
  final String address;

  const StudentMapView({super.key, required this.address});

  @override
  State<StudentMapView> createState() => _StudentMapViewState();
}

class _StudentMapViewState extends State<StudentMapView> {
  final MapController _mapController = MapController();
  LatLng? _studentLocation;
  bool _isLoading = true;
  String? _errorMessage;
  bool _showInfo = true;
  
  String _selectedMapStyle = 'standard';
  final Map<String, Map<String, String>> _mapStyles = {
    'standard': {
      'name': 'Standard',
      'url': 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    },
    'satellite': {
      'name': 'Satellite',
      'url': 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    }
  };

  @override
  void initState() {
    super.initState();
    _geocodeAddress();
  }

  Future<void> _geocodeAddress() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<Location> locations = await locationFromAddress(widget.address);
      
      if (locations.isNotEmpty) {
        setState(() {
          _studentLocation = LatLng(
            locations.first.latitude,
            locations.first.longitude,
          );
          _isLoading = false;
        });

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && _studentLocation != null) {
            _mapController.move(_studentLocation!, 15.0);
          }
        });
      } else {
        setState(() {
          _errorMessage = 'Location not found for this address';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to search address: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, currentZoom - 1);
  }

  void _recenterMap() {
    if (_studentLocation != null) {
      _mapController.move(_studentLocation!, 15.0);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Student Location',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: AppColors.primaryDark,
        actions: [
          if (!_isLoading && _errorMessage == null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.layers),
              tooltip: 'Choose map style',
              onSelected: (value) {
                setState(() {
                  _selectedMapStyle = value;
                });
              },
              itemBuilder: (context) => _mapStyles.entries.map((entry) {
                return PopupMenuItem<String>(
                  value: entry.key,
                  child: Row(
                    children: [
                      Icon(
                        _selectedMapStyle == entry.key
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(entry.value['name']!),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      Icon(
                        Icons.location_searching,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Searching for location...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.address,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_off,
                            size: 80,
                            color: Colors.red.shade400,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Location not found',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: _geocodeAddress,
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: const Text(
                            'Retry',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _studentLocation == null
                  ? const Center(
                      child: Text('Location not found'),
                    )
                  : Stack(
                      children: [
                        // Map
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _studentLocation!,
                            initialZoom: 15.0,
                            minZoom: 5.0,
                            maxZoom: 18.0,
                          ),
                          children: [
                            // Tile Layer
                            TileLayer(
                              urlTemplate: _mapStyles[_selectedMapStyle]!['url']!,
                              userAgentPackageName: 'com.example.student_manager',
                              maxZoom: 19,
                            ),
                            
                            // Circle Layer (Highlight area)
                            CircleLayer(
                              circles: [
                                CircleMarker(
                                  point: _studentLocation!,
                                  radius: 100,
                                  useRadiusInMeter: true,
                                  color: Colors.blue.withOpacity(0.1),
                                  borderColor: Colors.blue.withOpacity(0.3),
                                  borderStrokeWidth: 2,
                                ),
                              ],
                            ),
                            
                            // Marker Layer
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _studentLocation!,
                                  width: 120,
                                  height: 120,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              AppColors.primary,
                                              AppColors.primaryLight,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.blue.withOpacity(0.4),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.school,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            const Text(
                                              'Student',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.location_on,
                                          color: AppColors.primary,
                                          size: 36,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Floating Info Card
                        if (_showInfo)
                          Positioned(
                            top: 16,
                            left: 16,
                            right: 16,
                            child: Material(
                              elevation: 8,
                              borderRadius: BorderRadius.circular(16),
                              shadowColor: Colors.black.withOpacity(0.3),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.blue.shade50,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.blue.shade100,
                                    width: 1,
                                  ),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppColors.primaryLight,
                                                AppColors.primary,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.location_on,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Expanded(
                                          child: Text(
                                            'Address',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Color(0xFF2C3E50),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close, size: 20),
                                          onPressed: () {
                                            setState(() {
                                              _showInfo = false;
                                            });
                                          },
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.address,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              height: 1.4,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Divider(color: Colors.grey.shade200),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.my_location,
                                                size: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  '${_studentLocation!.latitude.toStringAsFixed(6)}, ${_studentLocation!.longitude.toStringAsFixed(6)}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade600,
                                                    fontFamily: 'monospace',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        // Zoom Controls
                        Positioned(
                          right: 16,
                          bottom: 100,
                          child: Column(
                            children: [
                              _buildControlButton(
                                icon: Icons.add,
                                onPressed: _zoomIn,
                                tooltip: 'Zoom in',
                              ),
                              const SizedBox(height: 8),
                              _buildControlButton(
                                icon: Icons.remove,
                                onPressed: _zoomOut,
                                tooltip: 'Zoom out',
                              ),
                            ],
                          ),
                        ),

                        // Recenter Button
                        Positioned(
                          right: 16,
                          bottom: 32,
                          child: _buildControlButton(
                            icon: Icons.my_location,
                            onPressed: _recenterMap,
                            tooltip: 'Recenter',
                            color: AppColors.primary,
                          ),
                        ),

                        // Toggle Info Button
                        if (!_showInfo)
                          Positioned(
                            top: 16,
                            right: 16,
                            child: _buildControlButton(
                              icon: Icons.info_outline,
                              onPressed: () {
                                setState(() {
                                  _showInfo = true;
                                });
                              },
                              tooltip: 'Show info',
                            ),
                          ),
                      ],
                    ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    Color? color,
  }) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      shadowColor: Colors.black.withOpacity(0.3),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color ?? Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color != null ? color.withOpacity(0.3) : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: color != null ? Colors.white : Colors.grey.shade700,
            size: 24,
          ),
        ),
      ),
    );
  }
}
