import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sgs/newarticle.dart';

class StockList extends StatefulWidget {
  @override
  _StockListState createState() => _StockListState();
}

class _StockListState extends State<StockList> {
  bool isEditing = false; // if we will edit this gonna change
  List<Article> articles = []; // List to store articles from Firestore

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: const Text('liste des articles'),


        actions: <Widget>[
          // Edit button to toggle editing mode
          IconButton(
            icon: isEditing ? const Icon(Icons.check) : const Icon(Icons.edit),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => NewArticle(
                    onArticleAdded: (articleName, quantity) {
                      // Update the UI to display the new article
                      setState(() {});
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('articles').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child:
                    CircularProgressIndicator()); // circle to wait for net connection
          }

          // turn Firestore data into Article objects
          articles = snapshot.data!.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            return Article(
              id: doc.id,
              name: data['name'],
              quantity: data['quantity'],
            );
          }).toList();

          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              Article article = articles[index];
              return ListTile(
                title: Text(article.name),
                subtitle: Text('Quantity: ${article.quantity}'),
                trailing: isEditing // Display +/- buttons in editing mode
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () {
                              updateQuantity(article, -1);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              updateQuantity(article, 1);
                            },
                          ),
                        ],
                      )
                    : null,
                tileColor: (article.quantity) == '0' ? Colors.red : null,

              );
            },
          );
        },
      ),
    );
  }

  void updateQuantity(Article article, int change) {
    int newQuantity = int.parse(article.quantity) + change;
    if (newQuantity >= 0) {
      FirebaseFirestore.instance
          .collection('articles')
          .doc(article.id)
          .update({'quantity': newQuantity.toString()});
    }
  }
}

class Article {
  final String id;
  final String name;
  final String quantity;

  Article({
    required this.id,
    required this.name,
    required this.quantity,
  });
}
