class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'],
      options: List<String>.from(json['options']),
      correctIndex: json['correctIndex'],
    );
  }
}

class Lesson {
  final String id;
  final String title;
  final int moduleNumber;
  final String sectionName;
  final String content;
  final int orderIndex;
  List<QuizQuestion> questions;
  bool isCompleted;
  bool isLocked;
  final int coinsReward;

  Lesson({
    required this.id,
    required this.title,
    required this.moduleNumber,
    required this.sectionName,
    required this.content,
    required this.orderIndex,
    required this.questions,
    this.isCompleted = false,
    this.isLocked = false,
    this.coinsReward = 10,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'] ?? '',
      moduleNumber: json['moduleNumber'] ?? 1,
      sectionName: json['sectionName'] ?? '',
      content: json['content'] ?? '',
      orderIndex: json['order_index'] ?? 0,
      questions: [], // Questions are fetched separately
      coinsReward: json['coinsReward'] ?? 10,
    );
  }

  Lesson copyWith({bool? isCompleted, bool? isLocked}) {
    return Lesson(
      id: id,
      title: title,
      moduleNumber: moduleNumber,
      sectionName: sectionName,
      content: content,
      orderIndex: orderIndex,
      questions: questions,
      isCompleted: isCompleted ?? this.isCompleted,
      isLocked: isLocked ?? this.isLocked,
      coinsReward: coinsReward,
    );
  }
}
