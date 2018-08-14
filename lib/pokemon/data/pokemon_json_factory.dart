
class Pokemons {
  final List<PokemonsListElement> results;

  Pokemons({this.results});

  factory Pokemons.fromJson(Map<String, dynamic> json) {
    return Pokemons(
      results: (json['results'] as List).map((i) => PokemonsListElement.fromJson(i)).toList()
    );
  }
}

class PokemonsListElement {
  final String name;
  final String url;

  PokemonsListElement({this.name, this.url});

  factory PokemonsListElement.fromJson(Map<String, dynamic> json) {
    return PokemonsListElement(
      name: json['name'],
      url: json['url'],
    );
  }
}

class Pokemon {
  final String name;
  final String image;

  Pokemon({this.name, this.image});

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      name: json['name'],
      image: json['sprites']['front_default'],
    );
  }
}
