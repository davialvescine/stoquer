import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Logger _logger = Logger();

  Future<String?> uploadImage(File imageFile, {String? folder}) async {
    try {
      String fileName = '${const Uuid().v4()}.jpg';
      String path = folder != null ? '$folder/$fileName' : 'asset_images/$fileName';
      Reference ref = _storage.ref().child(path);
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      _logger.e("Erro ao fazer upload da imagem", error: e);
      return null;
    }
  }

  Future<List<String>> uploadMultipleImages(List<File> imageFiles, {String? folder}) async {
    List<String> uploadedUrls = [];
    
    for (File imageFile in imageFiles) {
      String? url = await uploadImage(imageFile, folder: folder);
      if (url != null) {
        uploadedUrls.add(url);
      }
    }
    
    return uploadedUrls;
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      _logger.i("Imagem deletada com sucesso");
    } catch (e) {
      _logger.e("Erro ao deletar imagem", error: e);
    }
  }
}
