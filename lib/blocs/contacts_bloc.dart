import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_pagination_app/repository/firestore_reopsitory.dart';
import 'package:rxdart/rxdart.dart';

class ContactsListBloc {
  FireStoreRepository fireStoreRepository;

  bool showIndicator = false;
  List<DocumentSnapshot> documentList;

  BehaviorSubject<List<DocumentSnapshot>> contactsStreamController;

  BehaviorSubject<bool> showIndicatorController;

  ContactsListBloc() {
    contactsStreamController = BehaviorSubject<List<DocumentSnapshot>>();
    showIndicatorController = BehaviorSubject<bool>();
    fireStoreRepository = FireStoreRepository();
  }

  Stream get showIndicatorStream => showIndicatorController.stream;

  Stream<List<DocumentSnapshot>> get contactsStream => contactsStreamController.stream;

 ///This method will automatically fetch first 10 elements from the document list
  Future fetchFirstList() async {
    try {
      documentList = await fireStoreRepository.fetchFirstList();
      contactsStreamController.sink.add(documentList);
      try {
        if (documentList.length == 0) {
          contactsStreamController.sink.addError("No Data Available");
        }
      } catch (e) {}
    } on SocketException {
      contactsStreamController.sink.addError(SocketException("No Internet Connection"));
    } catch (e) {
      print(e.toString());
      contactsStreamController.sink.addError(e);
    }
  }

///This will automatically fetch the next 10 elements from the list
  fetchNextContacts() async {
    Future.delayed(Duration(seconds: 1));
    try {
      updateIndicator(true);
      List<DocumentSnapshot> newDocumentList =
      await fireStoreRepository.fetchNextList(documentList);
      documentList.addAll(newDocumentList);
      contactsStreamController.sink.add(documentList);
      try {
        if (documentList.length == 0) {
          contactsStreamController.sink.addError("No Data Available");
          updateIndicator(false);
        }
      } catch (e) {
        updateIndicator(false);
      }
    } on SocketException {
      contactsStreamController.sink.addError(SocketException("No Internet Connection"));
      updateIndicator(false);
    } catch (e) {
      updateIndicator(false);
      print(e.toString());
      contactsStreamController.sink.addError(e);
    }
    updateIndicator(false);
  }

///For updating the indicator below every list and paginate
  updateIndicator(bool value) async {
    showIndicator = value;
    showIndicatorController.sink.add(value);
  }

  void dispose() {
    contactsStreamController.close();
    showIndicatorController.close();
  }
}
