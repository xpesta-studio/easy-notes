import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  bool isPinned;

  @HiveField(4)
  int colorIndex;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime updatedAt;

  @HiveField(7)
  List<String> tags;

  Note({
    required this.id,
    required this.title,
    required this.content,
    this.isPinned = false,
    this.colorIndex = 0,
    required this.createdAt,
    required this.updatedAt,
    List<String>? tags,
  }) : tags = tags ?? [];

  /// Creates a copy of this note with modified fields
  Note copyWith({
    String? id,
    String? title,
    String? content,
    bool? isPinned,
    int? colorIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      isPinned: isPinned ?? this.isPinned,
      colorIndex: colorIndex ?? this.colorIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? List.from(this.tags),
    );
  }

  /// Calculates reading time estimation in minutes
  int get estimatedReadTimeMinutes {
    final wordCount = content.trim().isEmpty ? 0 : content.trim().split(RegExp(r'\s+')).length;
    final minutes = (wordCount / 200).ceil();
    return minutes == 0 ? 1 : minutes;
  }

  /// Word count helper
  int get wordCount {
    if (content.trim().isEmpty) return 0;
    return content.trim().split(RegExp(r'\s+')).length;
  }

  /// Character count helper
  int get characterCount {
    return content.length;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'isPinned': isPinned,
      'colorIndex': colorIndex,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      isPinned: map['isPinned'] as bool? ?? false,
      colorIndex: map['colorIndex'] as int? ?? 0,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      tags: List<String>.from(map['tags'] as List? ?? []),
    );
  }
}