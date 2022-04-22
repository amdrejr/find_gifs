import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _search;
  final int _offset = 0;

  Future<Map> _getGifs() async {
    http.Response response;

    if (_search == null) {
      // se null, pesquisa pelos trends gifs
      response = await http.get(Uri.parse(
          'https://api.giphy.com/v1/gifs/trending?api_key=8FjQCGsNZfNLfDIuyud5N5oafX8J3niV&limit=20&rating=g'));
    } else {
      // se não, busca pelo que foi pesquisado
      response = await http.get(Uri.parse(
          'https://api.giphy.com/v1/gifs/search?api_key=8FjQCGsNZfNLfDIuyud5N5oafX8J3niV&q=$_search&limit=20&offset=$_offset&rating=g&lang=pt'));
    }
    return json.decode(response.body); // Pegando o corpo da requisição
  }

  @override
  void initState() {
    super.initState();
    _getGifs().then((map) => print(map));
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
