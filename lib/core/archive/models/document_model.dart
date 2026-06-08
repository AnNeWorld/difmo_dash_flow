class DocumentModel {
  final String id;
  final String name;
  final String fileType;
  final DateTime uploadDate;
  final String size;
  final String category;

  DocumentModel({
    required this.id,
    required this.name,
    required this.fileType,
    required this.uploadDate,
    required this.size,
    required this.category,
  });
}
