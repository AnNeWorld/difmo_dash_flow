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
  final Map<String, dynamic>? rawJson;

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
    this.rawJson,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    // Safely extract employee data
    Map<String, dynamic> empData = {};
    if (json['employee'] is Map<String, dynamic>) {
      empData = json['employee'] as Map<String, dynamic>;
    } else if (json['employeeId'] is Map<String, dynamic>) {
      empData = json['employeeId'] as Map<String, dynamic>;
    } else if (json['userId'] is Map<String, dynamic>) {
      empData = json['userId'] as Map<String, dynamic>;
    } else if (json['user'] is Map<String, dynamic>) {
      empData = json['user'] as Map<String, dynamic>;
    }
    
    final fName = empData['firstName']?.toString() ?? 
                  (empData['user'] is Map ? empData['user']['firstName']?.toString() : null) ?? 
                  json['firstName']?.toString() ?? '';
    final lName = empData['lastName']?.toString() ?? 
                  (empData['user'] is Map ? empData['user']['lastName']?.toString() : null) ?? 
                  json['lastName']?.toString() ?? '';
    
    final nameFallback = empData['name']?.toString() ?? 
                         json['employeeName']?.toString() ?? 
                         json['name']?.toString() ?? 
                         'Unknown';

    final computedName = '$fName $lName'.trim().isNotEmpty ? '$fName $lName'.trim() : nameFallback;
    
    String init = '';
    if (fName.isNotEmpty) init += fName[0].toUpperCase();
    if (lName.isNotEmpty) init += lName[0].toUpperCase();
    final initials = init.isNotEmpty ? init : (computedName != 'Unknown' && computedName.isNotEmpty ? computedName[0].toUpperCase() : 'E');
    
    String rawEmpId = '';
    if (json['employeeId'] != null) {
      if (json['employeeId'] is String) rawEmpId = json['employeeId'].toString();
      else if (json['employeeId'] is Map) rawEmpId = json['employeeId']['_id']?.toString() ?? json['employeeId']['id']?.toString() ?? '';
    }
    if (rawEmpId.isEmpty && json['employee'] != null) {
      if (json['employee'] is String) rawEmpId = json['employee'].toString();
      else if (json['employee'] is Map) rawEmpId = json['employee']['_id']?.toString() ?? json['employee']['id']?.toString() ?? '';
    }
    if (rawEmpId.isEmpty && json['userId'] != null) {
      if (json['userId'] is String) rawEmpId = json['userId'].toString();
      else if (json['userId'] is Map) rawEmpId = json['userId']['_id']?.toString() ?? json['userId']['id']?.toString() ?? '';
    }
    
    final empId = empData['customId']?.toString() ??
                  empData['employeeId']?.toString() ??
                  empData['_id']?.toString() ?? 
                  empData['id']?.toString() ?? 
                  (rawEmpId.isNotEmpty ? rawEmpId : 'N/A');

    return LeaveModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      employeeId: empId,
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
      rawJson: json,
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
