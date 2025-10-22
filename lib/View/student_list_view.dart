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
      Provider.of<SinhVienViewModel>(context, listen: false).loadAllData();
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
    
    // Kiểm tra quyền trước khi xóa - CHỈ ADMIN
    if (!authViewModel.canDeleteStudent(maSV)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chỉ Admin mới có quyền xóa sinh viên!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xác Nhận Xóa'),
          content: Text('Bạn có chắc chắn muốn xóa sinh viên "$hoTen"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final viewModel = Provider.of<SinhVienViewModel>(context, listen: false);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(dialogContext);
                
                await viewModel.deleteStudent(maSV);
                
                navigator.pop();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Xóa sinh viên thành công!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Xóa'),
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
              const Text('Cài Đặt Tài Khoản'),
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
                  userName: currentUser?.hoTen ?? '?',
                ),
                title: Text(
                  currentUser?.hoTen ?? 'N/A',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Mã SV: ${currentUser?.maSV ?? 'N/A'}'),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.edit, color: AppColors.primary),
                title: const Text('Chỉnh sửa thông tin'),
                subtitle: const Text('Cập nhật ảnh đại diện, số điện thoại,...'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _editProfile();
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.lock, color: Colors.orange),
                title: const Text('Đổi mật khẩu'),
                subtitle: const Text('Thay đổi mật khẩu đăng nhập'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _showChangePasswordDialog();
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Xóa tài khoản', style: TextStyle(color: Colors.red)),
                subtitle: const Text(
                  'Xóa vĩnh viễn thông tin và tài khoản',
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
              child: const Text('Đóng'),
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
      
      // Làm mới thông tin user sau khi chỉnh sửa
      await authViewModel.refreshCurrentUser();
      
      // Làm mới danh sách sinh viên
      if (mounted) {
        Provider.of<SinhVienViewModel>(context, listen: false).loadAllData();
      }
    }
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xác Nhận Xóa Tài Khoản'),
          content: const Text(
            'Bạn có chắc chắn muốn xóa tài khoản của mình?\n\nHành động này không thể hoàn tác!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
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
                    content: Text('Tài khoản đã bị xóa'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Xóa'),
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
          "Danh Sách Sinh Viên",
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
            tooltip: 'Đăng xuất',
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
              accountName: Text(currentUser?.hoTen ?? 'Người dùng'),
              accountEmail: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(currentUser?.maSV ?? 'N/A'),
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
                userName: currentUser?.hoTen ?? '?',
                radius: 40,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Trang chủ'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: Text(isAdmin ? 'Quản lý Ngành' : 'Danh sách Ngành'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NganhManagementView(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Cài đặt tài khoản'),
              onTap: () {
                Navigator.pop(context);
                _showAccountSettings();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                authViewModel.logout();
              },
            ),
          ],
        ),
      ),
      body: Consumer<SinhVienViewModel>(
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
                    'Đang tải dữ liệu...',
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
              title: 'Chưa có sinh viên nào',
              subtitle: 'Hãy thêm sinh viên đầu tiên',
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
                label: const Text('Thêm Sinh Viên'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            );
          }

          // Lọc bỏ ADMIN khỏi danh sách hiển thị
          var displayStudents = studentViewModel.students
              .where((student) => student.maSV != 'ADMIN')
              .toList();
          
          // Áp dụng search filter
          if (_searchQuery.isNotEmpty) {
            displayStudents = displayStudents.where((student) {
              final query = _searchQuery.toLowerCase();
              return student.hoTen.toLowerCase().contains(query) ||
                     (student.maSV?.toLowerCase().contains(query) ?? false) ||
                     (student.soDT?.toLowerCase().contains(query) ?? false);
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
                    hintText: 'Tìm kiếm theo tên, mã SV, SĐT...',
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
                            ? 'Không tìm thấy sinh viên'
                            : 'Chưa có sinh viên nào',
                        subtitle: _searchQuery.isNotEmpty
                            ? 'Thử tìm kiếm với từ khóa khác'
                            : 'Hãy thêm sinh viên đầu tiên',
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
                                label: const Text('Thêm Sinh Viên'),
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
                            final canEdit = authViewModel.canEditStudent(student.maSV ?? '');
                            final canDelete = authViewModel.canDeleteStudent(student.maSV ?? '');

                            return StudentCard(
                              student: student,
                              canEdit: canEdit,
                              canDelete: canDelete,
                              onDelete: () => _confirmDeleteStudent(student.maSV ?? '', student.hoTen),
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
                  final viewModel = Provider.of<SinhVienViewModel>(context, listen: false);
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
                label: const Text('Thêm Sinh Viên'),
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
