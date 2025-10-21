import 'dart:io';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? avatarPath;
  final String userName;
  final double radius;

  const UserAvatar({
    super.key,
    this.avatarPath,
    required this.userName,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (avatarPath != null && avatarPath!.isNotEmpty && File(avatarPath!).existsSync()) {
      return CircleAvatar(
        key: ValueKey(avatarPath),
        radius: radius,
        backgroundImage: FileImage(File(avatarPath!)),
      );
    } else {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.blue.shade200,
        child: Text(
          userName.isNotEmpty ? userName[0].toUpperCase() : '?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: radius * 0.6,
          ),
        ),
      );
    }
  }
}

