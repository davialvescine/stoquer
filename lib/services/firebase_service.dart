import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/asset.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Assets Collection
  static CollectionReference get assetsCollection =>
      _firestore.collection('assets');

  // Auth Methods
  static User? get currentUser => _auth.currentUser;

  static Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      ('Erro no login: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Asset CRUD Operations
  static Future<List<Asset>> getAssets() async {
    try {
      QuerySnapshot snapshot = await assetsCollection.get();
      return snapshot.docs
          .map((doc) => Asset.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      ('Erro ao buscar ativos: $e');
      return [];
    }
  }

  static Future<bool> addAsset(Asset asset) async {
    try {
      await assetsCollection.doc(asset.id).set(asset.toMap());
      return true;
    } catch (e) {
      ('Erro ao adicionar ativo: $e');
      return false;
    }
  }

  static Future<bool> updateAsset(Asset asset) async {
    try {
      await assetsCollection.doc(asset.id).update(asset.toMap());
      return true;
    } catch (e) {
      ('Erro ao atualizar ativo: $e');
      return false;
    }
  }

  static Future<bool> deleteAsset(String assetId) async {
    try {
      await assetsCollection.doc(assetId).delete();
      return true;
    } catch (e) {
      ('Erro ao deletar ativo: $e');
      return false;
    }
  }

  // Storage Methods
  static Future<String?> uploadImage(String path, String fileName) async {
    try {
      Reference ref = _storage.ref().child('assets').child(fileName);
      UploadTask uploadTask = ref.putFile(File(path));
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      ('Erro no upload da imagem: $e');
      return null;
    }
  }
}