import 'package:flutter/material.dart';
import '../../Model/student.dart';
import '../../Utils/app_colors.dart';
import '../student_detail_view.dart';
import 'user_avatar.dart';

class StudentCard extends StatelessWidget {
  final Student student;
  final bool canEdit;
  final bool canDelete;
  final VoidCallback onDelete;
  final VoidCallback onRefresh;

  const StudentCard({
    super.key,
    required this.student,
    required this.canEdit,
    required this.canDelete,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canEdit
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentDetailView(student: student),
                    ),
                  ).then((_) => onRefresh());
                }
              : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar with badge
                Hero(
                  tag: 'avatar_${student.studentId ?? ''}',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryLight,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: UserAvatar(
                      avatarPath: student.avatarPath,
                      userName: student.full_name,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Student Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.full_name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.badge,
                            size: 14,
                            color: AppColors.primaryLight,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            student.studentId ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (student.phone_number != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 14,
                              color: Colors.green.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              student.phone_number!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Delete Button
                if (canDelete)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                      onPressed: onDelete,
                      tooltip: 'Delete student',
                    ),
                  ),
                
                // Arrow icon
                if (canEdit && !canDelete)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
