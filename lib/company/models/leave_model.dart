class LeaveModel {
  final String id;
  final String employeeId;
  final String employeeName;
  final String? profileImage;
  final String employeeInitials;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final int duration;
  final String status;
  final String reason;
  final String adminRemark;

  LeaveModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    this.profileImage,
    required this.employeeInitials,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.status,
    required this.reason,
    required this.adminRemark,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    // Safely extract employee data
    final empData = json['employee'] is Map<String, dynamic> ? json['employee'] as Map<String, dynamic> : <String, dynamic>{};
    
    final fName = empData['firstName']?.toString() ?? '';
    final lName = empData['lastName']?.toString() ?? '';
    final computedName = '$fName $lName'.trim().isNotEmpty ? '$fName $lName'.trim() : (empData['name']?.toString() ?? 'Unknown');
    final initials = fName.isNotEmpty ? fName[0].toUpperCase() : 'E';

    return LeaveModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      employeeId: empData['_id']?.toString() ?? empData['id']?.toString() ?? '',
      employeeName: computedName,
      profileImage: empData['profileImage']?.toString(),
      employeeInitials: initials,
      type: json['type']?.toString() ?? json['leaveType']?.toString() ?? 'Leave',
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate'].toString()) ?? DateTime.now() : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate'].toString()) ?? DateTime.now() : DateTime.now(),
      duration: int.tryParse(json['duration']?.toString() ?? '1') ?? 1,
      status: (json['status']?.toString() ?? 'PENDING').toUpperCase(),
      reason: json['reason']?.toString() ?? '',
      adminRemark: json['adminRemark']?.toString() ?? '',
    );
  }

  LeaveModel copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    String? profileImage,
    String? employeeInitials,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    int? duration,
    String? status,
    String? reason,
    String? adminRemark,
  }) {
    return LeaveModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      profileImage: profileImage ?? this.profileImage,
      employeeInitials: employeeInitials ?? this.employeeInitials,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      adminRemark: adminRemark ?? this.adminRemark,
    );
  }
}
