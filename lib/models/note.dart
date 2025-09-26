class Note {
  final String? title;
  final String link;

  Note({required this.title, required this.link});

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(title: json['title'], link: json['link']);
  }

  Map<String, dynamic> toJson() => {'title': title, 'link': link};
}
