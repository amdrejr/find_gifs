import 'package:flutter/material.dart';

import 'package:share/share.dart';

class GifPage extends StatelessWidget {
  final _gifData;

  const GifPage(this._gifData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          _gifData['title'],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(_gifData['images']['fixed_height']['url']);
            },
          )
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Image.network(_gifData['images']['fixed_height']['url']),
      ),
    );
  }
}
