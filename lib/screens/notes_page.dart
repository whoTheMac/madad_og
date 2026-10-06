import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:madad/screens/dashboard_screen.dart';


import 'package:speech_to_text/speech_to_text.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:translator/translator.dart';

// ============================================================
// NOTE MODEL
// ============================================================

class Note {
  String? id;
  String title;
  String content;
  DateTime lastEdited;

  Note({
    this.id,
    required this.title,
    required this.content,
    required this.lastEdited,
  });

  factory Note.fromMap(Map<String, dynamic> map) {
    final contentData = map['content'];

    return Note(
      id: map['id']?.toString(),
      title: map['title']?.toString() ?? 'Untitled Note',
      content: jsonEncode(contentData ?? <dynamic>[]),
      lastEdited:
      DateTime.tryParse(map['last_edited']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

// ============================================================
// NOTES PAGE
// ============================================================

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<Note> notes = [];
  bool loading = true;
  int _selectedBarIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        if (mounted) {
          setState(() => loading = false);
        }
        return;
      }

      final data = await supabase
          .from('notys')
          .select()
          .eq('user_id', user.id)
          .order('last_edited', ascending: false);

      final loaded = (data as List)
          .map(
            (item) => Note.fromMap(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();

      if (!mounted) return;

      setState(() {
        notes = loaded;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load notes: $e'),
        ),
      );
    }
  }

  Future<void> _createNote() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login first.'),
        ),
      );
      return;
    }

    try {
      final data = await supabase
          .from('notys')
          .insert({
        'user_id': user.id,
        'title': 'Untitled Note',
        'content': <dynamic>[],
        'last_edited': DateTime.now().toIso8601String(),
      })
          .select()
          .single();

      final note = Note.fromMap(
        Map<String, dynamic>.from(data),
      );

      if (!mounted) return;

      setState(() {
        notes.insert(0, note);
      });

      _openNote(note);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not create note: $e'),
        ),
      );
    }
  }

  void _openNote(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotePage(
          note: note,
          onSave: _loadNotes,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _getPreview(String content) {
    try {
      final decoded = jsonDecode(content);

      final document = Document.fromJson(
        List<dynamic>.from(decoded),
      );

      final text = document.toPlainText().trim();

      return text.isEmpty ? 'No content yet...' : text;
    } catch (_) {
      return 'No content yet...';
    }
  }

  // Determines color pattern:
  // Index % 3 == 0 -> Light Brown
  // Index % 3 == 1 -> Transparent Grey
  // Index % 3 == 2 -> Black
  Color _getNoteCardColor(int index) {
    final patternIndex = index % 3;
    switch (patternIndex) {
      case 0:
        return const Color(0xffd5aca5); // frst box clr
      case 1:
        return const Color(0xCF594e4c).withValues(); // Transparent Grey
      case 2:
        return const Color(0xFF1C1C1E); // Black
      default:
        return const Color(0xFFD7C4B7);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      extendBody: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Notes',
                        style: GoogleFonts.pacifico(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F0E11),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Your thoughts, beautifully kept.',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF77727C),
                          fontFamily: Platform.isIOS ? 'Courier' : 'monospace',
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: _createNote,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF977272),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF000000).withOpacity(0.25),
                            blurRadius: 15,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Expanded(
                child: loading
                    ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF977272),
                  ),
                )
                    : notes.isEmpty
                    ? const Center(
                  child: Text(
                    'No notes yet.\nTap + to create one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
                    : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 30),
                  itemCount: notes.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 18),
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    final cardColor = _getNoteCardColor(index);
                    final isBlackCard = (index % 3 == 2);

                    // Adapt text colors based on card background
                    final titleColor = isBlackCard
                        ? Colors.white
                        : const Color(0xFF29252D);
                    final bodyColor = isBlackCard
                        ? Colors.white.withOpacity(0.7)
                        : Colors.black.withOpacity(0.55);
                    final dateColor = isBlackCard
                        ? Colors.white.withOpacity(0.5)
                        : Colors.black.withOpacity(0.45);

                    return GestureDetector(
                      onTap: () => _openNote(note),
                      child: Container(
                        height: 155,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                note.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w700,
                                  color: titleColor,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _getPreview(note.content),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                  color: bodyColor,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Last edited '
                                    '${_formatDate(note.lastEdited)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: dateColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(

        color: Colors.grey[900]!, // Changed background color to black
        child: SafeArea(
          top: false,
          bottom: false, // Set to false to let the black fill all the way to the bottom edge
          child: SnakeNavigationBar.color(
            backgroundColor: Colors.grey[900]!,
            behaviour: SnakeBarBehaviour.floating,
            snakeShape: SnakeShape.circle,
            snakeViewColor:Color(0xFF977272),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            currentIndex: _selectedBarIndex,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.search), label: 'Search'),
              BottomNavigationBarItem(icon: Icon(Icons.add_box), label: 'Post'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.notifications), label: 'Alert'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Profile'),
            ],
            onTap: (index) {
              setState(() {
                _selectedBarIndex = index;
              });

              if (index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

// ============================================================
// NOTE EDITOR PAGE
// ============================================================

class NotePage extends StatefulWidget {
  final Note note;
  final VoidCallback onSave;

  const NotePage({
    super.key,
    required this.note,
    required this.onSave,
  });

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  late QuillController _controller;
  late TextEditingController _titleController;

  late FocusNode _editorFocusNode;
  late ScrollController _editorScrollController;

  TextSelection? _savedSelection;

  // ---------------- Speech-to-text ----------------
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;

  // Tracks where the current speech session started inserting text,
  // and how much text from that session is currently in the document,
  // so live partial results can replace themselves instead of stacking up.
  int _speechAnchor = 0;
  int _lastInsertedLength = 0;

  // ---------------- Translation ----------------
  final GoogleTranslator _translator = GoogleTranslator();
  bool _isTranslating = false;

  static const List<Map<String, String>> _translateLanguages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'es', 'name': 'Spanish'},
    {'code': 'fr', 'name': 'French'},
    {'code': 'de', 'name': 'German'},
    {'code': 'ar', 'name': 'Arabic'},
    {'code': 'ml', 'name': 'Malayalam'},
  ];

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.note.title,
    );

    _editorFocusNode = FocusNode();
    _editorScrollController = ScrollController();

    Document document;

    try {
      final decoded = jsonDecode(widget.note.content);

      if (decoded is List && decoded.isNotEmpty) {
        document = Document.fromJson(
          List<dynamic>.from(decoded),
        );
      } else {
        document = Document();
      }
    } catch (_) {
      document = Document();
    }

    _controller = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
    );

    _initSpeech();
  }

  @override
  void dispose() {
    if (_speechToText.isListening) {
      _speechToText.stop();
    }
    _titleController.dispose();
    _controller.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  // ==========================================================
  // SAVE
  // ==========================================================

  Future<void> _saveNote() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) return;

      final title = _titleController.text.trim().isEmpty
          ? 'Untitled Note'
          : _titleController.text.trim();

      final delta = _controller.document.toDelta().toJson();
      final now = DateTime.now();

      final updateData = {
        'title': title,
        'content': delta,
        'last_edited': now.toIso8601String(),
      };

      if (widget.note.id != null) {
        await supabase
            .from('notys')
            .update(updateData)
            .eq('id', widget.note.id!)
            .eq('user_id', user.id);
      } else {
        final inserted = await supabase
            .from('notys')
            .insert({
          ...updateData,
          'user_id': user.id,
        })
            .select()
            .single();

        widget.note.id = inserted['id'].toString();
      }

      widget.note.title = title;
      widget.note.content = jsonEncode(delta);
      widget.note.lastEdited = now;

      widget.onSave();

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not save note: $e'),
        ),
      );
    }
  }

  // ==========================================================
  // FORMATTING
  // ==========================================================

  void _toggleAttribute(Attribute<dynamic> attribute) {
    final selection = _controller.selection;

    if (!selection.isValid || selection.start == selection.end) {
      return;
    }

    final style = _controller.getSelectionStyle();

    final isApplied = style.containsKey(attribute.key);

    final format = isApplied
        ? Attribute.fromKeyValue(attribute.key, null)
        : attribute;

    _controller.formatText(
      selection.start,
      selection.end - selection.start,
      format,
    );
  }

  void _toggleBold() {
    _toggleAttribute(Attribute.bold);
  }

  void _toggleItalic() {
    _toggleAttribute(Attribute.italic);
  }

  void _toggleUnderline() {
    _toggleAttribute(Attribute.underline);
  }

  // ==========================================================
  // COLORS
  // ==========================================================

  void _applyColor(
      Color color, {
        required bool highlight,
      }) {
    final selection = _savedSelection ?? _controller.selection;

    if (!selection.isValid || selection.start == selection.end) {
      return;
    }

    final hex = _colorToHex(color);
    final key = highlight ? 'background' : 'color';

    final attribute = Attribute.fromKeyValue(key, hex);

    _controller.formatText(
      selection.start,
      selection.end - selection.start,
      attribute,
    );

    _controller.updateSelection(
      selection,
      ChangeSource.local,
    );

    _savedSelection = null;
  }

  void _showColorPicker({
    required bool highlight,
  }) {
    final selection = _controller.selection;

    if (!selection.isValid || selection.start == selection.end) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select some text first.'),
        ),
      );
      return;
    }

    _savedSelection = selection;

    final colors = highlight
        ? [
      const Color(0xFFFFF0A8),
      const Color(0xFFFFC8D3),
      const Color(0xFFFFC9D6),
      const Color(0xFFCFF5DC),
      const Color(0xFFE5D4FF),
    ]
        : [
      const Color(0xFF29252D),
      const Color(0xFF6C63FF),
      const Color(0xFFFF5C77),
      const Color(0xFF2878FF),
      const Color(0xFF22A06B),
      const Color(0xFFE58A00),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFFE5d8ca),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                highlight ? 'Highlight Color' : 'Text Color',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 25),
              Wrap(
                spacing: 18,
                runSpacing: 15,
                children: colors.map((color) {
                  return GestureDetector(
                    onTap: () {
                      _applyColor(
                        color,
                        highlight: highlight,
                      );

                      Navigator.pop(sheetContext);
                    },
                    child: Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 25),
            ],
          ),
        );
      },
    );
  }

  String _colorToHex(Color color) {
    final value = color.value.toRadixString(16).padLeft(8, '0');
    return '#${value.substring(2)}';
  }

  // ==========================================================
  // SPEECH TO TEXT
  // ==========================================================

  Future<void> _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onStatus: (status) {
        debugPrint('SPEECH STATUS: $status');
        if (status == 'notListening' || status == 'done') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (error) {
        debugPrint('SPEECH ERROR: $error');
        if (mounted) setState(() => _isListening = false);
      },
    );

    debugPrint('SPEECH ENABLED: $_speechEnabled');

    if (mounted) setState(() {});
  }

  int _clampToDocument(int index) {
    final maxIndex = _controller.document.length - 1;
    if (maxIndex < 0) return 0;
    return index.clamp(0, maxIndex);
  }

  Future<void> _startListening() async {
    if (!_speechEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speech recognition is not available.'),
        ),
      );
      return;
    }

    final currentSelection = _controller.selection;
    _speechAnchor = currentSelection.isValid
        ? _clampToDocument(currentSelection.baseOffset)
        : _clampToDocument(_controller.document.length - 1);
    _lastInsertedLength = 0;

    setState(() => _isListening = true);

    final started = await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: 'en_US',
    );
    debugPrint('SPEECH LISTEN CALL RETURNED: $started');
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
  }

  void _onSpeechResult(result) {
    final recognized = result.recognizedWords as String;

    debugPrint('SPEECH RESULT: "$recognized" (final: ${result.finalResult})');

    _controller.replaceText(
      _speechAnchor,
      _lastInsertedLength,
      recognized,
      TextSelection.collapsed(offset: _speechAnchor + recognized.length),
    );

    _lastInsertedLength = recognized.length;
  }

  // ==========================================================
  // TRANSLATE NOTE
  // ==========================================================

  void _showTranslatePicker() {
    if (_isTranslating) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFFe5d8ca),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Translate Note To',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 15),
              ..._translateLanguages.map((lang) {
                return ListTile(
                  title: Text(lang['name']!),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _translateNote(lang['code']!);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Future<void> _translateNote(String targetLangCode) async {
    final plainText = _controller.document.toPlainText().trim();

    if (plainText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nothing to translate yet.'),
        ),
      );
      return;
    }

    setState(() => _isTranslating = true);

    try {
      final translation = await _translator.translate(
        plainText,
        to: targetLangCode,
      );

      final translatedText = translation.text;

      final docLength = _controller.document.length;

      _controller.replaceText(
        0,
        docLength - 1,
        translatedText,
        TextSelection.collapsed(offset: translatedText.length),
      );
    } catch (e) {
      debugPrint('TRANSLATE ERROR: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Translation failed: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isTranslating = false);
    }
  }

  String _formatEditorDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5d8ca),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF29252D),
          ),
          onPressed: _saveNote,
        ),
        title: const Text(
          'Edit Note',
          style: TextStyle(
            color: Color(0xFF100F0F),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _saveNote,
            icon: const Icon(
              Icons.check_rounded,
              color: Color(0xFF977272),
              size: 28,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 10, 25, 0),
            child: TextField(
              controller: _titleController,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Color(0xFF29252D),
              ),
              decoration: const InputDecoration(
                hintText: 'Note title',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Color(0xFFB7B3BA),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Last edited ${_formatEditorDate(widget.note.lastEdited)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withOpacity(0.35),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),

          // TOOLBAR
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  IconButton(
                    onPressed: _toggleBold,
                    icon: const Icon(
                      Icons.format_bold_rounded,
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleItalic,
                    icon: const Icon(
                      Icons.format_italic_rounded,
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleUnderline,
                    icon: const Icon(
                      Icons.format_underlined_rounded,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    width: 1,
                    height: 25,
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  const SizedBox(width: 5),
                  IconButton(
                    onPressed: () {
                      _showColorPicker(highlight: false);
                    },
                    icon: const Icon(
                      Icons.format_color_text_rounded,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _showColorPicker(highlight: true);
                    },
                    icon: const Icon(
                      Icons.highlight_rounded,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    width: 1,
                    height: 25,
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  const SizedBox(width: 5),
                  IconButton(
                    onPressed: _isListening ? _stopListening : _startListening,
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none_rounded,
                      color: _isListening ? Colors.redAccent : null,
                    ),
                  ),
                  IconButton(
                    onPressed: _isTranslating ? null : _showTranslatePicker,
                    icon: _isTranslating
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.translate_rounded),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // EDITOR
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Color(0xFF977272),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: QuillEditor.basic(
                controller: _controller,
                focusNode: _editorFocusNode,
                scrollController: _editorScrollController,
              ),
            ),
          ),
        ],
      ),
    );
  }
}