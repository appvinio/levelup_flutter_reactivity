import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:levelup_flutter_reactive/pokemon/data/pokemon_json_factory.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

class PokemonPage extends StatefulWidget {
  PokemonPage({Key key}) : super(key: key);

  @override
  _PokemonPagePageState createState() => new _PokemonPagePageState();
}

class _PokemonPagePageState extends State<PokemonPage> {

  BehaviorSubject<String> searchQuery = BehaviorSubject<String>(seedValue: "");

  Observable<Pokemons> fetchPokemons() {
    return Observable.combineLatest2(
        http.get('http://pokeapi.co/api/v2/pokemon/').asStream().map((data) =>
            Pokemons.fromJson(json.decode(data.body))), searchQuery,
            (Pokemons pokemons, String query) =>
            Pokemons(results: pokemons.results.where((element) =>
                element.name.contains(query)).toList()));
  }

  Future<Pokemon> fetchPokemon(String url) {
    return Observable
        .fromFuture(http.get(url))
        .map((data) => Pokemon.fromJson(json.decode(data.body)))
        .first;
  }

  Future<PokemonDesc> fetchPokemonDesc(String url) {
    return Observable
        .fromFuture(http.get(url))
        .map((data) => PokemonDesc.fromJson(json.decode(data.body)))
        .first;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new TextField(onChanged: (query) => searchQuery.add(query),),
        ),
        body: buildAllPokemons());
  }

  Widget buildAllPokemons() {
    return StreamBuilder(
        stream: fetchPokemons(),
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
                    itemBuilder: (context, index) =>
                        buildPokemon(pokemons.results[index]));
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
                return buildPokemonInfo(snapshot.data, element.url);
              }
          }
        });
  }

  Widget buildPokemonInfo(Pokemon element, String url) {
    return Card(
      child: ExpansionTile(
        title: Column(
          children: <Widget>[Text(element.name), Image.network(element.image)],
        ),
        children: <Widget>[
          FutureBuilder<PokemonDesc>(
              future: fetchPokemonDesc(url),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Column(children: <Widget>[
                      Text('Awaiting result for ${element.name} descriptions'),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                    ]);
                  default:
                    if (snapshot.hasError)
                      return Text('Error: ${snapshot.error}');
                    else {
                      return buildPokemonDesc(snapshot.data);
                    }
                }
              })
        ],
      ),
    );
  }

  Widget buildPokemonDesc(PokemonDesc element) {
    return Column(
      children: <Widget>[
        Text("Base experience : ${element.baseExperience}"),
        Text("Weight : ${element.weight}"),
        Text("Height : ${element.height}"),
      ],
    );
  }
}
