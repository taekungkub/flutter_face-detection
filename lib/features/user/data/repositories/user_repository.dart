import 'package:flutter_test_version/features/user/data/datasources/user_remote_datasource.dart';
import 'package:flutter_test_version/features/user/domain/entities/user.dart';

class UserRepository {
  final UserRemoteDatasource remoteDatasource;

  UserRepository({required this.remoteDatasource});

  Future<void> updateUserProfile(User user) async {
    // ทำการเรียก API หรือ update ข้อมูล
    await remoteDatasource.updateUserProfile(user);
  }
}
