import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class EmployeeModel {
  final String id;
  final String name;
  final String position;
  final String email;
  final String salary;

  const EmployeeModel({
    required this.id,
    required this.name,
    required this.position,
    required this.email,
    required this.salary,
  });

  EmployeeModel copyWith({
    String? id,
    String? name,
    String? position,
    String? email,
    String? salary,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      email: email ?? this.email,
      salary: salary ?? this.salary,
    );
  }
}

class EmployeeService extends StateNotifier<AsyncValue<List<EmployeeModel>>> {
  EmployeeService() : super(const AsyncValue.loading()) {
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    state = const AsyncValue.loading();
    try {
      // Simulating network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Mock Data
      final employees = [
        const EmployeeModel(
          id: 'EMP-001',
          name: 'Rahul Sharma',
          position: 'Flutter Developer',
          email: 'rahul.s@example.com',
          salary: '₹60,000',
        ),
        const EmployeeModel(
          id: 'EMP-002',
          name: 'Anjali Varma',
          position: 'UI/UX Designer',
          email: 'anjali.v@example.com',
          salary: '₹50,000',
        ),
        const EmployeeModel(
          id: 'EMP-003',
          name: 'Neeraj Singh',
          position: 'Backend Developer',
          email: 'neeraj.s@example.com',
          salary: '₹70,000',
        ),
        const EmployeeModel(
          id: 'EMP-004',
          name: 'Priya Patel',
          position: 'Product Manager',
          email: 'priya.p@example.com',
          salary: '₹95,000',
        ),
        const EmployeeModel(
          id: 'EMP-005',
          name: 'Vikram Mehta',
          position: 'DevOps Engineer',
          email: 'vikram.m@example.com',
          salary: '₹85,000',
        ),
      ];

      state = AsyncValue.data(employees);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void addEmployee(EmployeeModel employee) {
    if (state.value != null) {
      state = AsyncValue.data([...state.value!, employee]);
    }
  }

  void deleteEmployee(String id) {
    if (state.value != null) {
      state = AsyncValue.data(state.value!.where((e) => e.id != id).toList());
    }
  }
}

final employeeProvider =
    StateNotifierProvider<EmployeeService, AsyncValue<List<EmployeeModel>>>((
      ref,
    ) {
      return EmployeeService();
    });
