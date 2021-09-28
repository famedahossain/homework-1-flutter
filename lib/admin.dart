import 'package:cloud_firestore/cloud_firestore.dart';
import 'driver.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _db = FirebaseFirestore.instance;

class Admin extends StatefulWidget {
  Admin({Key? key}) : super(key: key);

  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<Admin> {
  List<String> messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Fan Page"),
            actions: <Widget>[
              FlatButton(
                  onPressed: (){
                    add(context);
                  },
                  child: const Icon(Icons.add)
              )
            ]
        ),

        backgroundColor: Colors.white,

        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('messages').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return ListView(
              children: snapshot.data!.docs.map((document) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  height: 60,
                  color: Colors.lime,
                  child: Center(child: Text(document['message'])),
                );
              }).toList(),
            );
          },
        ),

        floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () {
                  signOut(context);
                },
                tooltip: 'Log out',
                child: const Icon(Icons.logout),
              ),
            ]
        )
    );
  }

  void signOut(BuildContext context) async {
    ScaffoldMessenger.of(context).clearSnackBars();
    await _auth.signOut();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('User logged out.')));
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (con) => AppDriver()));
  }

  final TextEditingController _textFieldController = TextEditingController();

  void add(BuildContext context) async{
    return showDialog(context: context,
        builder: (context){
          return AlertDialog(
            content: TextField(
              controller: _textFieldController,
              textInputAction: TextInputAction.go,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(hintText: "Enter message"),
            ),
            actions: <Widget>[
              OutlinedButton(
                  onPressed: (){
                    setState(() {
                      databased();
                      Navigator.pop(context);
                    });
                  },
                  child: Text('Post Message'))
            ],
          );
        });
  }

  Future<void> databased() async {
    _db
        .collection("messages")
        .doc()
        .set({
      "message": _textFieldController.text,
      "registration_deadline" : DateTime.now(),

    });
    setState(() {
      read();
    });
  }
  void read() async {
    FirebaseFirestore.instance.collection('messages')
        .get()
        .then((value) {
      if (value.size > 0 ) {
        value.docs.forEach((element) {
          messages.add(element["message"]);
        });
      }
    });
    setState(() {

    });
  }
}