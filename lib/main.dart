import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/photo.dart';
import 'models/goods.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(),
        '/list': (context) => ListPage(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/list');
                },
                child: Text(
                  'Next',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(350, 50),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ))
          ],
        ),
      ),
    );
  }
}

class ListPage extends StatefulWidget {
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  late Future<Map<Photo, List<Goods>>> _futurePhotoProductMap;

  @override
  void initState() {
    super.initState();
    _futurePhotoProductMap = fetchPhotoProductMap();
  }

  Future<Map<Photo, List<Goods>>> fetchPhotoProductMap() async {
    try {
      final photoResponse = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/photos'));
      final productResponse =
          await http.get(Uri.parse('https://fakestoreapi.com/products'));

      if (photoResponse.statusCode == 200 &&
          productResponse.statusCode == 200) {
        final List<Photo> photos = (json.decode(photoResponse.body) as List)
            .map((json) => Photo.fromJson(json))
            .toList();
        final List<Goods> products =
            (json.decode(productResponse.body) as List)
                .map((json) => Goods.fromJson(json))
                .toList();

        // Прив'язуємо продукти до фото
        final Map<Photo, List<Goods>> photoProductMap = {};
        int productIndex = 0;

        for (final photo in photos) {
          photoProductMap[photo] = [];
          for (int i = 0; i < 2; i++) {
            if (productIndex < products.length) {
              photoProductMap[photo]!.add(products[productIndex]);
              productIndex++;
            }
          }
        }

        return photoProductMap;
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Failed to load data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shops'),
      ),
      body: FutureBuilder<Map<Photo, List<Goods>>>(
        future: _futurePhotoProductMap,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final photoProductMap = snapshot.data!;
            return ListView(
              children: photoProductMap.entries.take(10).map((entry) {
                final photo = entry.key;
                final products = entry.value;

                return ExpansionTile(
                  leading: Image.network(
                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQlypgIGWLfPvo-RkcR5bXpFtgXEXJI5hDeKA&s"),
                  title: Text(photo.title),
                  subtitle: Text('Album ID: ${photo.albumId}'),
                  children: products.take(10).map((product) {
                    return ListTile(
                      leading: Image.network(product.image),
                      title: Text(product.title),
                      subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                    );
                  }).toList(),
                );
              }).toList(),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}