import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';
import 'boxes.dart';

class HiveService {
  Box<Note>? _notesBox;
  Box? _settingsBox;
  Box? _premiumBox;

  Box<Note> get notesBox {
    if (_notesBox == null || !_notesBox!.isOpen) {
      throw Exception('Notes box is not initialized or closed');
    }
    return _notesBox!;
  }

  Box get settingsBox {
    if (_settingsBox == null || !_settingsBox!.isOpen) {
      throw Exception('Settings box is not initialized or closed');
    }
    return _settingsBox!;
  }

  Box get premiumBox {
    if (_premiumBox == null || !_premiumBox!.isOpen) {
      throw Exception('Premium box is not initialized or closed');
    }
    return _premiumBox!;
  }

  /// Initializes Hive database and opens boxes
  Future<void> init() async {
    try {
      await Hive.initFlutter();
      
      // Register Adapter if not already registered
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(NoteAdapter());
      }

      _notesBox = await Hive.openBox<Note>(HiveBoxes.notesBox);
      _settingsBox = await Hive.openBox(HiveBoxes.settingsBox);
      _premiumBox = await Hive.openBox(HiveBoxes.premiumBox);

      // Seed initial sample notes if database is brand new
      if (_notesBox!.isEmpty) {
        await _seedInitialNotes();
      }
    } catch (e) {
      debugPrint('Error initializing Hive: $e');
      rethrow;
    }
  }

  /// Seed initial onboarding notes for first-time users
  Future<void> _seedInitialNotes() async {
    final now = DateTime.now();
    final sampleNotes = [
      Note(
        id: 'welcome-1',
        title: '✨ Welcome to Easy Notes!',
        content: 'Easy Notes is your fast, offline-first personal notebook designed with Material 3.\n\n• Everything is stored securely on your device.\n• Zero internet or permissions required.\n• Auto-saves every keystroke in real-time.\n• Tap the pin icon to keep important notes at top!',
        isPinned: true,
        colorIndex: 1, // Soft Indigo
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        tags: ['welcome', 'tips'],
      ),
      Note(
        id: 'welcome-2',
        title: '🎨 Custom Colors & Quick Search',
        content: 'You can customize note colors from the palette at the bottom of the editor.\n\nUse the search bar at the top to instantly find notes by title or keywords in content.',
        isPinned: false,
        colorIndex: 2, // Soft Mint
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        tags: ['features'],
      ),
      Note(
        id: 'welcome-3',
        title: '📋 Meeting Checklist Ideas',
        content: '1. Review roadmap deliverables\n2. Test performance on Android devices\n3. Verify dark mode contrast and accessibility\n4. Package production release APK / AppBundle',
        isPinned: false,
        colorIndex: 3, // Soft Amber
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
        tags: ['work', 'todo'],
      ),
    ];

    for (final note in sampleNotes) {
      await _notesBox!.put(note.id, note);
    }
  }

  /// Get all notes from Hive
  List<Note> getAllNotes() {
    try {
      return notesBox.values.toList();
    } catch (e) {
      debugPrint('Error fetching notes: $e');
      return [];
    }
  }

  /// Add or update a note
  Future<void> saveNote(Note note) async {
    try {
      await notesBox.put(note.id, note);
    } catch (e) {
      debugPrint('Error saving note: $e');
      rethrow;
    }
  }

  /// Delete note by ID
  Future<void> deleteNote(String id) async {
    try {
      await notesBox.delete(id);
    } catch (e) {
      debugPrint('Error deleting note: $e');
      rethrow;
    }
  }

  /// Toggle note pin status
  Future<void> togglePin(String id) async {
    try {
      final note = notesBox.get(id);
      if (note != null) {
        note.isPinned = !note.isPinned;
        note.updatedAt = DateTime.now();
        await note.save();
      }
    } catch (e) {
      debugPrint('Error toggling pin: $e');
      rethrow;
    }
  }

  /// Clear all notes (danger action)
  Future<void> clearAllNotes() async {
    await notesBox.clear();
  }
}