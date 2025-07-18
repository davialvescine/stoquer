import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import '../models/item_model.dart';
import '../models/asset_model.dart';
import '../models/category_model.dart';
import '../models/location_model.dart';
import '../models/kit_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  String get _userId => _auth.currentUser?.uid ?? '';

  // Métodos para Items
  Future<void> addItem(Item item) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('items')
          .add(item.toMap());
    } catch (e) {
      _logger.e('Erro ao adicionar item', error: e);
      rethrow;
    }
  }

  Future<void> updateItem(Item item) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('items')
          .doc(item.id)
          .update(item.toMap());
    } catch (e) {
      _logger.e('Erro ao atualizar item', error: e);
      rethrow;
    }
  }

  Future<void> deleteItem(String itemId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('items')
          .doc(itemId)
          .delete();
    } catch (e) {
      _logger.e('Erro ao deletar item', error: e);
      rethrow;
    }
  }

  Stream<List<Item>> getItems() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('items')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Item.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Métodos para Assets
  Future<void> addAsset(Asset asset) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('assets')
          .add(asset.toMap());
    } catch (e) {
      _logger.e('Erro ao adicionar asset', error: e);
      rethrow;
    }
  }

  Future<void> updateAsset(Asset asset) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('assets')
          .doc(asset.id)
          .update(asset.toMap());
    } catch (e) {
      _logger.e('Erro ao atualizar asset', error: e);
      rethrow;
    }
  }

  Future<void> deleteAsset(String assetId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('assets')
          .doc(assetId)
          .delete();
    } catch (e) {
      _logger.e('Erro ao deletar asset', error: e);
      rethrow;
    }
  }

  Stream<List<Asset>> getAssets() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('assets')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Asset.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Métodos para Categories
  Future<void> addCategory(Category category) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('categories')
          .add(category.toMap());
    } catch (e) {
      _logger.e('Erro ao adicionar categoria', error: e);
      rethrow;
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('categories')
          .doc(category.id)
          .update(category.toMap());
    } catch (e) {
      _logger.e('Erro ao atualizar categoria', error: e);
      rethrow;
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('categories')
          .doc(categoryId)
          .delete();
    } catch (e) {
      _logger.e('Erro ao deletar categoria', error: e);
      rethrow;
    }
  }

  Stream<List<Category>> getCategories() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('categories')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Category.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Métodos para Locations
  Future<void> addLocation(Location location) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('locations')
          .add(location.toMap());
    } catch (e) {
      _logger.e('Erro ao adicionar localização', error: e);
      rethrow;
    }
  }

  Future<void> updateLocation(Location location) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('locations')
          .doc(location.id)
          .update(location.toMap());
    } catch (e) {
      _logger.e('Erro ao atualizar localização', error: e);
      rethrow;
    }
  }

  Future<void> deleteLocation(String locationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('locations')
          .doc(locationId)
          .delete();
    } catch (e) {
      _logger.e('Erro ao deletar localização', error: e);
      rethrow;
    }
  }

  Stream<List<Location>> getLocations() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('locations')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Location.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Métodos para Kits
  Future<void> addKit(Kit kit) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('kits')
          .add(kit.toMap());
    } catch (e) {
      _logger.e('Erro ao adicionar kit', error: e);
      rethrow;
    }
  }

  Future<void> updateKit(Kit kit) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('kits')
          .doc(kit.id)
          .update(kit.toMap());
    } catch (e) {
      _logger.e('Erro ao atualizar kit', error: e);
      rethrow;
    }
  }

  Future<void> deleteKit(String kitId) async {
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('kits')
          .doc(kitId)
          .delete();
    } catch (e) {
      _logger.e('Erro ao deletar kit', error: e);
      rethrow;
    }
  }

  Stream<List<Kit>> getKits() {
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('kits')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Kit.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Método para obter estatísticas do dashboard
  Stream<Map<String, int>> getDashboardStats() {
    return getAssets().asyncMap((assets) async {
      final locations = await getLocations().first;
      final kits = await getKits().first;
      
      return {
        'totalAssets': assets.length,
        'loanedAssets': assets.where((asset) => asset.status == AssetStatus.emprestado).length,
        'locations': locations.length,
        'kits': kits.length,
      };
    });
  }
}