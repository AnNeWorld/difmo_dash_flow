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
    String fName = json['firstName']?.toString() ?? '';
    String lName = json['lastName']?.toString() ?? '';

    if (fName.isEmpty && json['userId'] is Map) {
      fName = json['userId']['firstName']?.toString() ?? '';
      lName = json['userId']['lastName']?.toString() ?? '';
    } else if (fName.isEmpty && json['user'] is Map) {
      fName = json['user']['firstName']?.toString() ?? '';
      lName = json['user']['lastName']?.toString() ?? '';
    }

    if (fName.isEmpty && json['name'] != null) {
      final parts = json['name'].toString().split(' ');
      fName = parts.first;
      lName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    String empEmail = json['email']?.toString() ?? '';
    if (empEmail.isEmpty && json['userId'] is Map) {
      empEmail = json['userId']['email']?.toString() ?? '';
    } else if (empEmail.isEmpty && json['user'] is Map) {
      empEmail = json['user']['email']?.toString() ?? '';
    }

    return EmployeeModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      firstName: fName,
      lastName: lName,
      email: empEmail,
      designation: (json['designation'] is Map)
          ? (json['designation']['name'] ?? 'Employee').toString()
          : (json['designation']?.toString() ?? 'Employee'),
      department: (json['department'] is Map)
          ? (json['department']['name'] ?? 'General').toString()
          : (json['department']?.toString() ?? 'General'),
      phone: json['phone']?.toString() ?? '',
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
