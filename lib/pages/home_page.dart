import 'dart:convert';

import 'package:find_gifs/pages/gif_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

String esqueleto = 'https://media.giphy.com/media/3ohhwvOnBaE8TtyBaw/giphy.gif';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _search;
  int _offset = 0;
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
          'https://api.giphy.com/v1/gifs/search?api_key=8FjQCGsNZfNLfDIuyud5N5oafX8J3niV&q=$_search&limit=25&offset=$_offset&rating=g&lang=pt'));
    }
    return json.decode(response.body); // Pegando o corpo da requisição
  }

  Future<Map> _getRandomGif() async {
    http.Response? response;
    response = await http.get(Uri.parse(
        'https://api.giphy.com/v1/gifs/random?api_key=8FjQCGsNZfNLfDIuyud5N5oafX8J3niV&tag=loop&rating=g'));
    return json.decode(response.body);
  }

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFffbbd5),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Image.network(
          'https://media.giphy.com/media/3ohs4l3Tlr1rzSNm80/giphy.gif',
          scale: 2,
        ),
        title: const Text(
          'GIF FINDER',
          style: TextStyle(
              color: Colors.purple, fontFamily: 'Pixelmania', fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          Image.network(
            'https://media.giphy.com/media/3ohs4cFD1UFULKN1sY/giphy.gif',
          ),
        ],
      ),
      body: FutureBuilder(
          future: _getRandomGif(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.none:
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.cyan),
                    strokeWidth: 5,
                  ),
                );

              default:
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Erro ao carregar..'),
                  );
                } else {
                  print('URL RANDOM: ${snapshot.data!['data']['url']}');
                  return corpo(snapshot);
                }
            }
          }),
    );
  }

  Widget corpo(AsyncSnapshot snapshot) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          repeat: ImageRepeat.repeat,
          scale: .4,
          alignment: Alignment.center,
          image: NetworkImage(
              snapshot.data['data']['images']['fixed_width']['url']),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 100),
            TextField(
              controller: _searchController,

              onSubmitted: (String text) {
                // Ao dar enter
                if (_searchController.text.isNotEmpty) {
                  setState(() {
                    _search = text;
                    _offset = 0;
                  });
                }
              },
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
                builder: (BuildContext context, AsyncSnapshot snapshot) {
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
      itemCount: _getCountList(snapshot.data['data']),

      itemBuilder: (context, index) {
        if (_search == null || index < snapshot.data["data"].length) {
          // Se não estiver nada pesquisado e se não for o último item
          // Irá mostar:
          return GestureDetector(
            onLongPress: () {
              Share.share(snapshot.data['data'][index]['images']['fixed_height']
                  ['url']);
            },
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return GifPage(snapshot.data['data'][index]);
                  },
                ),
              );
            },
            child: FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: snapshot.data['data'][index]['images']['fixed_height']
                  ['url'],
              height: 300,
              fit: BoxFit.cover,
            ),
          );
        } else {
          return Container(
            height: 300,
            width: 300,
            color: Colors.black,
            child: GestureDetector(
                onTap: () {
                  setState(() {
                    _offset += 25;
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.arrow_forward, color: Colors.white, size: 80),
                    Text(
                      'Carregar mais..',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    )
                  ],
                )),
          );
        }
      },
    );
  }

  int _getCountList(List data) {
    if (_search == null) {
      return data.length;
    } else {
      return data.length + 1;
    }
  }
}
