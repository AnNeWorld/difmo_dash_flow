class EmployeeModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String designation;
  final String department;
  final String phone;
  final bool isOnline;
  final List<dynamic> roles;

  EmployeeModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.designation,
    required this.department,
    required this.phone,
    this.isOnline = false,
    this.roles = const [],
  });

  String get fullName => "$firstName $lastName".trim();

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      designation: json['designation'] ?? 'Employee',
      department: (json['department'] is Map)
          ? (json['department']['name'] ?? 'General').toString()
          : (json['department']?.toString() ?? 'General'),
      phone: json['phone'] ?? '',
      isOnline: json['isOnline'] ?? false,
      roles: json['roles'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'designation': designation,
      'department': department,
      'phone': phone,
      'isOnline': isOnline,
      'roles': roles,
    };
  }
}
