import 'package:flutter_test_version/features/user/data/repositories/user_repository.dart';
import 'package:flutter_test_version/features/user/domain/entities/user.dart';

class UpdateUserProfile {
  final UserRepository userRepository;

  UpdateUserProfile({required this.userRepository});

  Future<void> call(User user) async {
    // เรียก UserRepository เพื่ออัปเดตข้อมูล
    await userRepository.updateUserProfile(user);
  }
}
