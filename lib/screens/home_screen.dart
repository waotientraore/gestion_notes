import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/database_manager.dart';
import '../widgets/note_card.dart';
import '../utils/constants.dart';
import 'add_note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _loadNotes() async {
    try {
      final notes = await DatabaseManager.instance.getNotes();
      setState(() => _notes = notes);
    } catch (e) {
      _showMessage('Impossible de charger les notes.');
    }
  }

  Future<void> _showEditDialog(Note note) async {
    final titleController = TextEditingController(text: note.title);
    final contentController = TextEditingController(text: note.content);
    String? errorMessage;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Modifier la note'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Titre',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: contentController,
                    decoration: const InputDecoration(
                      labelText: 'Contenu',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: () async {
                    final newTitle = titleController.text.trim();
                    final newContent = contentController.text.trim();
                    if (newTitle.isEmpty || newContent.isEmpty) {
                      setDialogState(
                        () => errorMessage = 'Champs obligatoires.',
                      );
                      return;
                    }
                    final dialogContext = context;
                    try {
                      await DatabaseManager.instance.updateNote(
                        Note(
                          id: note.id,
                          title: newTitle,
                          content: newContent,
                          createdAt: note.createdAt,
                        ),
                      );
                      if (dialogContext.mounted) Navigator.pop(dialogContext);
                      _loadNotes();
                    } catch (e) {
                      setDialogState(
                        () => errorMessage = 'Erreur lors de la modification.',
                      );
                    }
                  },
                  child: const Text('Enregistrer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la note'),
        content: Text('Voulez-vous vraiment supprimer "${note.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DatabaseManager.instance.deleteNote(note.id!);
        _loadNotes();
        _showMessage('Note supprimée.');
      } catch (e) {
        _showMessage('Erreur lors de la suppression.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appTitle)),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppConstants.primaryColor.withValues(alpha: 0.1),
            child: const Icon(
              Icons.note_alt_outlined,
              size: 60,
              color: AppConstants.primaryColor,
            ),
          ),
          Expanded(
            child: _notes.isEmpty
                ? const Center(child: Text('Aucune note pour le moment.'))
                : ListView.builder(
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      return NoteCard(
                        note: note,
                        onEdit: () => _showEditDialog(note),
                        onDelete: () => _confirmDelete(note),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddNoteScreen()),
          );
          if (result == true) _loadNotes();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
