import 'package:flutter/foundation.dart';
import '../models/asset.dart';
import '../services/firebase_service.dart';

class AssetProvider with ChangeNotifier {
  List<Asset> _assets = [];
  bool _isLoading = false;
  String _error = '';

  List<Asset> get assets => _assets;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadAssets() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _assets = await FirebaseService.getAssets();
    } catch (e) {
      _error = 'Erro ao carregar ativos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAsset(Asset asset) async {
    _isLoading = true;
    notifyListeners();

    try {
      bool success = await FirebaseService.addAsset(asset);
      if (success) {
        _assets.add(asset);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Erro ao adicionar ativo: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateAsset(Asset asset) async {
    try {
      bool success = await FirebaseService.updateAsset(asset);
      if (success) {
        int index = _assets.indexWhere((a) => a.id == asset.id);
        if (index != -1) {
          _assets[index] = asset;
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _error = 'Erro ao atualizar ativo: $e';
      return false;
    }
  }

  Future<bool> deleteAsset(String assetId) async {
    try {
      bool success = await FirebaseService.deleteAsset(assetId);
      if (success) {
        _assets.removeWhere((asset) => asset.id == assetId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = 'Erro ao deletar ativo: $e';
      return false;
    }
  }

  List<Asset> searchAssets(String query) {
    if (query.isEmpty) return _assets;
    
    return _assets.where((asset) {
      return asset.name.toLowerCase().contains(query.toLowerCase()) ||
             asset.description.toLowerCase().contains(query.toLowerCase()) ||
             asset.qrCode.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  List<Asset> filterByCategory(String category) {
    if (category == 'Todos') return _assets;
    return _assets.where((asset) => asset.category == category).toList();
  }
}