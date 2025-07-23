import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
    await _auth.currentUser?.reload();
  }

  Future<void> updatePhotoUrl(String photoUrl) async {
    await _auth.currentUser?.updatePhotoURL(photoUrl);
    await _auth.currentUser?.reload();
  }

  String? getCurrentDisplayName() => _auth.currentUser?.displayName;
  String? getCurrentPhotoUrl() => _auth.currentUser?.photoURL;


  Future<void> saveItemForUser(Map<String, dynamic> item) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    final userId = user.uid;
    final docRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('saved_items')
      .doc(Uri.encodeComponent(item['link']));

    await docRef.set({
      'title': item['title'],
      'link': item['link'],
      'image': item['image'],
      'brand': item['brand'],
      'price': item['price'],
      'materials': item['materials'],
      'sustainability_score': item['sustainability_score'],
      'savedAt': FieldValue.serverTimestamp()
    });
  }

  Future<bool> isItemAlreadySaved(String link) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final itemId = Uri.encodeComponent(link);
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('saved_items')
        .doc(itemId)
        .get();

    return doc.exists;
  }

  Future<List<dynamic>> getUserSavedItems() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('saved_items')
      .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> removeSavedItem(String link) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    final itemId = Uri.encodeComponent(link);
    await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('saved_items')
      .doc(itemId)
      .delete();
  }
}
