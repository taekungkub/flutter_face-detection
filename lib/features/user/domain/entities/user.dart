class User {
  final String id;
  final String name;
  final String email;
  final String profilePicture;

  User({required this.id, required this.name, required this.email, required this.profilePicture});

  // การแปลงข้อมูลจาก JSON ให้เป็น Entity
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profilePicture: json['profile_picture'],
    );
  }

  // การแปลงจาก Entity ไปเป็น JSON (สำหรับส่งกลับไปยัง API หรือจัดเก็บใน DB)
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'profile_picture': profilePicture};
  }
}
