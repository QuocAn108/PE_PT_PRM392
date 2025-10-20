import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_management/ViewModel/Services/home_viewmodel.dart';
import 'package:student_management/Model/student.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:io';

class StudentDetailView extends StatelessWidget {
  final Student student;

  const StudentDetailView({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Detail'),
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, vm, child) {
          final majorName = vm.getMajorNameById(student.majorID) ?? 'Unknown';
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: (student.avatarURL?.isNotEmpty ?? false)
                        ? FileImage(File(student.avatarURL!))
                        : null,
                    child: (student.avatarURL?.isEmpty ?? true)
                        ? Text(
                            student.fullName.isNotEmpty
                                ? student.fullName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontSize: 40),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),
                // Full Name
                Text(
                  'Full Name: ${student.fullName}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // ID
                Text(
                  'ID: ${student.id ?? 'N/A'}',
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
                  'Address: ${student.address ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                // Phone
                Text(
                  'Phone: ${student.phoneNumber ?? 'N/A'}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                // Map if coordinates available
                if (student.latitude != null && student.longitude != null)
                  SizedBox(
                    width: double.infinity,
                    height: 300,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(student.latitude!, student.longitude!),
                        initialZoom: 15.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(student.latitude!, student.longitude!),
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
