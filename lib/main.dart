import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sgs/stocklist.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Gestion de stock'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int result = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme
            .of(context)
            .colorScheme
            .inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 100.0, // Set your desired width
              height: 100.0, // Set your desired height
              child: FloatingActionButton(
                onPressed: () async {
                  var res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SimpleBarcodeScannerPage(),
                    ),
                  );
                  setState(() {
                    if (res is int) {
                      result = res;
                      updateQuantityID(result);
                    }
                  });
                },
                child: const Icon(Icons.qr_code_scanner_outlined,
                    size: 60.0), // Adjust the icon size if needed
              ),
            ),
            SizedBox(height: 20,),
            const Text(
              'Scanner le codebarre',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 30),
            // i'll remove this later
            Text(
              'Scanned Data: $result',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 100.0, // Set your desired width
              height: 100.0, // Set your desired height
              child: FloatingActionButton(
                onPressed: () {
                  // Navigate to the NextPage when the button is pressed
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => StockList(),
                    ),
                  );
                },
                child: const Icon(Icons.inventory_2_outlined,
                    size: 60.0), // Adjust the icon size if needed
              ),
            ),
            const SizedBox(height: 30),
            const SizedBox(
              height: 60,
              child: Text(
                'stock',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateQuantityID(int result) async {
    try {
      // nro7o ll collection
      CollectionReference articlesRef =
      FirebaseFirestore.instance.collection('articles');

      // find the matching article with the code scanned and put 'em on list
      QuerySnapshot matchingArticles = await articlesRef
          .where('id', isEqualTo: result)
          .limit(1)
          .get();

      if (matchingArticles.docs.isNotEmpty) {

        DocumentSnapshot articleDoc = matchingArticles.docs.first;
        int currentQuantity = articleDoc['quantity'] ?? 0;
        if (currentQuantity > 0) {

          await articlesRef.doc(articleDoc.id).update({
            'quantity': currentQuantity - 1,
          });
          print('Quantity updated for ID: $result');
        } else {
          print('repture de stock pour : $result');
        }
      } else {
        print('No article found with ID: $result');
      }
    } catch (error) {
      print('Error updating quantity: $error');
    }
  }
}
