import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_management/ViewModel/Services/home_viewmodel.dart';
import 'package:student_management/Model/student.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class StudentManagementView extends StatelessWidget {
  const StudentManagementView({super.key});

  Future<void> _showEditDialog(BuildContext context, {Student? student}) async {
    final isNew = student == null;
    final idController = TextEditingController(text: student?.id ?? '');
    final fullNameController = TextEditingController(text: student?.fullName ?? '');
    // We no longer use a plain text controller for major; use selectedMajorId instead
    String? selectedMajorId = student?.majorID;
    final addressController = TextEditingController(text: student?.address ?? '');
    final phoneController = TextEditingController(text: student?.phoneNumber ?? '');

    String? avatarURL = student?.avatarURL;

    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Consumer<HomeViewModel>(builder: (c, vm, _) {
              final majors = vm.majors;
              return AlertDialog(
                title: Text(isNew ? 'Add Student' : 'Edit Student'),
                content: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Avatar section
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: (avatarURL?.isNotEmpty ?? false)
                                  ? FileImage(File(avatarURL!))
                                  : null,
                              child: (avatarURL?.isEmpty ?? true)
                                  ? const Icon(Icons.person, size: 30)
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final picker = ImagePicker();
                                final pickedFile = await picker.pickImage(source: ImageSource.camera);
                                if (pickedFile != null) {
                                  final directory = await getApplicationDocumentsDirectory();
                                  final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
                                  final savedImage = await File(pickedFile.path).copy('${directory.path}/$fileName');
                                  setState(() {
                                    avatarURL = savedImage.path;
                                  });
                                }
                              },
                              icon: const Icon(Icons.camera),
                              label: const Text('Take Photo'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: idController,
                          decoration: const InputDecoration(labelText: 'ID'),
                          enabled: isNew, // Allow editing ID only for new students
                        ),
                        TextFormField(
                          controller: fullNameController,
                          decoration: const InputDecoration(labelText: 'Full Name'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter full name' : null,
                        ),
                        // Dropdown for majors: displays Major.majorName but stores Major.id
                        DropdownButtonFormField<String>(
                          initialValue: selectedMajorId,
                          items: majors
                              .map((m) => DropdownMenuItem<String>(value: m.id, child: Text(m.majorName)))
                              .toList(),
                          onChanged: (v) {
                            selectedMajorId = v;
                          },
                          decoration: const InputDecoration(labelText: 'Major'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Select major' : null,
                        ),
                        TextFormField(
                          controller: addressController,
                          decoration: const InputDecoration(labelText: 'Address'),
                        ),
                        TextFormField(
                          controller: phoneController,
                          decoration: const InputDecoration(labelText: 'Phone'),
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                  ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final vm = Provider.of<HomeViewModel>(context, listen: false);
                      final s = Student(
                        id: isNew ? (idController.text.trim().isEmpty ? null : idController.text.trim()) : student?.id,
                        fullName: fullNameController.text.trim(),
                        majorID: selectedMajorId ?? '',
                        address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
                        phoneNumber: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                        avatarURL: avatarURL,
                      );

                      try {
                        if (isNew) {
                          await vm.addStudent(s);
                        } else {
                          await vm.updateStudent(s);
                        }
                        if (context.mounted) Navigator.of(ctx).pop();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      }
                    },
                    child: Text(isNew ? 'Add' : 'Save'),
                  ),
                ],
              );
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Students')),
      body: Consumer<HomeViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) return const Center(child: CircularProgressIndicator());
          if (vm.errorMessage != null) return Center(child: Text('Error: ${vm.errorMessage}'));

          if (vm.students.isEmpty) {
            return const Center(child: Text('No students found'));
          }

          return ListView.separated(
            itemCount: vm.students.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final s = vm.students[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: (s.avatarURL?.isNotEmpty ?? false)
                      ? FileImage(File(s.avatarURL!))
                      : null,
                  child: (s.avatarURL?.isEmpty ?? true)
                      ? Text(s.fullName.isNotEmpty ? s.fullName[0].toUpperCase() : '?')
                      : null,
                ),
                title: Text(s.fullName),
                subtitle: Text('Major: ${vm.getMajorNameById(s.majorID) ?? s.majorID}\nPhone: ${s.phoneNumber ?? '-'}'),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditDialog(context, student: s),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        if (s.id == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Cannot delete student without ID')),
                          );
                          return;
                        }
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (dctx) => AlertDialog(
                            title: const Text('Confirm delete'),
                            content: Text('Delete ${s.fullName}?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(dctx).pop(false), child: const Text('Cancel')),
                              ElevatedButton(onPressed: () => Navigator.of(dctx).pop(true), child: const Text('Delete')),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await vm.removeStudent(s.id!);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
