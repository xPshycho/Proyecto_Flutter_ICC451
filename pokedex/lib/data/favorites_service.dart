import 'package:flutter/foundation.dart';
import '../data/models/pokemon.dart';

class FavoritesService with ChangeNotifier {
  final Set<int> _favorites = {};

  bool isFavorite(int id) => _favorites.contains(id);

  void toggleFavorite(Pokemon p) {
    if (_favorites.contains(p.id)) {
      _favorites.remove(p.id);
      p.isFavorite = false;
    } else {
      _favorites.add(p.id);
      p.isFavorite = true;
    }
    notifyListeners();
  }

  List<int> get all => _favorites.toList();
}

