import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:levelup_flutter_reactive/pokemon/data/pokemon_json_factory.dart';
import 'package:http/http.dart' as http;

class PokemonPage extends StatefulWidget {
  PokemonPage({Key key}) : super(key: key);

  @override
  _PokemonPagePageState createState() => new _PokemonPagePageState();
}

class _PokemonPagePageState extends State<PokemonPage> {
  Future<Pokemons> fetchPokemons() async {
    final response = await http.get('http://pokeapi.co/api/v2/pokemon/');

    if (response.statusCode == 200) {
      return Pokemons.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future<Pokemon> fetchPokemon(String url) async {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Pokemon.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load post');
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Pokemons"),
        ),
        body: buildAllPokemons());
  }

  FutureBuilder<Pokemons> buildAllPokemons() {
    return FutureBuilder(
          future: fetchPokemons(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Text('Awaiting result...');
              default:
                if (snapshot.hasError)
                  return Text('Error: ${snapshot.error}');
                else {
                  Pokemons pokemons = snapshot.data;
                  return ListView.builder(
                      itemCount: pokemons.results.length,
                      itemBuilder: (context, index) => buildPokemon(pokemons.results[index]));
                }
            }
          });
  }

  Widget buildPokemon(PokemonsListElement element) {
    return FutureBuilder(
        future: fetchPokemon(element.url),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Text('Awaiting result for ${element.name}');
            default:
              if (snapshot.hasError)
                return Text('Error: ${snapshot.error}');
              else {
                return buildPokemonDesc(snapshot.data);
              }
          }
        });
  }

  Widget buildPokemonDesc(Pokemon element) {
    return Card(
      child: Column(
        children: <Widget>[
          Text(element.name),
          Image.network(element.image)
        ],
      ),
    );
  }
}
