import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_management/ViewModel/Services/home_viewmodel.dart';
import 'package:student_management/Model/major.dart';

class MajorManagementView extends StatelessWidget {
  const MajorManagementView({super.key});

  Future<void> _showEditDialog(BuildContext context, {Major? major}) async {
    final isNew = major == null;
    final idController = TextEditingController(text: major?.id ?? '');
    final majorNameController = TextEditingController(text: major?.majorName ?? '');
    final descriptionController = TextEditingController(text: major?.description ?? '');

    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isNew ? 'Add Major' : 'Edit Major'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: idController,
                    decoration: const InputDecoration(labelText: 'ID'),
                    enabled: isNew, // Allow editing ID only for new majors
                  ),
                  TextFormField(
                    controller: majorNameController,
                    decoration: const InputDecoration(labelText: 'Major Name'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter major name' : null,
                  ),
                  TextFormField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
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
                final m = Major(
                  id: isNew ? (idController.text.trim().isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : idController.text.trim()) : major!.id,
                  majorName: majorNameController.text.trim(),
                  description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                );

                try {
                  if (isNew) {
                    await vm.addMajor(m);
                  } else {
                    await vm.updateMajor(m);
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Majors')),
      body: Consumer<HomeViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) return const Center(child: CircularProgressIndicator());
          if (vm.errorMessage != null) return Center(child: Text('Error: ${vm.errorMessage}'));

          if (vm.majors.isEmpty) {
            return const Center(child: Text('No majors found'));
          }

          return ListView.separated(
            itemCount: vm.majors.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final m = vm.majors[i];
              return ListTile(
                leading: CircleAvatar(child: Text(m.majorName.isNotEmpty ? m.majorName[0].toUpperCase() : '?')),
                title: Text(m.majorName),
                subtitle: Text(m.description ?? '-'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditDialog(context, major: m),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (dctx) => AlertDialog(
                            title: const Text('Confirm delete'),
                            content: Text('Delete ${m.majorName}?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(dctx).pop(false), child: const Text('Cancel')),
                              ElevatedButton(onPressed: () => Navigator.of(dctx).pop(true), child: const Text('Delete')),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await vm.removeMajor(m.id!);
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
