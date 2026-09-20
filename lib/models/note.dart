// Cette classe représente une note dans notre application.
class Note {
  final int? id; // null tant que la note n'est pas encore enregistrée en base
  final String title;
  final String content;
  final String createdAt;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  // Convertit une note en Map, pour pouvoir l'enregistrer dans SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt,
    };
  }

  // Convertit une ligne SQLite (Map) en objet Note utilisable dans l'app.
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: map['createdAt'],
    );
  }
}
