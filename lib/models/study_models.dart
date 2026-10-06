class StudyNotes {
  final String title;
  final List<NoteSection> sections;

  StudyNotes({required this.title, required this.sections});

  factory StudyNotes.fromJson(Map<String, dynamic> json) {
    var rawSections = json['sections'] as List? ?? [];
    List<NoteSection> parsedSections = rawSections.map((s) => NoteSection.fromJson(s)).toList();
    return StudyNotes(
      title: json['title'] ?? 'Study Notes',
      sections: parsedSections,
    );
  }
}

class NoteSection {
  final String heading;
  final String subheading;
  final List<String> keyPoints;
  final List<String> stickyNotes;
  final List<String> keywords;

  NoteSection({
    required this.heading,
    required this.subheading,
    required this.keyPoints,
    required this.stickyNotes,
    required this.keywords,
  });

  factory NoteSection.fromJson(Map<String, dynamic> json) {
    return NoteSection(
      heading: json['heading'] ?? '',
      subheading: json['subheading'] ?? '',
      keyPoints: List<String>.from(json['keyPoints'] ?? []),
      stickyNotes: List<String>.from(json['stickyNotes'] ?? []),
      keywords: List<String>.from(json['keywords'] ?? []),
    );
  }
}

class ExamQuestion {
  final String question;
  final List<String> options;
  final String answer;

  ExamQuestion({required this.question, required this.options, required this.answer});

  factory ExamQuestion.fromJson(Map<String, dynamic> json) {
    return ExamQuestion(
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      answer: json['answer'] ?? '',
    );
  }
}

class FlashcardItem {
  final String front;
  final String back;

  FlashcardItem({required this.front, required this.back});

  factory FlashcardItem.fromJson(Map<String, dynamic> json) {
    return FlashcardItem(
      front: json['front'] ?? '',
      back: json['back'] ?? '',
    );
  }
}