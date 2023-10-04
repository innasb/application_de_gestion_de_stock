// newarticle.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewArticle extends StatefulWidget {
  final Function(String articleName, String quantity) onArticleAdded;

  const NewArticle({Key? key, required this.onArticleAdded}) : super(key: key);

  @override
  _NewArticleState createState() => _NewArticleState();
}

class _NewArticleState extends State<NewArticle> {
  final _formKey = GlobalKey<FormState>();
  String articleName = '';
  String quantity = '';
  final TextEditingController idController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( centerTitle: true,
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: const Text('New Article'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Article Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an article name';
                  }
                  return null;
                },
                onSaved: (value) {
                  articleName = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid quantity';
                  }
                  return null;
                },
                onSaved: (value) {
                  quantity = value!;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: idController,
                decoration: const InputDecoration(
                  labelText: 'Article ID',
                  hintText: 'Enter the article ID',
                ),
              ),
              const SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Get the article ID from the controller
                    String articleId = idController.text;

                    // Create a reference to the Firestore collection
                    CollectionReference articlesRef =
                    FirebaseFirestore.instance.collection('articles');

                    // if the document's ID already exists
                    DocumentSnapshot document =
                    await articlesRef.doc(articleId).get();

                    if (document.exists) {
                      // If the document exists just update the quantity
                      await articlesRef.doc(articleId).update({
                        'quantity': quantity,
                      });
                    } else {
                      // If  not then add a new document
                      await articlesRef.doc(articleId).set({
                        'name': articleName,
                        'quantity': quantity,
                      });
                    }

                    // Pass the articleName and quantity back to the stocklist page
                    widget.onArticleAdded(articleName, quantity);

                    Navigator.of(context).pop(); // Close the new article page.
                  }
                },
                child: const SizedBox(
                  width: 350,
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_scanner_outlined),
                      Text('Save'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
