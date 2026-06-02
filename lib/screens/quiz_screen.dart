import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lesson.dart';
import '../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  final Lesson lesson;
  const QuizScreen({super.key, required this.lesson});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final List<int?> _selectedAnswers = [];
  int _currentQuestionIndex = 0;
  bool _isCurrentQuestionSubmitted = false;

  @override
  void initState() {
    super.initState();
    _selectedAnswers.addAll(
      List<int?>.filled(widget.lesson.questions.length, null),
    );
  }

  int get _correctCount {
    int count = 0;
    for (int i = 0; i < widget.lesson.questions.length; i++) {
      if (_selectedAnswers[i] == widget.lesson.questions[i].correctIndex) {
        count++;
      }
    }
    return count;
  }

  Future<void> _submitQuiz() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id');
      if (userId != null) {
        await ApiService.submitQuizResult(userId, widget.lesson.id, _selectedAnswers);
        await ApiService.saveProgress(userId, widget.lesson.id, true);
      }
    } catch (_) {}
    _showResultsDialog();
  }

  void _showResultsDialog() {
    final total = widget.lesson.questions.length;
    final correct = _correctCount;
    final percentage = (correct / total * 100).round();
    final coinsEarned =
        (widget.lesson.coinsReward * correct / total).round();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 12),
              const Text(
                'Congratulations!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'You scored $correct out of $total',
                style:
                    const TextStyle(fontSize: 17, color: Color(0xFF555555)),
              ),
              const SizedBox(height: 6),
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: percentage >= 70
                      ? const Color(0xFF58CC02)
                      : const Color(0xFFFF9800),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9C4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFFFFD600), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('💰', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 10),
                    Text(
                      'You earned $coinsEarned coins!',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF856404),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF58CC02),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Back to Roadmap',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final qIndex = _currentQuestionIndex;
    final question = lesson.questions[qIndex];
    final hasSelection = _selectedAnswers[qIndex] != null;
    final isLastQuestion = qIndex == lesson.questions.length - 1;
    final progress = (qIndex + 1) / lesson.questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFE0E0E0),
            color: const Color(0xFF58CC02),
            minHeight: 12,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE0E0E0)),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Module ${lesson.moduleNumber} · ${lesson.sectionName}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      lesson.title,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _QuestionCard(
                      questionIndex: qIndex,
                      question: question,
                      selectedOptionIndex: _selectedAnswers[qIndex],
                      submitted: _isCurrentQuestionSubmitted,
                      onSelect: _isCurrentQuestionSubmitted
                          ? null
                          : (optionIndex) {
                              setState(() =>
                                  _selectedAnswers[qIndex] = optionIndex);
                            },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: !hasSelection
                      ? null
                      : () {
                          if (!_isCurrentQuestionSubmitted) {
                            setState(() {
                              _isCurrentQuestionSubmitted = true;
                            });
                          } else {
                            if (isLastQuestion) {
                              _submitQuiz();
                            } else {
                              setState(() {
                                _currentQuestionIndex++;
                                _isCurrentQuestionSubmitted = false;
                              });
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !hasSelection
                        ? const Color(0xFFE0E0E0)
                        : (_isCurrentQuestionSubmitted
                            ? const Color(0xFF58CC02)
                            : const Color(0xFF2196F3)),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: hasSelection ? 3 : 0,
                  ),
                  child: Text(
                    !_isCurrentQuestionSubmitted
                        ? 'Check Answer'
                        : (isLastQuestion ? 'Finish Quiz' : 'Continue'),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int questionIndex;
  final QuizQuestion question;
  final int? selectedOptionIndex;
  final bool submitted;
  final void Function(int)? onSelect;

  const _QuestionCard({
    required this.questionIndex,
    required this.question,
    required this.selectedOptionIndex,
    required this.submitted,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Q${questionIndex + 1}.  ${question.question}',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(question.options.length, (optIndex) {
          final isSelected = selectedOptionIndex == optIndex;
          final isCorrect = question.correctIndex == optIndex;

          Color bgColor = Colors.white;
          Color borderColor = const Color(0xFFE0E0E0);
          Color textColor = const Color(0xFF333333);
          Widget? trailingIcon;

          if (submitted) {
            if (isCorrect) {
              bgColor = const Color(0xFFE8F5E9);
              borderColor = const Color(0xFF58CC02);
              textColor = const Color(0xFF2E7D32);
              trailingIcon = const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF58CC02), size: 22);
            } else if (isSelected && !isCorrect) {
              bgColor = const Color(0xFFFDECEC);
              borderColor = Colors.redAccent;
              textColor = const Color(0xFFC62828);
              trailingIcon = const Icon(Icons.cancel_rounded,
                  color: Colors.redAccent, size: 22);
            }
          } else if (isSelected) {
            bgColor = const Color(0xFFE3F2FD);
            borderColor = const Color(0xFF2196F3);
            textColor = const Color(0xFF1976D2);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: onSelect != null ? () => onSelect!(optIndex) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected || (submitted && isCorrect)
                            ? borderColor
                            : const Color(0xFFF0F0F0),
                      ),
                      child: Center(
                        child: Text(
                          ['A', 'B', 'C', 'D'][optIndex],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected || (submitted && isCorrect)
                                ? Colors.white
                                : const Color(0xFF888888),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        question.options[optIndex],
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (trailingIcon != null) ...[
                      const SizedBox(width: 8),
                      trailingIcon,
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
