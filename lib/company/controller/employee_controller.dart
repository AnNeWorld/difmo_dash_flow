import 'package:get/get.dart';
import '../services/api_service.dart';

class EmployeeController extends GetxController {
  final ApiService apiService = ApiService();
  var employees = <dynamic>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var selectedEmployee = Rxn<Map<String, dynamic>>();
  @override
  void onInit() {
    super.onInit();
    fetchAllEmployees();
  }

  Future<void> fetchAllEmployees() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await apiService.getAllUsers();
      employees.value = response;

      if (employees.isEmpty) {
        errorMessage.value = 'No employees found';
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('❌ Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchEmployeeById(String employeeId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await apiService.getUserById(employeeId);
      selectedEmployee.value = response;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('❌ Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createEmployee({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String role,
    String? companyId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await apiService.createUser(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        role: role,
        companyId: companyId,
      );
      await fetchAllEmployees();

      Get.snackbar('✅ Success', 'Employee created successfully!');
      Get.back();
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('❌ Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateEmployee({
    required String employeeId,
    required String firstName,
    required String lastName,
    required String phone,
    required String role,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await apiService.updateUser(
        userId: employeeId,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        role: role,
      );
      await fetchAllEmployees();
      await fetchEmployeeById(employeeId);

      Get.snackbar('✅ Success', 'Employee updated successfully!');
      Get.back();
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('❌ Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteEmployee(String employeeId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await apiService.deleteUser(employeeId);
      await fetchAllEmployees();
      Get.snackbar('✅ Success', 'Employee deleted successfully!');
      Get.back();
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('❌ Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  String getRoleLabel(String role) {
    const roleMap = {
      'admin': '👨‍💼 Admin',
      'manager': '👔 Manager',
      'employee': '👤 Employee',
    };
    return roleMap[role] ?? role;
  }
}
