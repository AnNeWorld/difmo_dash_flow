import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notification Page',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: NotificationsPage(),
    );
  }
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  final List<Map<String, dynamic>> notifications = const [
    {
      'title': 'New Message',
      'subtitle': 'You received a new message from John.',
      'icon': Icons.message,
      'color': Colors.blue,
      'time': '2 min ago',
    },
    {
      'title': 'Order Confirmed',
      'subtitle': 'Your order #1234 has been confirmed.',
      'icon': Icons.shopping_cart,
      'color': Colors.green,
      'time': '10 min ago',
    },
    {
      'title': 'Payment Successful',
      'subtitle': 'Your payment was completed successfully.',
      'icon': Icons.payment,
      'color': Colors.orange,
      'time': '1 hour ago',
    },
    {
      'title': 'App Update',
      'subtitle': 'A new app update is available.',
      'icon': Icons.system_update,
      'color': Colors.purple,
      'time': 'Yesterday',
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.done_all), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: notification['color'],
                radius: 28,
                child: Icon(notification['icon'], color: Colors.white),
              ),
              title: Text(
                notification['title'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(notification['subtitle']),
              ),
              trailing: Text(
                notification['time'],
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
