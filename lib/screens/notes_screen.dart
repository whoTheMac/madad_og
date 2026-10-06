import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/study_models.dart';

class NotesScreen extends StatelessWidget {
  final StudyNotes notes;

  const NotesScreen({super.key, required this.notes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Colors.white,
      appBar: AppBar(
        title: Text(
          notes.title,
          style: GoogleFonts.lora(
            color: Colors.black87,
            fontWeight: FontWeight.w600, // Optional: makes the Lora title pop a bit more
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87, // Changed from white so your icons/back button are visible!
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notes.sections.length,
        itemBuilder: (context, index) {
          final section = notes.sections[index];
          return Card(
            color: Color(0xFFEFCED2),
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heading
                  Text(
                    section.heading,
                    style: GoogleFonts.cinzel(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF977272),
                    ),
                  ),
                  if (section.subheading.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      section.subheading,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600], fontStyle: FontStyle.italic),
                    ),
                  ],
                  const Divider(height: 24),

                  // Keywords Highlight Chips
                  if (section.keywords.isNotEmpty) ...[
                    const Text('🔑 Key Terms', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: section.keywords.map((kw) => Chip(
                        label: Text(kw, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Color(0xFFe5d8ca),
                        padding: EdgeInsets.zero,
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Key Points
          const Text('📌 Key Points', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          ...section.keyPoints.map((point) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          const Text("• ", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF594e4c))),
          Expanded(
          child: Text(
          point,
          style: GoogleFonts.lora(
          fontSize: 15,
          height: 1.3,
          color: const Color(0xFF594e4c),
          ),
          ),
          ),
          ],
          ),
                  )),

                  // Sticky Notes / Formulas Container
                  if (section.stickyNotes.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ...section.stickyNotes.map((note) => Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFf2c6c2), // Classic sticky-note yellow
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFF977272)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.note_alt_outlined, size: 20, color: Color(0xFF977272)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              note,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF977272),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}