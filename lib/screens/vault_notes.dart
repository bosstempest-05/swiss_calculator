import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// --- THE NOTE DATA MODEL ---
class VaultNote {
  String id;
  String title;
  String content;
  DateTime date;

  VaultNote({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
  });

  // Convert to JSON for local storage
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    'date': date.toIso8601String(),
  };

  // Convert from JSON back to a Note object
  factory VaultNote.fromMap(Map<String, dynamic> map) => VaultNote(
    id: map['id'],
    title: map['title'],
    content: map['content'],
    date: DateTime.parse(map['date']),
  );
}

// --- THE MAIN NOTES DASHBOARD ---
class VaultNotes extends StatefulWidget {
  const VaultNotes({super.key});

  @override
  State<VaultNotes> createState() => _VaultNotesState();
}

class _VaultNotesState extends State<VaultNotes> {
  List<VaultNote> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  // Load notes from local encrypted storage
  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notesJson = prefs.getString('vault_notes_data');

    if (notesJson != null) {
      final List<dynamic> decodedList = json.decode(notesJson);
      setState(() {
        _notes = decodedList.map((item) => VaultNote.fromMap(item)).toList();
        // Sort newest first
        _notes.sort((a, b) => b.date.compareTo(a.date));
      });
    }
    setState(() => _isLoading = false);
  }

  // Save notes to local storage
  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(
      _notes.map((note) => note.toMap()).toList(),
    );
    await prefs.setString('vault_notes_data', encodedData);
  }

  // The PANIC BUTTON logic
  Future<void> _wipeAllNotes() async {
    HapticFeedback.heavyImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('vault_notes_data');
    setState(() => _notes.clear());

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vault wiped clean.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _deleteNote(String id) {
    setState(() => _notes.removeWhere((note) => note.id == id));
    _saveNotes();
  }

  void _openEditor({VaultNote? existingNote}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteEditor(note: existingNote)),
    );

    if (result != null && result is VaultNote) {
      setState(() {
        if (existingNote != null) {
          final index = _notes.indexWhere((n) => n.id == existingNote.id);
          if (index != -1) _notes[index] = result;
        } else {
          _notes.insert(0, result);
        }
      });
      _saveNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ---> NEW: Adaptive theme colors for the notes dashboard <---
    bool isLightMode = Theme.of(context).brightness == Brightness.light;
    Color adaptiveBgColor = isLightMode
        ? Colors.grey[100]!
        : const Color(0xFF0A0A0A);
    Color adaptiveCardColor = isLightMode
        ? Colors.white
        : const Color(0xFF1A1A1A);
    Color adaptiveTextColor = isLightMode ? Colors.black87 : Colors.white;

    return Scaffold(
      backgroundColor: adaptiveBgColor,
      appBar: AppBar(
        title: Text('Secure Notes', style: TextStyle(color: adaptiveTextColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: adaptiveTextColor),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
              size: 28,
            ),
            tooltip: 'Panic Wipe',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: adaptiveCardColor,
                  title: const Text(
                    'BURN VAULT?',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    'This will permanently delete all secure notes. This action cannot be undone.',
                    style: TextStyle(color: adaptiveTextColor),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _wipeAllNotes();
                      },
                      child: const Text(
                        'WIPE',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.orangeAccent),
            )
          : _notes.isEmpty
          ? const Center(
              child: Text(
                'No secure notes.\nTap + to create one.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Card(
                  color: adaptiveCardColor,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      note.title.isEmpty ? 'Untitled Note' : note.title,
                      style: TextStyle(
                        color: adaptiveTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        note.content,
                        style: const TextStyle(color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    onTap: () => _openEditor(existingNote: note),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.grey,
                      ),
                      onPressed: () => _deleteNote(note.id),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orangeAccent,
        onPressed: () => _openEditor(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ), // Keeps icon white for contrast against orange
      ),
    );
  }
}

// --- THE EDITOR SCREEN ---
class NoteEditor extends StatefulWidget {
  final VaultNote? note;
  const NoteEditor({super.key, this.note});

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
  }

  void _save() {
    if (_titleController.text.trim().isEmpty &&
        _contentController.text.trim().isEmpty) {
      Navigator.pop(context);
      return;
    }

    final newNote = VaultNote(
      id: widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      date: DateTime.now(),
    );

    Navigator.pop(context, newNote);
  }

  @override
  Widget build(BuildContext context) {
    // ---> NEW: Adaptive theme colors for the editor <---
    bool isLightMode = Theme.of(context).brightness == Brightness.light;
    Color adaptiveBgColor = isLightMode
        ? Colors.grey[100]!
        : const Color(0xFF0A0A0A);
    Color adaptiveTextColor = isLightMode ? Colors.black87 : Colors.white;

    return Scaffold(
      backgroundColor: adaptiveBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: adaptiveTextColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.orangeAccent, size: 28),
            onPressed: _save,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: adaptiveTextColor,
              ),
              decoration: const InputDecoration(
                hintText: 'Title',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
            const Divider(color: Colors.grey),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: TextStyle(
                  fontSize: 18,
                  color: adaptiveTextColor,
                  height: 1.5,
                ),
                decoration: const InputDecoration(
                  hintText: 'Start typing...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
