import 'package:flutter/material.dart';
import 'app_colors.dart';

class _QuizQuestion {
  _QuizQuestion()
      : questionController = TextEditingController(),
        optionControllers = List.generate(4, (_) => TextEditingController()),
        correctIndex = 0;
  final TextEditingController questionController;
  final List<TextEditingController> optionControllers;
  int correctIndex;

  void dispose() {
    questionController.dispose();
    for (final c in optionControllers) {
      c.dispose();
    }
  }
}

/// Create Quiz Screen — title + class, add MCQ questions dynamically (each
/// with 4 options and a correct-answer selector), then publish. Matches
/// the CampusZ purple theme.
///
/// NOTE: Pure UI with local state only. Wire `_publishQuiz()` to save a
/// QuizModel + questions to Firestore once the backend is ready.
class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({super.key});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  static const Color primaryIndigo = Color(0xFF4A5AE8);
  static const Color gradientStart = Color(0xFF6C4CE0);
  static const Color gradientEnd = Color(0xFF3D5AE0);

  final List<String> _classes = const ['Data Structures', 'Database Systems', 'Algorithms', 'Operating Systems'];
  int _selectedClass = 0;
  final TextEditingController _quizTitleController = TextEditingController();
  final List<_QuizQuestion> _questions = [_QuizQuestion()];

  @override
  void dispose() {
    _quizTitleController.dispose();
    for (final q in _questions) {
      q.dispose();
    }
    super.dispose();
  }

  void _addQuestion() => setState(() => _questions.add(_QuizQuestion()));

  void _removeQuestion(int index) {
    if (_questions.length == 1) return;
    setState(() {
      _questions[index].dispose();
      _questions.removeAt(index);
    });
  }

  void _publishQuiz() {
    if (_quizTitleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add a quiz title first')));
      return;
    }
    // TODO: save `_quizTitleController.text`, `_classes[_selectedClass]`, and
    // each question's text/options/correctIndex to Firestore here.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${_quizTitleController.text}" published to ${_classes[_selectedClass]}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  _label('Quiz Title'),
                  _buildTextField(_quizTitleController, 'e.g. Chapter 5 Quick Check'),
                  const SizedBox(height: 16),
                  _label('Class'),
                  _buildClassDropdown(),
                  const SizedBox(height: 20),
                  ...List.generate(_questions.length, (i) => _buildQuestionCard(i)),
                  const SizedBox(height: 8),
                  _buildAddQuestionButton(),
                ],
              ),
            ),
            _buildPublishBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.text(context), size: 18),
          ),
          Expanded(
            child: Text('Create Quiz',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.text(context))),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.text(context))),
  );

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: TextField(
        controller: controller,
        style: TextStyle(fontSize: 13, color: AppColors.text(context)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12.5, color: Colors.black38),
          contentPadding: const EdgeInsets.all(14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildClassDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          value: _selectedClass,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryIndigo),
          items: List.generate(
            _classes.length,
                (i) => DropdownMenuItem(value: i, child: Text(_classes[i], style: TextStyle(fontSize: 13, color: AppColors.text(context)))),
          ),
          onChanged: (val) => setState(() => _selectedClass = val ?? 0),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    final question = _questions[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.text(context).withOpacity(0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: primaryIndigo.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text('Q${index + 1}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: primaryIndigo)),
              ),
              const Spacer(),
              if (_questions.length > 1)
                InkWell(
                  onTap: () => _removeQuestion(index),
                  child: Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.text(context).withOpacity(0.35)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: question.questionController,
            style: TextStyle(fontSize: 13, color: AppColors.text(context)),
            decoration: InputDecoration(
              hintText: 'Enter your question...',
              hintStyle: const TextStyle(fontSize: 12.5, color: Colors.black38),
              filled: true,
              fillColor: AppColors.bg(context),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(4, (optIndex) {
            final isCorrect = question.correctIndex == optIndex;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => setState(() => question.correctIndex = optIndex),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCorrect ? const Color(0xFF3CBF7F) : Colors.transparent,
                        border: Border.all(color: isCorrect ? Color(0xFF3CBF7F) : AppColors.text(context).withOpacity(0.25), width: 1.5),
                      ),
                      child: isCorrect ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: question.optionControllers[optIndex],
                      style: TextStyle(fontSize: 12.5, color: AppColors.text(context)),
                      decoration: InputDecoration(
                        hintText: 'Option ${optIndex + 1}',
                        hintStyle: const TextStyle(fontSize: 12, color: Colors.black38),
                        filled: true,
                        fillColor: AppColors.bg(context),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          Text(
            'Tap a circle to mark the correct answer',
            style: TextStyle(fontSize: 10.5, color: AppColors.text(context).withOpacity(0.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddQuestionButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: _addQuestion,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: primaryIndigo.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: primaryIndigo.withOpacity(0.2), style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, color: primaryIndigo, size: 18),
            const SizedBox(width: 6),
            Text('Add Question', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: primaryIndigo)),
          ],
        ),
      ),
    );
  }

  Widget _buildPublishBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: AppColors.text(context).withOpacity(0.06), blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _publishQuiz,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ).copyWith(
            backgroundColor: WidgetStateProperty.all(Colors.transparent),
            shadowColor: WidgetStateProperty.all(Colors.transparent),
          ),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [gradientStart, gradientEnd]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Container(
              alignment: Alignment.center,
              width: double.infinity,
              height: 48,
              child: const Text('Publish Quiz',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ),
    );
  }
}