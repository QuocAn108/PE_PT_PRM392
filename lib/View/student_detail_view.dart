import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Model/student.dart';
import '../../ViewModel/Services/auth_viewmodel.dart';
import '../../ViewModel/Services/student_viewmodel.dart';
import 'student_map_view.dart';
import '../../Utils/app_colors.dart';

class StudentDetailView extends StatefulWidget {
  final Student? student;

  const StudentDetailView({super.key, this.student});

  @override
  State<StudentDetailView> createState() => _StudentDetailViewState();
}

class _StudentDetailViewState extends State<StudentDetailView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _maSVController;
  late TextEditingController _hoTenController;
  late TextEditingController _diaChiController;
  late TextEditingController _soDTController;
  
  String? _selectedMaNganh;
  bool _isEditing = false;
  bool _hasPermission = true;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.student != null;
    
    _maSVController = TextEditingController(text: widget.student?.studentId ?? '');
    _hoTenController = TextEditingController(text: widget.student?.full_name ?? '');
    _diaChiController = TextEditingController(text: widget.student?.addresss ?? '');
    _soDTController = TextEditingController(text: widget.student?.phone_number ?? '');
    _selectedMaNganh = widget.student?.maNganh;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = Provider.of<StudentViewmodel>(context, listen: false);
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      
      // Check permission when editing
      if (_isEditing && widget.student != null) {
        _hasPermission = authViewModel.canEditStudent(widget.student!.studentId ?? '');
        if (!_hasPermission) {
          // No permission, go back
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You do not have permission to edit this student!'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Fetch latest student data to ensure the form shows current data
        final latestStudent = await viewModel.getStudentById(widget.student!.studentId ?? '');
        if (latestStudent != null && mounted) {
          setState(() {
            _maSVController.text = latestStudent.studentId ?? '';
            _hoTenController.text = latestStudent.full_name;
            _diaChiController.text = latestStudent.addresss ?? '';
            _soDTController.text = latestStudent.phone_number ?? '';
            _selectedMaNganh = latestStudent.maNganh;
          });
        }
      }
      
      viewModel.fetchMajors();
      viewModel.clearPickedImage();
    });
  }

  @override
  void dispose() {
    _maSVController.dispose();
    _hoTenController.dispose();
    _diaChiController.dispose();
    _soDTController.dispose();
    super.dispose();
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose image source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take photo'),
              onTap: () async {
                Navigator.pop(context);
                await Provider.of<StudentViewmodel>(context, listen: false)
                    .pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(context);
                await Provider.of<StudentViewmodel>(context, listen: false)
                    .pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickContactPhone() async {
    final viewModel = Provider.of<StudentViewmodel>(context, listen: false);
    final phone = await viewModel.pickContactPhone();
    if (phone != null) {
      setState(() {
        _soDTController.text = phone;
      });
    }
  }

  Future<void> _saveStudent() async {
    if (_formKey.currentState?.validate() ?? false) {
      final viewModel = Provider.of<StudentViewmodel>(context, listen: false);
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      
      // Check permission before saving
      if (_isEditing && widget.student != null) {
        if (!authViewModel.canEditStudent(widget.student!.studentId ?? '')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You do not have permission to edit this student!'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
      
      await viewModel.saveStudent(
        maSV: _maSVController.text.trim(),
        hoTen: _hoTenController.text.trim(),
        diaChi: _diaChiController.text.trim().isEmpty ? null : _diaChiController.text.trim(),
        soDT: _soDTController.text.trim().isEmpty ? null : _soDTController.text.trim(),
        maNganh: _selectedMaNganh,
        currentAvatarPath: widget.student?.avatarPath,
        isEditing: _isEditing,
      );

      // Refresh the list and current user data
      await viewModel.fetchStudents();
      await authViewModel.refreshCurrentUser();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Updated successfully!' : 'Added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  void _showMapView() {
    if (_diaChiController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an address before viewing the map'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentMapView(address: _diaChiController.text.trim()),
      ),
    );
  }

  Widget _buildAvatar() {
    final viewModel = context.watch<StudentViewmodel>();
    
    if (viewModel.pickedImage != null) {
      return CircleAvatar(
        key: ValueKey('picked_${viewModel.pickedImage!.path}'),
        radius: 60,
        backgroundImage: FileImage(viewModel.pickedImage!),
      );
    } else if (widget.student?.avatarPath != null && 
               widget.student!.avatarPath!.isNotEmpty &&
               File(widget.student!.avatarPath!).existsSync()) {
      return CircleAvatar(
        key: ValueKey('avatar_${widget.student!.avatarPath}'),
        radius: 60,
        backgroundImage: FileImage(File(widget.student!.avatarPath!)),
      );
    } else {
      return CircleAvatar(
        radius: 60,
        backgroundColor: AppColors.primaryLight,
        child: Icon(
          Icons.person,
          size: 60,
          color: AppColors.primaryLight,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StudentViewmodel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Student' : 'Add Student',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: AppColors.primaryDark,
      ),
      body: viewModel.isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Processing...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header with Avatar Section
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Stack(
                            children: [
                              Hero(
                                tag: _isEditing ? 'avatar_${widget.student?.studentId}' : 'new_avatar',
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: _buildAvatar(),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade500,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                                    onPressed: _showImageSourceDialog,
                                    tooltip: 'Change photo',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                    
                    // Form Content with Cards
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF5F7FA),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Basic Information
                              _buildSectionTitle('Basic Information', Icons.person),
                              const SizedBox(height: 16),
                              _buildFormCard([
                                // Student ID
                                TextFormField(
                                  controller: _maSVController,
                                  decoration: InputDecoration(
                                    labelText: 'Student ID *',
                                    hintText: 'Enter student ID',
                                    prefixIcon: Icon(Icons.badge, color: AppColors.primaryLight),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade200),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
                                    ),
                                  ),
                                  enabled: !_isEditing,
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) return 'Please enter student ID';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Full Name
                                TextFormField(
                                  controller: _hoTenController,
                                  decoration: InputDecoration(
                                    labelText: 'Full Name *',
                                    hintText: 'Enter full name',
                                    prefixIcon: Icon(Icons.person, color: AppColors.primaryLight),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade200),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) return 'Please enter full name';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),

                                // Major
                                DropdownButtonFormField<String>(
                                  value: _selectedMaNganh,
                                  decoration: InputDecoration(
                                    labelText: 'Major',
                                    hintText: 'Select major',
                                    prefixIcon: Icon(Icons.school, color: AppColors.primaryLight),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade200),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
                                    ),
                                  ),
                                  items: viewModel.majors.isEmpty
                                    ? null 
                                    : viewModel.majors.map((nganh) {
                                        return DropdownMenuItem(
                                          value: nganh.majorId,
                                          child: Text(nganh.majorName),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedMaNganh = value;
                                    });
                                  },
                                ),
                              ]),
                              
                              const SizedBox(height: 24),
                              
                              // Contact Information
                              _buildSectionTitle('Contact Information', Icons.contact_phone),
                              const SizedBox(height: 16),
                              _buildFormCard([
                                // Address with Map button
                                TextFormField(
                                  controller: _diaChiController,
                                  decoration: InputDecoration(
                                    labelText: 'Address',
                                    hintText: 'Enter address',
                                    prefixIcon: Icon(Icons.home, color: Colors.green.shade400),
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.map, color: Colors.green.shade400),
                                      onPressed: _showMapView,
                                      tooltip: 'View on map',
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade200),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.green.shade400, width: 2),
                                    ),
                                  ),
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 16),

                                // Phone Number with Contact picker
                                TextFormField(
                                  controller: _soDTController,
                                  decoration: InputDecoration(
                                    labelText: 'Phone Number',
                                    hintText: 'Enter phone number',
                                    prefixIcon: Icon(Icons.phone, color: Colors.orange.shade400),
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.contacts, color: Colors.orange.shade400),
                                      onPressed: _pickContactPhone,
                                      tooltip: 'Pick from contacts',
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey.shade200),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.orange.shade400, width: 2),
                                    ),
                                  ),
                                  keyboardType: TextInputType.phone,
                                ),
                              ]),

                              const SizedBox(height: 32),

                              // Save Button
                              ElevatedButton.icon(
                                onPressed: _saveStudent,
                                icon: const Icon(Icons.save, color: Colors.white),
                                label: Text(
                                  _isEditing ? 'Update Information' : 'Add Student',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  backgroundColor: AppColors.primaryLight,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 4,
                                  shadowColor: AppColors.primaryLight,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade200,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
