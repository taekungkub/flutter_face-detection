import 'package:flutter/material.dart';
import 'package:flutter_test_version/features/user/domain/entities/user.dart';
import 'package:flutter_test_version/features/user/domain/usercases/update_user_profile.dart';

class UserController extends ChangeNotifier {
  final UpdateUserProfile updateUserProfileUseCase;

  UserController({required this.updateUserProfileUseCase});

  Future<void> updateUserProfile(User user) async {
    try {
      await updateUserProfileUseCase(user);  // เรียก UseCase เพื่ออัปเดตข้อมูล
      // แจ้งผลลัพธ์การอัปเดต
    } catch (e) {
      // จัดการข้อผิดพลาด
    }
  }
}
