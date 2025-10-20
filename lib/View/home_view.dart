import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ViewModel/home_viewmodel.dart';
import '../Model/student.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Management'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                    child: Text(student.name[0].toUpperCase()),
                  ),
                  title: Text(student.name),
                  subtitle: Text('${student.email}\n${student.phone}'),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => viewModel.removeStudent(student.id),
                  ),
                  onTap: () {
                    // Navigate to detail view (to be implemented)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Selected: ${student.name}')),
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
          // Add new student (mock)
          final viewModel = Provider.of<HomeViewModel>(context, listen: false);
          final newStudent = Student(
            id: DateTime.now().millisecondsSinceEpoch,
            name: 'New Student ${viewModel.students.length + 1}',
            email: 'new${viewModel.students.length + 1}@example.com',
            phone: '0${viewModel.students.length + 1}00000000',
          );
          viewModel.addStudent(newStudent);
        },
        tooltip: 'Add Student',
        child: const Icon(Icons.add),
      ),
    );
  }
}
