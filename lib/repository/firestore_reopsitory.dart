import 'package:cloud_firestore/cloud_firestore.dart';

class FireStoreRepository {
  final fireStore = FirebaseFirestore.instance;
  Future<List<DocumentSnapshot>> fetchFirstList() async {
    return (await fireStore.collection("contacts").orderBy("email").limit(10).get()).docs;
  }

  Future<List<DocumentSnapshot>> fetchNextList(List<DocumentSnapshot> documentList) async {
    return (await fireStore
            .collection("contacts")
            .orderBy("email")
            .startAfterDocument(documentList[documentList.length - 1])
            .limit(10)
            .get())
        .docs;
  }
}
