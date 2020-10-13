import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../blocs/contacts_bloc.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ContactsListBloc contactsListBloc;

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    contactsListBloc = ContactsListBloc();
    contactsListBloc.fetchFirstList();
    _scrollController.addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Follow.it"),
        centerTitle: true,
      ),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: contactsListBloc.contactsStream,
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return StreamBuilder<bool>(
              stream: contactsListBloc.showIndicatorStream,
                builder: (context,indicatorSnapShot){
                  if(indicatorSnapShot.data == true && snapshot.data.length<30)
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Center(child: CircularProgressIndicator(),)
                      ],
                    );

              return ListView.builder(
                itemCount:
                snapshot.data.length > 29 ? snapshot.data.length + 1 : snapshot.data.length,
                controller: _scrollController,
                itemBuilder: (context, index) {
                  Widget child;
                  if(index >= snapshot.data.length)
                    child = FlutterLogo(
                      size: 100,
                    );
                  else
                    child = Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(
                          snapshot.data[index]["full_name"],
                        ),
                        subtitle: Text(
                          snapshot.data[index]["email"],
                        ),
                      ),
                    );
                  return child;
                },
              );
            });
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  void _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      contactsListBloc.fetchNextContacts();
    }
  }
}
