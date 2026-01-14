class User {
  final int id;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String idNumber;
  final String phone;
  final String? phone2;
  final String department;
  final int position;
  final String username;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.idNumber,
    required this.phone,
    this.phone2,
    required this.department,
    required this.position,
    required this.username,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      idNumber: json['idNumber'] as String,
      phone: json['phone'] as String,
      phone2: json['phone2'] as String?,
      department: json['department'] as String,
      position: json['position'] as int,
      username: json['username'] as String,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'idNumber': idNumber,
      'phone': phone,
      'phone2': phone2,
      'department': department,
      'position': position,
      'username': username,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? idNumber,
    String? phone,
    String? phone2,
    String? department,
    int? position,
    String? username,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      idNumber: idNumber ?? this.idNumber,
      phone: phone ?? this.phone,
      phone2: phone2 ?? this.phone2,
      department: department ?? this.department,
      position: position ?? this.position,
      username: username ?? this.username,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}