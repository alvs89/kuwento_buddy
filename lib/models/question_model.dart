/// Types of questions for comprehension checks
enum QuestionType { multipleChoice, trueFalse, fillBlank }

/// Higher-order thinking skill categories
enum QuestionSkill { inference, prediction, emotion }

/// Model for comprehension questions at story checkpoints
class QuestionModel {
  final String id;
  final String question;
  final QuestionType type;
  final QuestionSkill skill;
  final List<String> options;
  final int correctAnswerIndex;
  final String hint;
  final String encouragement;
  final String buddyHintParagraph;

  const QuestionModel({
    required this.id,
    required this.question,
    required this.type,
    required this.skill,
    required this.options,
    required this.correctAnswerIndex,
    required this.hint,
    required this.encouragement,
    this.buddyHintParagraph = '',
  });

  /// Get the correct answer text
  String get correctAnswer => options[correctAnswerIndex];

  /// Check if the given answer index is correct
  bool isCorrect(int answerIndex) => answerIndex == correctAnswerIndex;

  /// Get skill display name
  String get skillDisplayName {
    switch (skill) {
      case QuestionSkill.inference:
        return 'Understanding Why';
      case QuestionSkill.prediction:
        return 'Predicting What Happens';
      case QuestionSkill.emotion:
        return 'Understanding Feelings';
    }
  }

  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
        id: json['id'] as String,
        question: json['question'] as String,
        type: QuestionType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => QuestionType.multipleChoice,
        ),
        skill: QuestionSkill.values.firstWhere(
          (e) => e.name == json['skill'],
          orElse: () => QuestionSkill.inference,
        ),
        options: (json['options'] as List<dynamic>).cast<String>(),
        correctAnswerIndex: json['correctAnswerIndex'] as int,
        hint: json['hint'] as String,
        encouragement: json['encouragement'] as String,
        buddyHintParagraph: json['buddyHintParagraph'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'type': type.name,
        'skill': skill.name,
        'options': options,
        'correctAnswerIndex': correctAnswerIndex,
        'hint': hint,
        'encouragement': encouragement,
        'buddyHintParagraph': buddyHintParagraph,
      };

  QuestionModel copyWith({
    String? id,
    String? question,
    QuestionType? type,
    QuestionSkill? skill,
    List<String>? options,
    int? correctAnswerIndex,
    String? hint,
    String? encouragement,
    String? buddyHintParagraph,
  }) =>
      QuestionModel(
        id: id ?? this.id,
        question: question ?? this.question,
        type: type ?? this.type,
        skill: skill ?? this.skill,
        options: options ?? this.options,
        correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
        hint: hint ?? this.hint,
        encouragement: encouragement ?? this.encouragement,
        buddyHintParagraph: buddyHintParagraph ?? this.buddyHintParagraph,
      );
}
