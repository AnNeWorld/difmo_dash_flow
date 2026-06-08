class ApiException implements Exception {
  final String message;
  final String? errorCode;
  final int? statusCode;

  ApiException({required this.message, this.errorCode, this.statusCode});

  @override
  String toString() =>
      'ApiException(message: $message, errorCode: $errorCode, statusCode: $statusCode)';
}

class ListResponse<T> {
  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;

  ListResponse({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });
}

class Attendance {
  final String id;
  final String employeeId;
  final String employeeName;
  final DateTime date;
  final String checkInTime;
  final String? checkOutTime;
  final String status;
  final String? remarks;

  Attendance({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    required this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.remarks,
  });
}

class Employee {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String designation;
  final String department;
  final double salary;
  final DateTime joinDate;
  final String status;
  final String imageUrl;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.designation,
    required this.department,
    required this.salary,
    required this.joinDate,
    required this.status,
    required this.imageUrl,
  });
}

class Leave {
  final String id;
  final String employeeId;
  final String employeeName;
  final DateTime fromDate;
  final DateTime toDate;
  final String leaveType;
  final int noOfDays;
  final String status;
  final String reason;
  final String? approverName;
  final DateTime? approvedDate;

  Leave({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.fromDate,
    required this.toDate,
    required this.leaveType,
    required this.noOfDays,
    required this.status,
    required this.reason,
    this.approverName,
    this.approvedDate,
  });
}

class Payroll {
  final String id;
  final String employeeId;
  final String employeeName;
  final int month;
  final int year;
  final double basicSalary;
  final double hra;
  final double da;
  final double specialAllowance;
  final double attendance;
  final double totalEarnings;
  final double incomeTax;
  final double pfDeduction;
  final double professionalTax;
  final double otherDeductions;
  final double totalDeductions;
  final double netSalary;
  final String status;
  final DateTime? releaseDate;

  Payroll({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.month,
    required this.year,
    required this.basicSalary,
    required this.hra,
    required this.da,
    required this.specialAllowance,
    required this.attendance,
    required this.totalEarnings,
    required this.incomeTax,
    required this.pfDeduction,
    required this.professionalTax,
    required this.otherDeductions,
    required this.totalDeductions,
    required this.netSalary,
    required this.status,
    this.releaseDate,
  });
}
