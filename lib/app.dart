import 'package:flutter/material.dart';
import 'Views/AlbumsPage/albums_page.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gallery App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AlbumsPage(),
    );
  }
}
