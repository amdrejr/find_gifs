import 'package:flutter/material.dart';

import 'pages/home_page.dart';

void main(List<String> args) {
  runApp(MaterialApp(
    title: 'Buscador de Gifs',
    home: const HomePage(),
    theme: ThemeData(hintColor: Colors.black),
  ));
}
