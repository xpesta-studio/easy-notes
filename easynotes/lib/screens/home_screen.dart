import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../services/theme_service.dart';
import '../services/premium_service.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/empty_state.dart';
import '../widgets/staggered_note_grid.dart';
import '../widgets/delete_dialog.dart';
import 'note_editor_screen.dart';
import 'settings_screen.dart';
import 'premium_subscription_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openNoteEditor(BuildContext context, [Note? note]) {
    final noteService = Provider.of<NoteService>(context, listen: false);
    final targetNote = note ?? noteService.createDraft();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(note: targetNote),
      ),
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    final noteService = Provider.of<NoteService>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Text(
                    'Sort Notes By',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Newest First (Default)'),
                  trailing: noteService.sortOption == NoteSortOption.newest
                      ? const Icon(Icons.check, color: Colors.purple)
                      : null,
                  onTap: () {
                    noteService.setSortOption(NoteSortOption.newest);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Oldest First'),
                  trailing: noteService.sortOption == NoteSortOption.oldest
                      ? const Icon(Icons.check, color: Colors.purple)
                      : null,
                  onTap: () {
                    noteService.setSortOption(NoteSortOption.oldest);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.update),
                  title: const Text('Recently Modified'),
                  trailing: noteService.sortOption == NoteSortOption.recentlyUpdated
                      ? const Icon(Icons.check, color: Colors.purple)
                      : null,
                  onTap: () {
                    noteService.setSortOption(NoteSortOption.recentlyUpdated);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sort_by_alpha),
                  title: const Text('Title (A-Z)'),
                  trailing: noteService.sortOption == NoteSortOption.title
                      ? const Icon(Icons.check, color: Colors.purple)
                      : null,
                  onTap: () {
                    noteService.setSortOption(NoteSortOption.title);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteService = context.watch<NoteService>();
    final themeService = context.watch<ThemeService>();
    final premiumService = context.watch<PremiumService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allNotes = noteService.notes;
    final pinned = noteService.pinnedNotes;
    final unpinned = noteService.otherNotes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Easy Notes'),
        actions: [
          // Upgrade to Premium Button
          IconButton(
            icon: Icon(
              premiumService.isPremium
                  ? Icons.workspace_premium_rounded
                  : Icons.auto_awesome_rounded,
              color: premiumService.isPremium ? Colors.amber : Theme.of(context).colorScheme.primary,
            ),
            tooltip: premiumService.isPremium ? 'Premium Active' : 'Upgrade to Premium',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PremiumSubscriptionScreen()),
              );
            },
          ),
          // Toggle Grid / List layout
          IconButton(
            icon: Icon(
              noteService.viewMode == NoteViewMode.staggeredGrid
                  ? Icons.view_agenda_outlined
                  : Icons.grid_view_rounded,
            ),
            tooltip: 'Toggle Layout',
            onPressed: () => noteService.toggleViewMode(),
          ),
          // Sort Options
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sort Notes',
            onPressed: () => _showSortBottomSheet(context),
          ),
          // Settings Screen
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchBarWidget(
              controller: _searchController,
              onChanged: (val) => noteService.setSearchQuery(val),
              onClear: () => noteService.setSearchQuery(''),
            ),
          ),

          // Tag Filters (if tags exist)
          if (noteService.allTags.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: const Text('All'),
                      selected: noteService.selectedTagFilter == null,
                      onSelected: (_) => noteService.setTagFilter(null),
                    ),
                  ),
                  ...noteService.allTags.map((tag) {
                    final isSelected = noteService.selectedTagFilter == tag;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text('#$tag'),
                        selected: isSelected,
                        onSelected: (selected) {
                          noteService.setTagFilter(selected ? tag : null);
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),

          // Body Content
          Expanded(
            child: allNotes.isEmpty
                ? EmptyStateWidget(
                    isSearch: noteService.searchQuery.isNotEmpty,
                    onAddNotePressed: () => _openNoteEditor(context),
                  )
                : StaggeredNoteGrid(
                    notes: allNotes,
                    viewMode: noteService.viewMode,
                    onNoteTap: (note) => _openNoteEditor(context, note),
                    onPinToggle: (note) => noteService.togglePin(note.id),
                    onLongPress: (note) async {
                      final confirmed = await DeleteNoteDialog.show(
                        context,
                        noteTitle: note.title,
                      );
                      if (confirmed == true) {
                        await noteService.deleteNote(note.id);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Note deleted')),
                          );
                        }
                      }
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNoteEditor(context),
        icon: const Icon(Icons.add),
        label: const Text('Note'),
      ),
    );
  }
}