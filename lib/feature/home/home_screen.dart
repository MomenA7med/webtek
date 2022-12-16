import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webteck/model/password_model.dart';

class HomeScreen extends StatelessWidget {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  CollectionReference users =
      FirebaseFirestore.instance.collection("passwords");
  final TextEditingController infoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _usersStream = users
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection("password")
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              PasswordModel passwordModel = PasswordModel.fromJson(data);
              return ListTile(
                title: Text(passwordModel.name!),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      child: const Icon(Icons.edit),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => _buildSheet(context,
                              edit: true,
                              passwordModel: passwordModel,
                              documentSnapshot: document),
                        );
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      onTap: () {
                        users
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection("password")
                            .doc(document.id)
                            .delete();
                      },
                      child: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) {
                return _buildSheet(context);
              },
            );
          },
          child: const Icon(Icons.add)),
    );
  }

  Widget _buildSheet(BuildContext context,
      {bool edit = false,
      PasswordModel? passwordModel,
      DocumentSnapshot? documentSnapshot}) {
    if (edit) {
      nameController.text = passwordModel?.name ?? "";
      userNameController.text = passwordModel?.userName ?? "";
      infoController.text = passwordModel?.info ?? "";
      passwordController.text = passwordModel?.password ?? "";
    }
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 10,
          left: 10,
          right: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: nameController,
              scrollPadding: EdgeInsets.only(bottom: 10),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person),
                hintText: "Enter Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: userNameController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.person),
                hintText: "Enter User Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: infoController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.email),
                hintText: "Additional Information",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.lock),
                hintText: "Enter Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () async {
                    if (edit) {
                      users
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection("password")
                          .doc(documentSnapshot!.id)
                          .set({
                        'name': nameController.text, // John Doe
                        'userName': userNameController.text, // Stokes and Sons
                        'password': passwordController.text,
                        'info': infoController.text
                      }).then((value) {
                        Fluttertoast.showToast(
                            msg: "Data Updated Successfully",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.indigo,
                            textColor: Colors.white,
                            fontSize: 16.0);
                        Navigator.of(context).pop();
                      });
                    } else {
                      users
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection("password")
                          .add({
                        'name': nameController.text, // John Doe
                        'userName': userNameController.text, // Stokes and Sons
                        'password': passwordController.text,
                        'info': infoController.text
                      }).then((value) {
                        Navigator.of(context).pop();
                      });
                    }
                  },
                  child: Text(edit ? "Update" : "Add")),
            ),
          ],
        ),
      ),
    );
  }
}
