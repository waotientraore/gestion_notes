# Documentation du projet — Gestion de Notes

## 1. Présentation

**Nom du projet :** Gestion de Notes
**Objectif :** Application mobile permettant de se connecter, puis de créer, consulter, modifier et supprimer des notes personnelles, stockées localement.
**Technologies utilisées :** Flutter, Dart, SQLite (via `sqflite` et `sqflite_common_ffi_web` pour le web).

## 2. Architecture du projet

```
lib/
├── main.dart                  # Point d'entrée, configuration du thème
├── models/
│   └── note.dart              # Modèle de données Note
├── services/
│   └── database_manager.dart  # Toute la logique SQLite (CRUD)
├── screens/
│   ├── login_screen.dart      # Écran de connexion
│   ├── home_screen.dart       # Écran principal (liste + modification + suppression)
│   └── add_note_screen.dart   # Écran d'ajout d'une note
├── widgets/
│   └── note_card.dart         # Carte d'affichage d'une note
└── utils/
    └── constants.dart         # Couleurs, styles et textes réutilisés
```

- **`main.dart`** : démarre l'application et définit le thème global (couleurs, styles de boutons).
- **`models/`** : contient les classes représentant les données manipulées par l'app.
- **`services/`** : contient la logique d'accès aux données (ici, SQLite).
- **`screens/`** : un fichier par écran complet de l'application.
- **`widgets/`** : composants réutilisables entre plusieurs écrans.
- **`utils/`** : constantes et styles partagés, pour éviter la duplication de code.

## 3. Widgets Flutter principaux utilisés

- **`Scaffold`** : structure de base d'un écran (barre du haut, corps, bouton flottant).
- **`StatefulWidget` / `State`** : widgets dont l'affichage peut changer dans le temps.
- **`TextField` / `TextEditingController`** : champs de saisie et lecture de leur contenu.
- **`ListView.builder`** : liste défilante optimisée, ne construit que les éléments visibles.
- **`AlertDialog` / `showDialog`** : boîtes de dialogue (modification, confirmation de suppression).
- **`FloatingActionButton`** : bouton d'action principale (ajouter une note).
- **`SnackBar`** : notification temporaire en bas d'écran (ex : "Note supprimée.").

## 4. Navigation

```
LoginScreen
    │  (identifiants corrects)
    ▼
HomeScreen ──── FloatingActionButton "+" ────▶ AddNoteScreen
    │                                                │
    │◀───────────────── retour (Navigator.pop) ──────┘
    │
    ├── clic sur une note / crayon ──▶ AlertDialog "Modifier la note" (même écran)
    └── clic sur la corbeille ──▶ AlertDialog "Supprimer la note" (même écran)
```

- **`Navigator.pushReplacement`** : utilisé du Login vers l'accueil, pour empêcher un retour arrière vers l'écran de connexion.
- **`Navigator.push`** : utilisé pour ouvrir l'écran d'ajout (on peut revenir en arrière).
- **`Navigator.pop(context, valeur)`** : ferme l'écran ou la boîte de dialogue actuelle, et peut renvoyer un résultat à l'écran précédent.

## 5. Modèle Note

```dart
class Note {
  final int? id;         // null tant que la note n'est pas encore en base
  final String title;    // titre de la note
  final String content;  // contenu de la note
  final String createdAt; // date de création (format ISO8601)
}
```

- **`toMap()`** : convertit une `Note` en `Map<String, dynamic>`, format attendu par SQLite pour l'insertion/modification.
- **`fromMap()`** : convertit une ligne SQLite (`Map`) en objet `Note` utilisable dans l'application.

## 6. Base de données SQLite

**Table `notes` :**

| Colonne   | Type    | Détail                         |
|-----------|---------|---------------------------------|
| id        | INTEGER | Clé primaire, auto-incrémentée |
| title     | TEXT    | Obligatoire                    |
| content   | TEXT    | Obligatoire                    |
| createdAt | TEXT    | Date de création (ISO8601)     |

**Opérations CRUD :**

| Méthode Dart   | Requête SQL équivalente                        | Usage                          |
|----------------|--------------------------------------------------|---------------------------------|
| `insert()`     | `INSERT INTO notes (...) VALUES (...)`           | Ajouter une nouvelle note       |
| `query()`      | `SELECT * FROM notes ORDER BY createdAt DESC`     | Lire toutes les notes           |
| `update()`     | `UPDATE notes SET ... WHERE id = ?`               | Modifier une note existante     |
| `delete()`     | `DELETE FROM notes WHERE id = ?`                  | Supprimer une note              |

L'identifiant `id` est généré automatiquement par SQLite grâce à `INTEGER PRIMARY KEY AUTOINCREMENT` — l'application n'a jamais besoin de le calculer elle-même.

## 7. Authentification

L'authentification est **locale et simplifiée**, à des fins pédagogiques uniquement :
- Identifiants "en dur" dans le code (`admin` / `1234`).
- Aucune vérification côté serveur, aucun chiffrement du mot de passe.

⚠️ **Ceci n'est pas une authentification sécurisée de production.** Dans un vrai projet, il faudrait : un serveur d'authentification, des mots de passe hachés (jamais stockés en clair), et idéalement un protocole comme OAuth2 ou JWT.

## 8. Gestion des erreurs

Chaque opération sensible (accès à la base de données, sauvegarde) est entourée d'un bloc `try/catch` :

```dart
try {
  // opération pouvant échouer (ex : accès SQLite)
} catch (e) {
  // on affiche un message simple à l'utilisateur,
  // jamais l'erreur technique brute (e)
}
```

Les messages d'erreur sont affichés soit sous forme de texte rouge dans les formulaires (validation), soit via une `SnackBar` (erreurs techniques, confirmations).

## 9. Tests effectués

- Connexion avec identifiants corrects/incorrects.
- Ajout, modification, suppression de notes avec champs valides/invalides.
- Confirmation avant suppression.
- Persistance des données après rafraîchissement de la page (test web).
- Vérification avec `flutter analyze` (0 warning).

## 10. Difficultés rencontrées

| Problème | Cause | Solution |
|---|---|---|
| L'ajout de note restait bloqué sur le web, sans erreur | `sqflite_common_ffi_web` nécessite des fichiers binaires (`sqlite3.wasm`, `sqflite_sw.js`) absents du dossier `web/` | Exécuter `dart run sqflite_common_ffi_web:setup` |
| Chevauchement visuel entre les champs Titre/Contenu dans la boîte de modification | Absence d'espacement (`SizedBox`) et de bordure complète (`OutlineInputBorder`) entre les deux `TextField` | Ajout d'un `SizedBox(height: 16)` et de `border: OutlineInputBorder()` |
| Avertissement `use_build_context_synchronously` | Utilisation du `context` après une opération asynchrone sans vérification adaptée | Utilisation de `context.mounted` au lieu de `State.mounted` pour un `context` de boîte de dialogue |
