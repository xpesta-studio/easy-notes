import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import 'note_card.dart';

class StaggeredNoteGrid extends StatelessWidget {
  final List<Note> notes;
  final NoteViewMode viewMode;
  final Function(Note) onNoteTap;
  final Function(Note) onPinToggle;
  final Function(Note) onLongPress;

  const StaggeredNoteGrid({
    super.key,
    required this.notes,
    required this.viewMode,
    required this.onNoteTap,
    required this.onPinToggle,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (viewMode == NoteViewMode.list) {
      return ListView.separated(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 90),
        itemCount: notes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final note = notes[index];
          return NoteCard(
            note: note,
            onTap: () => onNoteTap(note),
            onPinToggle: () => onPinToggle(note),
            onLongPress: () => onLongPress(note),
          );
        },
      );
    }

    return MasonryGridView.count(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 90),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return NoteCard(
          note: note,
          onTap: () => onNoteTap(note),
          onPinToggle: () => onPinToggle(note),
          onLongPress: () => onLongPress(note),
        );
      },
    );
  }
}