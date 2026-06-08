part of 'attendance_model.dart';

T _$identity<T>(T value) => value;

mixin _$AttendanceModel {
  String get id;
  String get employeeId;
  String get employeeName;
  DateTime get date;
  String get checkIn;
  String get checkOut;
  String get status;
  double? get workingHours;
  String? get remarks;

  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AttendanceModelCopyWith<AttendanceModel> get copyWith =>
      _$AttendanceModelCopyWithImpl<AttendanceModel>(
        this as AttendanceModel,
        _$identity,
      );

  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AttendanceModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.employeeName, employeeName) ||
                other.employeeName == employeeName) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.checkIn, checkIn) || other.checkIn == checkIn) &&
            (identical(other.checkOut, checkOut) ||
                other.checkOut == checkOut) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.workingHours, workingHours) ||
                other.workingHours == workingHours) &&
            (identical(other.remarks, remarks) || other.remarks == remarks));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    employeeId,
    employeeName,
    date,
    checkIn,
    checkOut,
    status,
    workingHours,
    remarks,
  );

  @override
  String toString() {
    return 'AttendanceModel(id: $id, employeeId: $employeeId, employeeName: $employeeName, date: $date, checkIn: $checkIn, checkOut: $checkOut, status: $status, workingHours: $workingHours, remarks: $remarks)';
  }
}

abstract mixin class $AttendanceModelCopyWith<$Res> {
  factory $AttendanceModelCopyWith(
    AttendanceModel value,
    $Res Function(AttendanceModel) then,
  ) = _$AttendanceModelCopyWithImpl;
  @useResult
  $Res call({
    String id,
    String employeeId,
    String employeeName,
    DateTime date,
    String checkIn,
    String checkOut,
    String status,
    double? workingHours,
    String? remarks,
  });
}

class _$AttendanceModelCopyWithImpl<$Res>
    implements $AttendanceModelCopyWith<$Res> {
  _$AttendanceModelCopyWithImpl(this._self, this._then);

  final AttendanceModel _self;
  final $Res Function(AttendanceModel) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id,
    Object? employeeId,
    Object? employeeName,
    Object? date,
    Object? checkIn,
    Object? checkOut,
    Object? status,
    Object? workingHours = freezed,
    Object? remarks = freezed,
  }) {
    return _then(
      _self.copyWith(
        id: null == id ? _self.id : id as String,
        employeeId: null == employeeId
            ? _self.employeeId
            : employeeId as String,
        employeeName: null == employeeName
            ? _self.employeeName
            : employeeName as String,
        date: null == date ? _self.date : date as DateTime,
        checkIn: null == checkIn ? _self.checkIn : checkIn as String,
        checkOut: null == checkOut ? _self.checkOut : checkOut as String,
        status: null == status ? _self.status : status as String,
        workingHours: freezed == workingHours
            ? _self.workingHours
            : workingHours as double?,
        remarks: freezed == remarks ? _self.remarks : remarks as String?,
      ),
    );
  }
}

/// Adds pattern-matching-related methods to AttendanceModel].
extension AttendanceModelPatterns on AttendanceModel {
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_AttendanceModel value)? $default, {
    required TResult Function() orElse,
  }) {
    final that = this;
    switch (that) {
      case _AttendanceModel() when $default != null:
        return $default(that);
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_AttendanceModel value) $default,
  ) {
    final that = this;
    switch (that) {
      case _AttendanceModel():
        return $default(that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_AttendanceModel value)? $default,
  ) {
    final that = this;
    switch (that) {
      case _AttendanceModel() when $default != null:
        return $default(that);
      case _:
        return null;
    }
  }

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
      String id,
      String employeeId,
      String employeeName,
      DateTime date,
      String checkIn,
      String checkOut,
      String status,
      double? workingHours,
      String? remarks,
    )?
    $default, {
    required TResult Function() orElse,
  }) {
    final that = this;
    switch (that) {
      case _AttendanceModel() when $default != null:
        return $default(
          that.id,
          that.employeeId,
          that.employeeName,
          that.date,
          that.checkIn,
          that.checkOut,
          that.status,
          that.workingHours,
          that.remarks,
        );
      case _:
        return orElse();
    }
  }

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
      String id,
      String employeeId,
      String employeeName,
      DateTime date,
      String checkIn,
      String checkOut,
      String status,
      double? workingHours,
      String? remarks,
    )
    $default,
  ) {
    final that = this;
    switch (that) {
      case _AttendanceModel():
        return $default(
          that.id,
          that.employeeId,
          that.employeeName,
          that.date,
          that.checkIn,
          that.checkOut,
          that.status,
          that.workingHours,
          that.remarks,
        );
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
      String id,
      String employeeId,
      String employeeName,
      DateTime date,
      String checkIn,
      String checkOut,
      String status,
      double? workingHours,
      String? remarks,
    )?
    $default,
  ) {
    final that = this;
    switch (that) {
      case _AttendanceModel() when $default != null:
        return $default(
          that.id,
          that.employeeId,
          that.employeeName,
          that.date,
          that.checkIn,
          that.checkOut,
          that.status,
          that.workingHours,
          that.remarks,
        );
      case _:
        return null;
    }
  }
}

