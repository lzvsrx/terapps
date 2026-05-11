class User {
  User({required this.id, required this.name, required this.email, required this.profession});
  final int id;
  final String name;
  final String email;
  final String profession;
}

class ProfessionPreset {
  ProfessionPreset({required this.name, required this.category, required this.description});
  final String name;
  final String category;
  final String description;
}

class ProfessionToolkit {
  ProfessionToolkit({
    required this.profession,
    required this.category,
    required this.tools,
    required this.documents,
    required this.routines,
    required this.metrics,
  });

  final String profession;
  final String category;
  final List<String> tools;
  final List<String> documents;
  final List<String> routines;
  final List<String> metrics;
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
    this.updatedAt,
    this.isFavorite = false,
  });

  final int id;
  final int userId;
  final String profession;
  final String type;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isFavorite;
}

class DailyTask {
  DailyTask({required this.id, required this.userId, required this.profession, required this.title, required this.done});
  final int id;
  final int userId;
  final String profession;
  final String title;
  final bool done;
}
