import '../api/pokemon_api.dart';
import '../database/pokemon_database.dart';
import '../models/pokemon.dart';
import '../models/pokemon_info.dart';

class PokemonRepository {
  final PokemonApi _api;
  final PokemonDatabase _database;

  PokemonRepository({
    PokemonApi? api,
    PokemonDatabase? database,
  })  : _api = api ?? PokemonApi(),
        _database = database ?? PokemonDatabase();

  /// Fetch Pokemon list with caching strategy
  /// First try to get from cache, if not available fetch from network
  Future<List<Pokemon>> fetchPokemonList({
    required int page,
    bool forceRefresh = false,
  }) async {
    // Try cache first if not forcing refresh
    if (!forceRefresh) {
      final cached = await _database.getPokemonListByPage(page);
      if (cached.isNotEmpty) {
        return cached;
      }
    }

    // Fetch from network
    final response = await _api.fetchPokemonList(page: page);

    // Cache the results
    await _database.insertPokemonList(response.results);

    return response.results;
  }

  /// Fetch Pokemon info with caching strategy
  Future<PokemonInfo> fetchPokemonInfo({
    required String name,
    bool forceRefresh = false,
  }) async {
    // Try cache first if not forcing refresh
    if (!forceRefresh) {
      final cached = await _database.getPokemonInfo(name);
      if (cached != null) {
        return cached;
      }
    }

    // Fetch from network
    final info = await _api.fetchPokemonInfo(name);

    // Cache the result
    await _database.insertPokemonInfo(info);

    return info;
  }
}