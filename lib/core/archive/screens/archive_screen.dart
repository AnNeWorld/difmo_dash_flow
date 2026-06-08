import 'package:flutter/material.dart';

import '../models/document_model.dart';
import '../widgets/document_card.dart';
import '../widgets/filter_chip_widget.dart';
import '../widgets/search_bar_widget.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'HR',
    'Finance',
    'Sales',
    'Personal'
  ];

  // Mock data
  late final List<DocumentModel> _allDocuments;

  @override
  void initState() {
    super.initState();
    _allDocuments = [
      DocumentModel(
        id: '1',
        name: 'Salary_Slip_Jan_2026.pdf',
        fileType: 'pdf',
        uploadDate: DateTime(2026, 1, 31),
        size: '1.2 MB',
        category: 'Finance',
      ),
      DocumentModel(
        id: '2',
        name: 'Sales_Report_Feb.xlsx',
        fileType: 'xlsx',
        uploadDate: DateTime(2026, 2, 28),
        size: '3.4 MB',
        category: 'Sales',
      ),
      DocumentModel(
        id: '3',
        name: 'HR_Policy.docx',
        fileType: 'docx',
        uploadDate: DateTime(2025, 12, 15),
        size: '2.5 MB',
        category: 'HR',
      ),
      DocumentModel(
        id: '4',
        name: 'Employee_Contract.pdf',
        fileType: 'pdf',
        uploadDate: DateTime(2024, 6, 12),
        size: '4.1 MB',
        category: 'Personal',
      ),
      DocumentModel(
        id: '5',
        name: 'Q4_Financial_Summary.pdf',
        fileType: 'pdf',
        uploadDate: DateTime(2025, 12, 31),
        size: '8.7 MB',
        category: 'Finance',
      ),
    ];
  }

  List<DocumentModel> get _filteredDocuments {
    return _allDocuments.where((doc) {
      final matchesCategory = _selectedCategory == 'All' || doc.category == _selectedCategory;
      final matchesSearch = doc.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredDocs = _filteredDocuments;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Archives',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              children: [
                SearchBarWidget(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: _categories.map((category) {
                      return FilterChipWidget(
                        label: category,
                        isSelected: _selectedCategory == category,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredDocs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'No documents found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final document = filteredDocs[index];
                      return DocumentCard(
                        document: document,
                        onView: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Viewing ${document.name}')),
                          );
                        },
                        onDownload: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Downloading ${document.name}')),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
