import 'dart:ui';

import 'package:linkorize/models/note.dart';

class Category {
  final String id;
  Color avatarColor;
  String name;
  final List<Note> notes;

  Category({
    required this.id,
    required this.avatarColor,
    required this.name,
    required this.notes,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      avatarColor: Color.from(
        alpha: 1,
        red: json['avatar']['red'],
        green: json['avatar']['green'],
        blue: json['avatar']['blue'],
      ),
      notes:
          (json['notes'] as List).map((note) => Note.fromJson(note)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "avatar": {
        "red": avatarColor.r,
        "green": avatarColor.g,
        "blue": avatarColor.b,
      },
      "notes": [for (var note in notes) note.toJson()],
    };
  }
}
