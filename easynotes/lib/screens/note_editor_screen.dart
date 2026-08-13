import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../utils/app_colors.dart';
import '../utils/date_formatter.dart';
import '../widgets/color_picker_palette.dart';
import '../widgets/delete_dialog.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note note;

  const NoteEditorScreen({super.key, required this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late Note _currentNote;
  Timer? _debounceTimer;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentNote = widget.note;
    _titleController = TextEditingController(text: _currentNote.title);
    _contentController = TextEditingController(text: _currentNote.content);

    // Listen to changes to trigger auto-save
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _saveNoteImmediate(); // Flush save on screen exit
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _saveNoteImmediate();
    });
  }

  Future<void> _saveNoteImmediate() async {
    if (!mounted) return;
    setState(() => _isSaving = true);

    _currentNote.title = _titleController.text;
    _currentNote.content = _contentController.text;

    final noteService = Provider.of<NoteService>(context, listen: false);
    await noteService.saveNote(_currentNote);

    if (mounted) {
      setState(() => _isSaving = false);
    }
  }

  void _togglePin() {
    setState(() {
      _currentNote.isPinned = !_currentNote.isPinned;
    });
    _saveNoteImmediate();
  }

  void _changeColor(int index) {
    setState(() {
      _currentNote.colorIndex = index;
    });
    _saveNoteImmediate();
  }

  void _addTagDialog() {
    final tagController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Tag'),
          content: TextField(
            controller: tagController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'e.g. ideas, work, groceries',
              prefixText: '#',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final tag = tagController.text.trim().replaceAll('#', '');
                if (tag.isNotEmpty && !_currentNote.tags.contains(tag)) {
                  setState(() {
                    _currentNote.tags.add(tag);
                  });
                  _saveNoteImmediate();
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorList = isDark ? AppColors.noteColorsDark : AppColors.noteColorsLight;
    final bgColor = colorList[_currentNote.colorIndex];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Auto-save indicator
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),

          // Pin toggle
          IconButton(
            icon: Icon(
              _currentNote.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: _currentNote.isPinned
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
            tooltip: _currentNote.isPinned ? 'Unpin' : 'Pin to top',
            onPressed: _togglePin,
          ),

          // Add Tag
          IconButton(
            icon: const Icon(Icons.label_outline),
            tooltip: 'Add Tag',
            onPressed: _addTagDialog,
          ),

          // Delete Note
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete Note',
            onPressed: () async {
              final confirmed = await DeleteNoteDialog.show(
                context,
                noteTitle: _titleController.text,
              );
              if (confirmed == true && mounted) {
                final noteService = Provider.of<NoteService>(context, listen: false);
                await noteService.deleteNote(_currentNote.id);
                if (mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Input
                    TextField(
                      controller: _titleController,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Note Title',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                          fontWeight: FontWeight.w700,
                        ),
                        border: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Timestamp & word stats bar
                    Row(
                      children: [
                        Text(
                          AppDateFormatter.formatFullDate(_currentNote.updatedAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_contentController.text.length} chars • ${_currentNote.wordCount} words',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    // Tags list (if any)
                    if (_currentNote.tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: _currentNote.tags.map((tag) {
                          return Chip(
                            label: Text('#$tag'),
                            deleteIcon: const Icon(Icons.close, size: 14),
                            onDeleted: () {
                              setState(() {
                                _currentNote.tags.remove(tag);
                              });
                              _saveNoteImmediate();
                            },
                          );
                        }).toList(),
                      ),
                    ],

                    const Divider(height: 24),

                    // Content Input
                    TextField(
                      controller: _contentController,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: isDark ? Colors.grey[200] : Colors.black87,
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Start typing your note...',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                        ),
                        border: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Toolbar with Color Picker
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1B24) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ColorPickerPalette(
                    selectedColorIndex: _currentNote.colorIndex,
                    onColorSelected: _changeColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}