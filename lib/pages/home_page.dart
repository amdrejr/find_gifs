import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String esqueleto = 'https://media.giphy.com/media/3ohhwvOnBaE8TtyBaw/giphy.gif';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _search;
  final int _offset = 0;
  late double numero;
  late String fundo;

  Future<Map> _getGifs() async {
    http.Response response;

    if (_search == null) {
      // se null, pesquisa pelos trends gifs
      response = await http.get(Uri.parse(
          'https://api.giphy.com/v1/gifs/trending?api_key=8FjQCGsNZfNLfDIuyud5N5oafX8J3niV&limit=25&rating=g'));
    } else {
      // se não, busca pelo que foi pesquisado
      response = await http.get(Uri.parse(
          'https://api.giphy.com/v1/gifs/search?api_key=8FjQCGsNZfNLfDIuyud5N5oafX8J3niV&q=$_search&limit=20&offset=$_offset&rating=g&lang=pt'));
    }
    return json.decode(response.body); // Pegando o corpo da requisição
  }

  Future<Map> puxando() async {
    http.Response? response;
    response = await http.get(Uri.parse(
        'https://api.giphy.com/v1/gifs/random?api_key=8FjQCGsNZfNLfDIuyud5N5oafX8J3niV&tag=loop&rating=g'));
    return json.decode(response.body);
  }

  String _futureBackGroud() {
    String resultado =
        'https://media.giphy.com/media/3ohhwvOnBaE8TtyBaw/giphy.gif';

    puxando().then((valor) {
      resultado = valor['data']['url'];
    });

    print('resultado: $resultado');

    return resultado;
  }

  late TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    numero = 1;
  }

  @override
  Widget build(BuildContext context) {
    String texto = _futureBackGroud();
    return Scaffold(
      backgroundColor: const Color(0xFFffbbd5),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: numero,
        leading: Image.network(
          'https://media.giphy.com/media/3ohs4l3Tlr1rzSNm80/giphy.gif',
          scale: 2,
        ),
        title: const Text(
          'GIF FINDER',
          style: TextStyle(
              color: Colors.black, fontFamily: 'Pixelmania', fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          Image.network(
            'https://media.giphy.com/media/3ohs4cFD1UFULKN1sY/giphy.gif',
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            repeat: ImageRepeat.repeat,
            scale: .1,
            alignment: Alignment.center,
            image: NetworkImage(texto),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 100),
              TextField(
                controller: searchController,
                textCapitalization:
                    TextCapitalization.characters, // deixar texto em uppercase
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Color(0xCFfae1eb),
                  hintText: 'BUSQUE AQUI',
                  hintStyle: TextStyle(color: Colors.pink),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                ),
                style: const TextStyle(
                    color: Color(0xff660606), fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder(
                  future: _getGifs(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.purple),
                            strokeWidth: 5,
                          ),
                        );
                      default:
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text('Erro ao carregar..'),
                          );
                        } else {
                          return _createGifTable(context, snapshot);
                        }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
      padding: const EdgeInsets.only(top: 10),
      // Quantos itens por linha
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          // Espaçamentos
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      itemCount: snapshot.data['data'].length,

      itemBuilder: (context, index) {
        return GestureDetector(
          child: Image.network(
              snapshot.data['data'][index]['images']['fixed_height']['url'],
              height: 300,
              fit: BoxFit
                  .cover // Recorta a imagem para caber certinho no tamanho definido acima
              ),
        );
      },
    );
  }
}
