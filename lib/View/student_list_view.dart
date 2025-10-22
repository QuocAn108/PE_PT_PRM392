import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ViewModel/Services/auth_viewmodel.dart';
import '../../ViewModel/Services/student_viewmodel.dart';
import 'student_detail_view.dart';
import 'major_management_view.dart';
import 'widgets/change_password_dialog.dart';
import 'widgets/student_card.dart';
import 'widgets/user_avatar.dart';
import 'widgets/empty_state.dart';
import '../../Utils/app_colors.dart';

class StudentListView extends StatefulWidget {
  const StudentListView({super.key});

  @override
  State<StudentListView> createState() => _StudentListViewState();
}

class _StudentListViewState extends State<StudentListView> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );
    _fabAnimationController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentViewmodel>(context, listen: false).loadAllData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _confirmDeleteStudent(String maSV, String hoTen) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    
    // Check permission before deleting - ONLY ADMIN
    if (!authViewModel.canDeleteStudent(maSV)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only admins can delete students!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete student "${hoTen}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final viewModel = Provider.of<StudentViewmodel>(context, listen: false);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(dialogContext);
                
                await viewModel.deleteStudent(maSV);
                
                navigator.pop();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Student deleted successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showAccountSettings() {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final currentUser = authViewModel.currentSinhvien;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.settings, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('Account Settings'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: UserAvatar(
                  avatarPath: currentUser?.avatarPath,
                  userName: currentUser?.full_name ?? '?',
                ),
                title: Text(
                  currentUser?.full_name ?? 'N/A',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('ID: ${currentUser?.studentId ?? 'N/A'}'),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.edit, color: AppColors.primary),
                title: const Text('Edit profile'),
                subtitle: const Text('Update avatar, phone number, ...'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _editProfile();
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.lock, color: Colors.orange),
                title: const Text('Change password'),
                subtitle: const Text('Change account password'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _showChangePasswordDialog();
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Delete account', style: TextStyle(color: Colors.red)),
                subtitle: const Text(
                  'Permanently delete account and data',
                  style: TextStyle(fontSize: 11),
                ),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _confirmDeleteAccount();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => ChangePasswordDialog(),
    );
  }

  void _editProfile() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final currentUser = authViewModel.currentSinhvien;

    if (currentUser != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudentDetailView(student: currentUser),
        ),
      );
      
      // Refresh user info after editing
      await authViewModel.refreshCurrentUser();
      
      // Refresh student list
      if (mounted) {
        Provider.of<StudentViewmodel>(context, listen: false).loadAllData();
      }
    }
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Account Deletion'),
          content: const Text(
            'Are you sure you want to delete your account?\n\nThis action cannot be undone!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(dialogContext);
                
                await authViewModel.deleteAccount();
                
                navigator.pop();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Account deleted'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final currentUser = authViewModel.currentSinhvien;
    final isAdmin = authViewModel.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Student List",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authViewModel.logout();
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
              ),
              accountName: Text(currentUser?.full_name ?? 'User'),
              accountEmail: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(currentUser?.studentId ?? 'N/A'),
                  if (isAdmin)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'ADMIN',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              currentAccountPicture: UserAvatar(
                avatarPath: currentUser?.avatarPath,
                userName: currentUser?.full_name ?? '?',
                radius: 40,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: Text(isAdmin ? 'Manage Majors' : 'Major List'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MajorManagementView(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Account Settings'),
              onTap: () {
                Navigator.pop(context);
                _showAccountSettings();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                authViewModel.logout();
              },
            ),
          ],
        ),
      ),
      body: Consumer<StudentViewmodel>(
        builder: (context, studentViewModel, child) {
          if (studentViewModel.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryDark),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading data...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          if (studentViewModel.students.isEmpty) {
            return EmptyState(
              icon: Icons.people_outline,
              title: 'No students yet',
              subtitle: 'Add the first student',
              iconColor: AppColors.primaryLight,
              action: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StudentDetailView(student: null),
                    ),
                  ).then((_) => studentViewModel.loadAllData());
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Student'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            );
          }

          // Filter out ADMIN from display list
          var displayStudents = studentViewModel.students
              .where((student) => student.studentId != 'ADMIN')
              .toList();
          
          // Apply search filter
          if (_searchQuery.isNotEmpty) {
            displayStudents = displayStudents.where((student) {
              final query = _searchQuery.toLowerCase();
              return student.full_name.toLowerCase().contains(query) ||
                     (student.studentId?.toLowerCase().contains(query) ?? false) ||
                     (student.phone_number?.toLowerCase().contains(query) ?? false);
            }).toList();
          }

          return Column(
            children: [
              // Search Bar
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by name, ID, phone...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: Icon(Icons.search, color: AppColors.primaryLight),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey.shade400),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
              ),

              // Student List or Empty State
              Expanded(
                child: displayStudents.isEmpty
                    ? EmptyState(
                        icon: _searchQuery.isNotEmpty ? Icons.search_off : Icons.people_outline,
                        title: _searchQuery.isNotEmpty 
                            ? 'No students found'
                            : 'No students yet',
                        subtitle: _searchQuery.isNotEmpty
                            ? 'Try searching with different keywords'
                            : 'Add the first student',
                        iconColor: _searchQuery.isNotEmpty
                            ? Colors.orange.shade300
                            : AppColors.primaryLight,
                        action: (isAdmin && _searchQuery.isEmpty)
                            ? ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const StudentDetailView(student: null),
                                    ),
                                  ).then((_) => studentViewModel.loadAllData());
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add Student'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              )
                            : null,
                      )
                    : RefreshIndicator(
                        onRefresh: () => studentViewModel.loadAllData(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: displayStudents.length,
                          itemBuilder: (context, index) {
                            final student = displayStudents[index];
                            final canEdit = authViewModel.canEditStudent(student.studentId ?? '');
                            final canDelete = authViewModel.canDeleteStudent(student.studentId ?? '');

                            return StudentCard(
                              student: student,
                              canEdit: canEdit,
                              canDelete: canDelete,
                              onDelete: () => _confirmDeleteStudent(student.studentId ?? '', student.full_name),
                              onRefresh: () => studentViewModel.loadAllData(),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: isAdmin
          ? ScaleTransition(
              scale: _fabAnimation,
              child: FloatingActionButton.extended(
                onPressed: () {
                  final viewModel = Provider.of<StudentViewmodel>(context, listen: false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StudentDetailView(student: null),
                    ),
                  ).then((_) {
                    viewModel.loadAllData();
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Student'),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: AppColors.primary,
              ),
            )
          : null,
    );
  }

}