@JsonSerializable()
class _AttendanceModel implements AttendanceModel {
  const _AttendanceModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    this.workingHours,
    this.remarks,
  });

  @override
  final String id;
  @override
  final String employeeId;
  @override
  final String employeeName;
  @override
  final DateTime date;
  @override
  final String checkIn;
  @override
  final String checkOut;
  @override
  final String status;
  @override
  final double? workingHours;
  @override
  final String? remarks;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AttendanceModelCopyWith<_AttendanceModel> get copyWith =>
      __$AttendanceModelCopyWithImpl<_AttendanceModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AttendanceModelToJson(this);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AttendanceModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.employeeId, employeeId) ||
                other.employeeId == employeeId) &&
            (identical(other.employeeName, employeeName) ||
                other.employeeName == employeeName) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.checkIn, checkIn) || other.checkIn == checkIn) &&
            (identical(other.checkOut, checkOut) ||
                other.checkOut == checkOut) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.workingHours, workingHours) ||
                other.workingHours == workingHours) &&
            (identical(other.remarks, remarks) || other.remarks == remarks));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    employeeId,
    employeeName,
    date,
    checkIn,
    checkOut,
    status,
    workingHours,
    remarks,
  );

  @override
  String toString() {
    return 'AttendanceModel(id: $id, employeeId: $employeeId, employeeName: $employeeName, date: $date, checkIn: $checkIn, checkOut: $checkOut, status: $status, workingHours: $workingHours, remarks: $remarks)';
  }
}

abstract mixin class _$AttendanceModelCopyWith<$Res>
    implements $AttendanceModelCopyWith<$Res> {
  factory _$AttendanceModelCopyWith(
    _AttendanceModel value,
    $Res Function(_AttendanceModel) then,
  ) = __$AttendanceModelCopyWithImpl;
  @override
  @useResult
  $Res call({
    String id,
    String employeeId,
    String employeeName,
    DateTime date,
    String checkIn,
    String checkOut,
    String status,
    double? workingHours,
    String? remarks,
  });
}

class __$AttendanceModelCopyWithImpl<$Res>
    implements _$AttendanceModelCopyWith<$Res> {
  __$AttendanceModelCopyWithImpl(this._self, this._then);

  final _AttendanceModel _self;
  final $Res Function(_AttendanceModel) _then;

  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id,
    Object? employeeId,
    Object? employeeName,
    Object? date,
    Object? checkIn,
    Object? checkOut,
    Object? status,
    Object? workingHours = freezed,
    Object? remarks = freezed,
  }) {
    return _then(
      _AttendanceModel(
        id: null == id ? _self.id : id as String,
        employeeId: null == employeeId
            ? _self.employeeId
            : employeeId as String,
        employeeName: null == employeeName
            ? _self.employeeName
            : employeeName as String,
        date: null == date ? _self.date : date as DateTime,
        checkIn: null == checkIn ? _self.checkIn : checkIn as String,
        checkOut: null == checkOut ? _self.checkOut : checkOut as String,
        status: null == status ? _self.status : status as String,
        workingHours: freezed == workingHours
            ? _self.workingHours
            : workingHours as double?,
        remarks: freezed == remarks ? _self.remarks : remarks as String?,
      ),
    );
  }
}
