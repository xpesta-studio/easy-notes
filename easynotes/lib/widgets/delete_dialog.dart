import 'package:flutter/material.dart';

class DeleteNoteDialog extends StatelessWidget {
  final String noteTitle;

  const DeleteNoteDialog({
    super.key,
    required this.noteTitle,
  });

  static Future<bool?> show(BuildContext context, {required String noteTitle}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => DeleteNoteDialog(noteTitle: noteTitle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 36),
      title: const Text(
        'Delete Note?',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      content: Text(
        noteTitle.trim().isEmpty
            ? 'Are you sure you want to delete this untitled note? This action cannot be undone.'
            : 'Are you sure you want to delete "$noteTitle"? This action cannot be undone.',
        style: const TextStyle(fontSize: 14, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}