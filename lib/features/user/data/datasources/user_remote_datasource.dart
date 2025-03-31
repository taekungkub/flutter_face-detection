import 'package:flutter_test_version/features/user/domain/entities/user.dart';

class UserRemoteDatasource {
  Future<void> updateUserProfile(User user) async {
    // ทำการเรียก API สำหรับอัปเดตข้อมูลผู้ใช้
    final response = await Future.value(123);
    // ตรวจสอบผลลัพธ์จาก API แล้วทำการจัดการ
  }
}
