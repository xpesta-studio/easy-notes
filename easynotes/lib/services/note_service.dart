import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../database/hive_service.dart';
import '../models/note.dart';

enum NoteSortOption {
  newest,
  oldest,
  recentlyUpdated,
  title,
  color,
}

enum NoteViewMode {
  staggeredGrid,
  list,
}

class NoteService extends ChangeNotifier {
  final HiveService hiveService;
  final _uuid = const Uuid();

  List<Note> _allNotes = [];
  String _searchQuery = '';
  String? _selectedTagFilter;
  NoteSortOption _sortOption = NoteSortOption.newest;
  NoteViewMode _viewMode = NoteViewMode.staggeredGrid;
  bool _isLoading = false;

  NoteService({required this.hiveService}) {
    loadNotes();
  }

  // Getters
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedTagFilter => _selectedTagFilter;
  NoteSortOption get sortOption => _sortOption;
  NoteViewMode get viewMode => _viewMode;

  /// Returns filtered and sorted notes based on active query and sort options
  List<Note> get notes {
    var list = List<Note>.from(_allNotes);

    // Apply search query filter
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((n) {
        final titleMatch = n.title.toLowerCase().contains(q);
        final contentMatch = n.content.toLowerCase().contains(q);
        final tagMatch = n.tags.any((t) => t.toLowerCase().contains(q));
        return titleMatch || contentMatch || tagMatch;
      }).toList();
    }

    // Apply tag filter
    if (_selectedTagFilter != null && _selectedTagFilter!.isNotEmpty) {
      list = list.where((n) => n.tags.contains(_selectedTagFilter)).toList();
    }

    // Apply sorting
    list.sort((a, b) {
      // Pinned notes always take top precedence
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;

      switch (_sortOption) {
        case NoteSortOption.newest:
          return b.createdAt.compareTo(a.createdAt);
        case NoteSortOption.oldest:
          return a.createdAt.compareTo(b.createdAt);
        case NoteSortOption.recentlyUpdated:
          return b.updatedAt.compareTo(a.updatedAt);
        case NoteSortOption.title:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        case NoteSortOption.color:
          return a.colorIndex.compareTo(b.colorIndex);
      }
    });

    return list;
  }

  /// Pinned notes list
  List<Note> get pinnedNotes => notes.where((n) => n.isPinned).toList();

  /// Other unpinned notes list
  List<Note> get otherNotes => notes.where((n) => !n.isPinned).toList();

  /// Total count of notes
  int get totalNotesCount => _allNotes.length;

  /// All unique tags across all notes
  List<String> get allTags {
    final tagsSet = <String>{};
    for (final note in _allNotes) {
      tagsSet.addAll(note.tags);
    }
    return tagsSet.toList()..sort();
  }

  /// Load notes from Hive
  void loadNotes() {
    _isLoading = true;
    notifyListeners();

    _allNotes = hiveService.getAllNotes();
    _isLoading = false;
    notifyListeners();
  }

  /// Create a new empty note draft
  Note createDraft() {
    final now = DateTime.now();
    return Note(
      id: _uuid.v4(),
      title: '',
      content: '',
      createdAt: now,
      updatedAt: now,
      colorIndex: 0,
      isPinned: false,
    );
  }

  /// Save or update note (handles auto-save gracefully)
  Future<void> saveNote(Note note) async {
    // If both title and content are blank, ignore or delete if empty
    if (note.title.trim().isEmpty && note.content.trim().isEmpty) {
      await deleteNote(note.id);
      return;
    }

    final existingIndex = _allNotes.indexWhere((n) => n.id == note.id);
    note.updatedAt = DateTime.now();

    if (existingIndex >= 0) {
      _allNotes[existingIndex] = note;
    } else {
      _allNotes.add(note);
    }

    await hiveService.saveNote(note);
    notifyListeners();
  }

  /// Delete note by ID
  Future<void> deleteNote(String id) async {
    _allNotes.removeWhere((n) => n.id == id);
    await hiveService.deleteNote(id);
    notifyListeners();
  }

  /// Toggle pin status
  Future<void> togglePin(String id) async {
    final noteIndex = _allNotes.indexWhere((n) => n.id == id);
    if (noteIndex >= 0) {
      final note = _allNotes[noteIndex];
      note.isPinned = !note.isPinned;
      note.updatedAt = DateTime.now();
      await hiveService.saveNote(note);
      notifyListeners();
    }
  }

  /// Update search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Set selected tag filter
  void setTagFilter(String? tag) {
    _selectedTagFilter = tag;
    notifyListeners();
  }

  /// Change sorting method
  void setSortOption(NoteSortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  /// Toggle Grid / List view mode
  void toggleViewMode() {
    _viewMode = _viewMode == NoteViewMode.staggeredGrid
        ? NoteViewMode.list
        : NoteViewMode.staggeredGrid;
    notifyListeners();
  }
}