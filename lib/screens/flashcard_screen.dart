import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/study_models.dart';

class FlashcardScreen extends StatelessWidget {
  final List<FlashcardItem> flashcards;

  const FlashcardScreen({super.key, required this.flashcards});

  @override
  Widget build(BuildContext context) {
    if (flashcards.isEmpty) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text("No flashcards available.")));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Interactive Flashcards',
          style: GoogleFonts.lora(
            color: Colors.black87,
            fontWeight: FontWeight.w600, // Optional: makes the Lora title pop a bit more
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87, // Changed from white so your icons/back button are visible!
      ),
      body: PageView.builder(
        itemCount: flashcards.length,
        controller: PageController(viewportFraction: 0.85),
        itemBuilder: (context, index) {
          final fc = flashcards[index];
          return Center(
            child: SizedBox(
              height: 400,
              child: FlipCard(
                direction: FlipDirection.HORIZONTAL,
                front: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: Color(0xFF977272),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('QUESTION (Tap to Flip)', style: TextStyle(color: Color(0xFFD7C4B7), fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          Text(fc.front, textAlign: TextAlign.center, style: GoogleFonts.lora(
                            color: Colors.black87,
                          ),),
                        ],
                      ),
                    ),
                  ),
                ),
                back: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: Color(0xFFD7C4B7),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('ANSWER', style: TextStyle(color: Color(0xFF977272), fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                      Text(
                        fc.back,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lora(
                          color: Colors.black87,
                        ),
                      ),]
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}