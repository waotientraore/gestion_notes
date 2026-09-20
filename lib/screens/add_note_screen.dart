import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/database_manager.dart';
import '../utils/constants.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _errorMessage;

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      setState(
        () => _errorMessage = 'Le titre et le contenu sont obligatoires.',
      );
      return;
    }

    try {
      await DatabaseManager.instance.insertNote(
        Note(
          title: title,
          content: content,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _errorMessage = 'Erreur lors de l\'enregistrement.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle note')),
      body: Padding(
        padding: AppConstants.screenPadding,
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: AppConstants.inputDecoration('Titre'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: AppConstants.inputDecoration('Contenu'),
              maxLines: 5,
            ),
            const SizedBox(height: 8),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveNote,
                    child: const Text('Enregistrer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
