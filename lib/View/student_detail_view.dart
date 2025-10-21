import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_management/ViewModel/Services/home_viewmodel.dart';
import 'package:student_management/Model/student.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentDetailView extends StatefulWidget {
  final Student student;

  const StudentDetailView({super.key, required this.student});

  @override
  State<StudentDetailView> createState() => _StudentDetailViewState();
}

class _StudentDetailViewState extends State<StudentDetailView> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  double? _latitude;
  double? _longitude;
  bool _isGeocoding = false;

  @override
  void initState() {
    super.initState();
    _latitude = widget.student.latitude;
    _longitude = widget.student.longitude;
    if (_latitude == null && _longitude == null && widget.student.address != null && widget.student.address!.isNotEmpty) {
      _geocodeAddress();
    }
  }

  Future<void> _geocodeAddress() async {
    setState(() {
      _isGeocoding = true;
    });
    const apiKey = 'AIzaSyCGprFnwxF0SQJvHMfoCdnso6CQ_NiSkqo'; // Replace with your actual API key
    final url = 'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(widget.student.address!)}&key=$apiKey';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        setState(() {
          _latitude = location['lat'];
          _longitude = location['lng'];
          _isGeocoding = false;
        });
      } else {
        setState(() {
          _isGeocoding = false;
        });
      }
    } else {
      setState(() {
        _isGeocoding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Detail'),
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, vm, child) {
          final majorName = vm.getMajorNameById(widget.student.majorID) ?? 'Unknown';
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: (widget.student.avatarURL?.isNotEmpty ?? false)
                        ? FileImage(File(widget.student.avatarURL!))
                        : null,
                    child: (widget.student.avatarURL?.isEmpty ?? true)
                        ? Text(
                            widget.student.fullName.isNotEmpty
                                ? widget.student.fullName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontSize: 40),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                // Full Name
                Text(
                  'Full Name: ${widget.student.fullName}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // ID
                Text(
                  'ID: ${widget.student.id ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                // Major
                Text(
                  'Major: $majorName',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                // Address
                Text(
                  'Address: ${widget.student.address ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                // Phone
                Text(
                  'Phone: ${widget.student.phoneNumber ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                // Map if coordinates available
                if (_latitude != null && _longitude != null)
                  SizedBox(
                    width: double.infinity,
                    height: 300,
                    child: GoogleMap(
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      initialCameraPosition: CameraPosition(
                        target: LatLng(_latitude!, _longitude!),
                        zoom: 15.0,
                      ),
                      markers: {
                        Marker(
                          markerId: MarkerId('studentLocation'),
                          position: LatLng(_latitude!, _longitude!),
                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                        ),
                      },
                    ),
                  ),
                if (_isGeocoding)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
