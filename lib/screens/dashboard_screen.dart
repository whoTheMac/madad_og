import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:madad/screens/notes_page.dart';
import '../models/study_models.dart';
import '../profile_page.dart';
import '../services/ai_study_service.dart';
import 'notes_screen.dart';
import 'exam_monster_screen.dart';
import 'flashcard_screen.dart';
import 'profile_plant_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AiStudyService _service = AiStudyService();
  bool _isLoading = false;
  String? _pdfUrl;
  int _userWaterDrops = 0;

  // Track selected index for the bottom navigation bar (Default to 2 for Post/Dashboard)
  int _selectedBarIndex = 2;

  Future<void> _handleUploadPdf() async {
    setState(() => _isLoading = true);
    try {
      _pdfUrl = await _service.uploadPdfAndGetUrl();
      if (_pdfUrl != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF Uploaded & Ready for AI Study!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateFeature(String action) async {
    if (_pdfUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a PDF first!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final data = await _service.processPdf(pdfUrl: _pdfUrl!, action: action);
      setState(() => _isLoading = false);

      if (!mounted) return;

      if (action == 'notes') {
        final notes = StudyNotes.fromJson(data);
        Navigator.push(context, MaterialPageRoute(builder: (_) => NotesScreen(notes: notes)));
      } else if (action == 'exam') {
        final rawQuestions = data['questions'] as List? ?? [];
        final questions = rawQuestions.map((q) => ExamQuestion.fromJson(q)).toList();

        Navigator.push(context, MaterialPageRoute(builder: (_) => ExamMonsterScreen(
          questions: questions,
          onQuizComplete: (earnedDrops) {
            setState(() {
              _userWaterDrops += earnedDrops;
            });
          },
        )));
      } else if (action == 'flashcards') {
        final rawCards = data['flashcards'] as List? ?? [];
        final flashcards = rawCards.map((fc) => FlashcardItem.fromJson(fc)).toList();

        Navigator.push(context, MaterialPageRoute(builder: (_) => FlashcardScreen(flashcards: flashcards)));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background for scaffold
      appBar: AppBar(
        backgroundColor: Colors.white, // White background for app bar
        foregroundColor: Colors.black,  // Dark text/icons
        elevation: 0,
        automaticallyImplyLeading: false, // Removes default top-left back/drawer icon
        title: const Text(
          'AI Study Hub',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // PDF Upload Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[100],
                foregroundColor: Colors.black87,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              onPressed: _handleUploadPdf,
              icon: const Icon(Icons.upload_file, color: Colors.indigo),
              label: Text(
                _pdfUrl == null ? 'Upload PDF Document' : 'PDF Uploaded (Change)',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 24),

            // 1. Notes Box (Shade 1: Light Rose Pink)
            _buildAestheticCard(
              title: 'Generate Structured Notes',
              subtitle: 'Summaries & Sticky Notes from PDF',
              icon: Icons.note_alt_rounded,
              cardColor: const Color(0xFFFFCCD5),
              textColor: const Color(0xFF881337),
              onTap: () => _navigateFeature('notes'),
            ),
            const SizedBox(height: 16),

            // 2. Exam Prep Box (Shade 2: Pastel Blush Pink)
            _buildAestheticCard(
              title: 'Exam Prep (Monster Battle)',
              subtitle: 'Test your knowledge & water your plant',
              icon: Icons.shield_rounded,
              cardColor: const Color(0xFFFFB3C1),
              textColor: const Color(0xFF50001D),
              onTap: () => _navigateFeature('exam'),
            ),
            const SizedBox(height: 16),

            // 3. Flashcards Box (Shade 3: Warm Soft Pink / Mauve)
            _buildAestheticCard(
              title: 'Interactive Flashcards',
              subtitle: 'Memorize key terms and concepts',
              icon: Icons.style_rounded,
              cardColor: const Color(0xFFFF8FA3),
              textColor: const Color(0xFF38040E),
              onTap: () => _navigateFeature('flashcards'),
            ),
          ],
        ),
      ),

      // Custom SnakeNavigationBar
      bottomNavigationBar: Container(
        color: Colors.grey[900]!,
        child: SafeArea(
          top: false,
          bottom: false,
          child: SnakeNavigationBar.color(
            backgroundColor: Colors.grey[900]!,
            behaviour: SnakeBarBehaviour.floating,
            snakeShape: SnakeShape.circle,
            snakeViewColor: const Color(0xFF977272),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            currentIndex: _selectedBarIndex,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
              BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Post'),
              BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alert'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
            onTap: (index) {
              setState(() {
                _selectedBarIndex = index;
              });

              if (index == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotesPage()),
                );
              }
              if (index == 4) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  // Helper widget to create aesthetic rectangular pink feature boxes
  Widget _buildAestheticCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color cardColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(20),
      elevation: 2,
      shadowColor: cardColor.withOpacity(0.4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: textColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: textColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: textColor, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}