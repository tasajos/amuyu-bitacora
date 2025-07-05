// lib/models/entry_model.dart

class Entry {
  final String id;
  final String title;
  final String content;
  final DateTime date;

  Entry({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
  });
}