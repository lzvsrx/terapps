class User {
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.profession,
  });

  final int id;
  final String name;
  final String email;
  final String profession;
}

class ProfessionPreset {
  ProfessionPreset({
    required this.name,
    required this.category,
    required this.description,
  });

  final String name;
  final String category;
  final String description;
}

class WorkRecord {
  WorkRecord({
    required this.id,
    required this.userId,
    required this.profession,
    required this.type,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  final int id;
  final int userId;
  final String profession;
  final String type;
  final String title;
  final String content;
  final DateTime createdAt;
}
