import 'package:flutter/material.dart';
import 'add_new_empoyees.dart';

void main() {
  runApp(const EmployeesPage());
}

class EmployeesPage extends StatelessWidget {
  const EmployeesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Employee Page',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const EmployeePage(),
    );
  }
}

class EmployeePage extends StatelessWidget {
  const EmployeePage({super.key});

  final List<Map<String, dynamic>> employees = const [
    {
      'name': ' Rahul Sharma',
      'position': 'Flutter Developer',
      'email': ' Rahul@example.com',
      'salary': '₹60,000',
    },
    {
      'name': 'Anjali Varma ',
      'position': 'UI/UX Designer',
      'email': 'Anjali@example.com',
      'salary': '₹50,000',
    },
    {
      'name': 'Neeraj  Singh',
      'position': 'Backend Developer',
      'email': 'Neeaj@example.com',
      'salary': '₹70,000',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employee Details'), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final employee = employees[index];

          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.indigo,
                    child: Text(
                      employee['name'][0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          employee['position'],
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          employee['email'],
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Salary: ${employee['salary']}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Edit ${employee['name']}')),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEmployeeCompletePage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
