part of 'attendance_model.dart';

_AttendanceModel _$AttendanceModelFromJson(Map<String, dynamic> json) =>
    _AttendanceModel(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      employeeName: json['employeeName'] as String,
      date: DateTime.parse(json['date'] as String),
      checkIn: json['checkIn'] as String,
      checkOut: json['checkOut'] as String,
      status: json['status'] as String,
      workingHours: (json['workingHours'] as num?)?.toDouble(),
      remarks: json['remarks'] as String?,
    );
Map<String, dynamic> _$AttendanceModelToJson(_AttendanceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'employeeName': instance.employeeName,
      'date': instance.date.toIso8601String(),
      'checkIn': instance.checkIn,
      'checkOut': instance.checkOut,
      'status': instance.status,
      'workingHours': instance.workingHours,
      'remarks': instance.remarks,
    };
