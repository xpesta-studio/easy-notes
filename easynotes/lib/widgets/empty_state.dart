import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final bool isSearch;
  final VoidCallback? onAddNotePressed;

  const EmptyStateWidget({
    super.key,
    this.isSearch = false,
    this.onAddNotePressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: isDark
                    ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.25)
                    : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSearch ? Icons.search_off_rounded : Icons.note_alt_outlined,
                size: 54,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isSearch ? 'No notes matched' : 'Your notebook is empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.grey[200] : Colors.grey[900],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              isSearch
                  ? 'Try searching with different keywords or clear the filter.'
                  : 'Capture your thoughts, daily plans, and checklists. Tap the button below to write your first note.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (!isSearch && onAddNotePressed != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAddNotePressed,
                icon: const Icon(Icons.add),
                label: const Text('Create Note'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}