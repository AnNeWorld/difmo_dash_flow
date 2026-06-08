class EmployeeModel {
  final String id;
  final String firstName;
  final String lastName;
  final String name;
  final String email;
  final String phone;
  final String department;
  final String designation;
  final double salary;
  final DateTime joinDate;
  final String? profileImage;
  final String gender;
  final DateTime dateOfBirth;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String? bankAccount;
  final String? ifscCode;
  final String panNumber;
  final String? aadharNumber;
  final String employmentType;
  final String status;
  final DateTime? exitDate;
  final bool isOnline;

  EmployeeModel({
    required this.id,
    this.firstName = '',
    this.lastName = '',
    required this.name,
    required this.email,
    required this.phone,
    required this.department,
    required this.designation,
    required this.salary,
    required this.joinDate,
    this.profileImage,
    required this.gender,
    required this.dateOfBirth,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    this.bankAccount,
    this.ifscCode,
    required this.panNumber,
    this.aadharNumber,
    required this.employmentType,
    required this.status,
    this.exitDate,
    this.isOnline = false,
  });
  String get fullName {
    final combined = '$firstName $lastName'.trim();
    return combined.isNotEmpty ? combined : name;
  }

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    final fName = json['firstName'] as String? ?? '';
    final lName = json['lastName'] as String? ?? '';
    final rawName = json['name'] as String? ?? '';
    final computedName = '$fName $lName'.trim().isNotEmpty
        ? '$fName $lName'.trim()
        : rawName;

    return EmployeeModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      firstName: fName,
      lastName: lName,
      name: computedName,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      department: json['department'] as String? ?? '',
      designation: json['designation'] as String? ?? '',
      salary: (json['salary'] as num?)?.toDouble() ?? 0.0,
      joinDate: json['joinDate'] != null
          ? DateTime.tryParse(json['joinDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      profileImage: json['profileImage'] as String?,
      gender: json['gender'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'] as String) ?? DateTime.now()
          : DateTime.now(),
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      zipCode: json['zipCode'] as String? ?? '',
      bankAccount: json['bankAccount'] as String?,
      ifscCode: json['ifscCode'] as String?,
      panNumber: json['panNumber'] as String? ?? '',
      aadharNumber: json['aadharNumber'] as String?,
      employmentType: json['employmentType'] as String? ?? '',
      status: json['status'] as String? ?? '',
      exitDate: json['exitDate'] != null
          ? DateTime.tryParse(json['exitDate'] as String)
          : null,
      isOnline:
          json['isOnline'] as bool? ??
          json['status'] == 'active' || json['status'] == 'Active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'name': name,
      'email': email,
      'phone': phone,
      'department': department,
      'designation': designation,
      'salary': salary,
      'joinDate': joinDate.toIso8601String(),
      'profileImage': profileImage,
      'gender': gender,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'address': address,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'bankAccount': bankAccount,
      'ifscCode': ifscCode,
      'panNumber': panNumber,
      'aadharNumber': aadharNumber,
      'employmentType': employmentType,
      'status': status,
      'exitDate': exitDate?.toIso8601String(),
      'isOnline': isOnline,
    };
  }

  EmployeeModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? name,
    String? email,
    String? phone,
    String? department,
    String? designation,
    double? salary,
    DateTime? joinDate,
    String? profileImage,
    String? gender,
    DateTime? dateOfBirth,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? bankAccount,
    String? ifscCode,
    String? panNumber,
    String? aadharNumber,
    String? employmentType,
    String? status,
    DateTime? exitDate,
    bool? isOnline,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      salary: salary ?? this.salary,
      joinDate: joinDate ?? this.joinDate,
      profileImage: profileImage ?? this.profileImage,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      bankAccount: bankAccount ?? this.bankAccount,
      ifscCode: ifscCode ?? this.ifscCode,
      panNumber: panNumber ?? this.panNumber,
      aadharNumber: aadharNumber ?? this.aadharNumber,
      employmentType: employmentType ?? this.employmentType,
      status: status ?? this.status,
      exitDate: exitDate ?? this.exitDate,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  bool get isActive => status == 'Active';

  bool get isInactive => status == 'Inactive';

  bool get hasExited => status == 'Exited' && exitDate != null;

  int get yearsOfService {
    final endDate = exitDate ?? DateTime.now();
    return endDate.difference(joinDate).inDays ~/ 365;
  }

  String get employmentTypeDisplay {
    switch (employmentType) {
      case 'Full-Time':
        return 'Full-Time';
      case 'Part-Time':
        return 'Part-Time';
      case 'Contract':
        return 'Contract';
      case 'Intern':
        return 'Internship';
      default:
        return employmentType;
    }
  }

  String get statusColor {
    switch (status) {
      case 'Active':
        return '#4CAF50';
      case 'Inactive':
        return '#FFC107';
      case 'Exited':
        return '#F44336';
      default:
        return '#9E9E9E';
    }
  }

  int calculateAge() {
    final today = DateTime.now();
    int age = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  String getFullAddress() {
    return '$address, $city, $state - $zipCode';
  }

  bool get isEligibleForRetirement {
    return calculateAge() >= 60;
  }

  int getProfileCompleteness() {
    int completedFields = 0;
    int totalFields = 20;

    if (profileImage != null && profileImage!.isNotEmpty) completedFields++;
    if (address.isNotEmpty) completedFields++;
    if (city.isNotEmpty) completedFields++;
    if (state.isNotEmpty) completedFields++;
    if (zipCode.isNotEmpty) completedFields++;
    if (bankAccount != null && bankAccount!.isNotEmpty) completedFields++;
    if (ifscCode != null && ifscCode!.isNotEmpty) completedFields++;
    if (panNumber.isNotEmpty) completedFields++;
    if (aadharNumber != null && aadharNumber!.isNotEmpty) completedFields++;

    return ((completedFields / totalFields) * 100).toInt();
  }

  bool isValidEmail() {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool isValidPhone() {
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    return phoneRegex.hasMatch(phone);
  }

  bool isValidPAN() {
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    return panRegex.hasMatch(panNumber);
  }

  String getFormattedJoinDate() {
    return '${joinDate.day}-${joinDate.month}-${joinDate.year}';
  }

  String getFormattedDOB() {
    return '${dateOfBirth.day}-${dateOfBirth.month}-${dateOfBirth.year}';
  }

  String? getFormattedExitDate() {
    if (exitDate == null) return null;
    return '${exitDate!.day}-${exitDate!.month}-${exitDate!.year}';
  }

  @override
  String toString() {
    return 'EmployeeModel(id: $id, name: $name, email: $email, department: $department, designation: $designation, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EmployeeModel &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.department == department &&
        other.designation == designation &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        department.hashCode ^
        designation.hashCode ^
        status.hashCode;
  }
}
