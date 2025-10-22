import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Model/major.dart';
import '../../ViewModel/Services/auth_viewmodel.dart';
import '../ViewModel/Services/student_viewmodel.dart';
import '../../Utils/app_colors.dart';

class MajorManagementView extends StatefulWidget {
  const MajorManagementView({super.key});

  @override
  State<MajorManagementView> createState() => _MajorManagementViewState();
}

class _MajorManagementViewState extends State<MajorManagementView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentViewmodel>(context, listen: false).fetchMajors();
    });
  }

  void _showAddEditDialog({Major? nganh}) {
    final maNganhController = TextEditingController(text: nganh?.id ?? '');
    final tenNganhController = TextEditingController(text: nganh?.name ?? '');
    final formKey = GlobalKey<FormState>();
    final isEditing = nganh != null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEditing ? 'Chỉnh Sửa Ngành' : 'Thêm Ngành Mới'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: maNganhController,
                  decoration: InputDecoration(
                    labelText: 'Mã Ngành',
                    prefixIcon: const Icon(Icons.code),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  enabled: !isEditing, // Không cho sửa mã khi edit
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Vui lòng nhập mã ngành';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: tenNganhController,
                  decoration: InputDecoration(
                    labelText: 'Tên Ngành',
                    prefixIcon: const Icon(Icons.school),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Vui lòng nhập tên ngành';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  final viewModel = Provider.of<StudentViewmodel>(context, listen: false);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(dialogContext);
                  
                  final newNganh = Major(
                    id: maNganhController.text.trim(),
                    name: tenNganhController.text.trim(),
                  );

                  try {
                    if (isEditing) {
                      await viewModel.updateNganh(newNganh);
                    } else {
                      await viewModel.addNganh(newNganh);
                    }
                    
                    navigator.pop();
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text(isEditing ? 'Cập nhật thành công!' : 'Thêm mới thành công!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(
                        content: Text('Lỗi: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: Text(isEditing ? 'Cập Nhật' : 'Thêm'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(Major major) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Xác Nhận Xóa'),
          content: Text('Bạn có chắc chắn muốn xóa ngành "${major.name}"?\n\nLưu ý: Các sinh viên thuộc ngành này sẽ có MaNganh = NULL.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final viewModel = Provider.of<StudentViewmodel>(context, listen: false);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final navigator = Navigator.of(dialogContext);
                
                await viewModel.deleteNganh(major.id);

                navigator.pop();
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Xóa thành công!'),
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

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final isAdmin = authViewModel.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Quản Lý Ngành' : 'Danh Sách Ngành'),
        elevation: 0,
      ),
      body: Consumer<StudentViewmodel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.majors.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 100,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có ngành nào',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (isAdmin) ...[
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => _showAddEditDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Thêm Ngành Đầu Tiên'),
                    ),
                  ],
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: viewModel.majors.length,
            itemBuilder: (context, index) {
              final major = viewModel.majors[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.school,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  title: Text(
                    major.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    'Mã: ${major.id}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  trailing: isAdmin
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showAddEditDialog(nganh: major),
                              tooltip: 'Chỉnh sửa',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(major),
                              tooltip: 'Xóa',
                            ),
                          ],
                        )
                      : null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showAddEditDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Thêm Ngành'),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }
}
