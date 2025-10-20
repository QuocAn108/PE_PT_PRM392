import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_management/ViewModel/Services/home_viewmodel.dart';
import 'package:student_management/Model/student.dart';

class StudentManagementView extends StatelessWidget {
  const StudentManagementView({super.key});

  Future<void> _showEditDialog(BuildContext context, {Student? student}) async {
    final isNew = student == null;
    final fullNameController = TextEditingController(text: student?.fullName ?? '');
    final majorController = TextEditingController(text: student?.majorID ?? '');
    final addressController = TextEditingController(text: student?.address ?? '');
    final phoneController = TextEditingController(text: student?.phoneNumber ?? '');

    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isNew ? 'Add Student' : 'Edit Student'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: fullNameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter full name' : null,
                ),
                TextFormField(
                  controller: majorController,
                  decoration: const InputDecoration(labelText: 'Major ID'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter major' : null,
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
                id: student?.id,
                fullName: fullNameController.text.trim(),
                majorID: majorController.text.trim(),
                address: addressController.text.trim().isEmpty ? null : addressController.text.trim(),
                phoneNumber: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
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
      ),
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
                leading: CircleAvatar(child: Text(s.fullName.isNotEmpty ? s.fullName[0].toUpperCase() : '?')),
                title: Text(s.fullName),
                subtitle: Text('Major: ${s.majorID}\nPhone: ${s.phoneNumber ?? '-'}'),
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

