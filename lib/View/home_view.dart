import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ViewModel/Services/home_viewmodel.dart';
import '../Model/student.dart';
import 'package:student_management/Utils/Routes/app_routes.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            tooltip: 'Manage Students',
            icon: const Icon(Icons.manage_accounts),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.studentManage),
          ),
          IconButton(
            tooltip: 'Manage Majors',
            icon: const Icon(Icons.school),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.majorManage),
          ),
        ],
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Text('Error: ${viewModel.errorMessage}'),
            );
          }

          return ListView.builder(
            itemCount: viewModel.students.length,
            itemBuilder: (context, index) {
              final student = viewModel.students[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(student.fullName.isNotEmpty ? student.fullName[0].toUpperCase() : '?'),
                  ),
                  title: Text(student.fullName),
                  subtitle: Text('${student.phoneNumber ?? ''}\nMajor: ${student.majorID}'),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      if (student.id == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cannot delete student without ID')),
                        );
                        return;
                      }
                      viewModel.removeStudent(student.id!);
                    },
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Selected: ${student.fullName}')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final viewModel = Provider.of<HomeViewModel>(context, listen: false);
          final newStudent = Student(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            fullName: 'New Student ${viewModel.students.length + 1}',
            majorID: 'SE18',
            phoneNumber: '0${viewModel.students.length + 1}00000000',
          );
          viewModel.addStudent(newStudent);
        },
        tooltip: 'Add Student',
        child: const Icon(Icons.add),
      ),
    );
  }
}
