import 'package:flutter/material.dart';
import '../models/study_models.dart';

class ExamMonsterScreen extends StatefulWidget {
  final List<ExamQuestion> questions;
  final Function(int earnedDrops) onQuizComplete;

  const ExamMonsterScreen({super.key, required this.questions, required this.onQuizComplete});

  @override
  State<ExamMonsterScreen> createState() => _ExamMonsterScreenState();
}

class _ExamMonsterScreenState extends State<ExamMonsterScreen> {
  int currentIndex = 0;
  int monsterHp = 100;
  bool isFinished = false;
  String? selectedOption;
  bool answeredCurrent = false;

  void handleAnswer(String option) {
    if (answeredCurrent) return;
    setState(() {
      selectedOption = option;
      answeredCurrent = true;

      final currentQ = widget.questions[currentIndex];
      if (option.trim().toLowerCase() == currentQ.answer.trim().toLowerCase()) {
        // Deal damage to monster
        monsterHp -= (100 / widget.questions.length).round();
        if (monsterHp < 0) monsterHp = 0;
      }
    });

    Future.delayed(const Duration(seconds: 1500), () {
      if (!mounted) return;
      if (currentIndex < widget.questions.length - 1) {
        setState(() {
          currentIndex++;
          selectedOption = null;
          answeredCurrent = false;
        });
      } else {
        setState(() => isFinished = true);
        if (monsterHp == 0) {
          widget.onQuizComplete(1); // Award 1 water drop
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text("No questions generated.")));
    }

    if (isFinished) {
      return Scaffold(
        appBar: AppBar(title: const Text('Battle Complete!')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(monsterHp == 0 ? Icons.military_tech : Icons.sentiment_dissatisfied, size: 80, color: Colors.amber),
              const SizedBox(height: 16),
              Text(
                monsterHp == 0 ? '🎉 Monster Defeated!' : 'Fight Over!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                monsterHp == 0 ? 'You earned 💧 +1 Water Drop for your plant!' : 'Study more to defeat the beast next time!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Return to Hub'),
              ),
            ],
          ),
        ),
      );
    }

    final q = widget.questions[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text('Exam Prep (${currentIndex + 1}/${widget.questions.length})'), backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Monster Health Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  const Text('👾 Wild Study Beast HP', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: monsterHp / 100,
                    backgroundColor: Colors.grey[300],
                    color: Colors.redAccent,
                    minHeight: 12,
                  ),
                  const SizedBox(height: 6),
                  Text('$monsterHp / 100 HP', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Question Card
            Text(
              q.question,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Options List
            ...q.options.map((opt) {
              Color btnColor = Colors.white;
              Color textColor = Colors.black;
              if (answeredCurrent) {
                if (opt.trim().toLowerCase() == q.answer.trim().toLowerCase()) {
                  btnColor = Colors.green;
                  textColor = Colors.white;
                } else if (opt == selectedOption) {
                  btnColor = Colors.red;
                  textColor = Colors.white;
                }
              }

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnColor,
                    foregroundColor: textColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: answeredCurrent ? null : () => handleAnswer(opt),
                  child: Text(opt, style: const TextStyle(fontSize: 16)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}