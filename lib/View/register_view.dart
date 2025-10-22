import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Model/student.dart';
import '../../ViewModel/Services/auth_viewmodel.dart';
import '../../ViewModel/Services/student_viewmodel.dart';
import '../Utils/app_colors.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _maSVController = TextEditingController();
  final _hoTenController = TextEditingController();
  final _diaChiController = TextEditingController();
  final _soDTController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String? _selectedMaNganh;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SinhVienViewModel>(context, listen: false).fetchNganhs();
    });
  }

  @override
  void dispose() {
    _maSVController.dispose();
    _hoTenController.dispose();
    _diaChiController.dispose();
    _soDTController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      
      final newStudent = Student(
        id: _maSVController.text.trim(),
        fullName: _hoTenController.text.trim(),
        majorId: _selectedMaNganh,
        address: _diaChiController.text.trim().isEmpty ? null : _diaChiController.text.trim(),
        phoneNumber: _soDTController.text.trim().isEmpty ? null : _soDTController.text.trim(),
        avatarPath: null,
      );

      final success = await authViewModel.register(
        newStudent,
        _passwordController.text,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng ký thành công! Vui lòng đăng nhập.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authViewModel.errorMessage ?? 'Đăng ký thất bại'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthViewModel>().isLoading;
    final studentViewModel = context.watch<SinhVienViewModel>();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryLight,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_add,
                          size: 80,
                          color: AppColors.primaryDark,                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Đăng Ký Tài Khoản',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Mã SV
                        TextFormField(
                          controller: _maSVController,
                          decoration: InputDecoration(
                            labelText: 'Mã Sinh Viên',
                            prefixIcon: const Icon(Icons.badge),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Vui lòng nhập mã sinh viên';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Họ Tên
                        TextFormField(
                          controller: _hoTenController,
                          decoration: InputDecoration(
                            labelText: 'Họ và Tên',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Vui lòng nhập họ tên';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Ngành
                        DropdownButtonFormField<String>(
                          value: _selectedMaNganh,
                          decoration: InputDecoration(
                            labelText: 'Ngành',
                            prefixIcon: const Icon(Icons.school),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: studentViewModel.nganhs.isEmpty 
                            ? null 
                            : studentViewModel.nganhs.map((nganh) {
                                return DropdownMenuItem(
                                  value: nganh.maNganh,
                                  child: Text(nganh.tenNganh),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedMaNganh = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Mật khẩu
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Mật Khẩu',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Vui lòng nhập mật khẩu';
                            if (value!.length < 3) return 'Mật khẩu phải có ít nhất 3 ký tự';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Xác nhận mật khẩu
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Xác Nhận Mật Khẩu',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Vui lòng xác nhận mật khẩu';
                            if (value != _passwordController.text) return 'Mật khẩu không khớp';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Nút đăng ký
                        if (isLoading)
                          const CircularProgressIndicator()
                        else
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _handleRegister,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: AppColors.primaryLight,
                              ),
                              child: const Text(
                                'Đăng Ký',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        
                        // Link đăng nhập
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Đã có tài khoản? '),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Đăng nhập ngay',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
