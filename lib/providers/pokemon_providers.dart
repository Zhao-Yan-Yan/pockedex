import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/pokemon.dart';
import '../data/models/pokemon_info.dart';
import '../data/repository/pokemon_repository.dart';

// Repository provider
final pokemonRepositoryProvider = Provider<PokemonRepository>((ref) {
  return PokemonRepository();
});

// Pokemon list state
class PokemonListState {
  final List<Pokemon> pokemonList;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMore;

  const PokemonListState({
    this.pokemonList = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 0,
    this.hasMore = true,
  });

  PokemonListState copyWith({
    List<Pokemon>? pokemonList,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMore,
  }) {
    return PokemonListState(
      pokemonList: pokemonList ?? this.pokemonList,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// Pokemon list notifier
class PokemonListNotifier extends StateNotifier<PokemonListState> {
  final PokemonRepository _repository;

  PokemonListNotifier(this._repository) : super(const PokemonListState()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final pokemonList = await _repository.fetchPokemonList(page: 0);
      state = state.copyWith(
        pokemonList: pokemonList,
        isLoading: false,
        currentPage: 0,
        hasMore: pokemonList.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final newPokemon = await _repository.fetchPokemonList(page: nextPage);

      state = state.copyWith(
        pokemonList: [...state.pokemonList, ...newPokemon],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMore: newPokemon.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      pokemonList: [],
      currentPage: 0,
      hasMore: true,
    );

    try {
      final pokemonList = await _repository.fetchPokemonList(
        page: 0,
        forceRefresh: true,
      );
      state = state.copyWith(
        pokemonList: pokemonList,
        isLoading: false,
        hasMore: pokemonList.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final pokemonListProvider =
    StateNotifierProvider<PokemonListNotifier, PokemonListState>((ref) {
  final repository = ref.watch(pokemonRepositoryProvider);
  return PokemonListNotifier(repository);
});

// Pokemon info state
class PokemonInfoState {
  final PokemonInfo? info;
  final bool isLoading;
  final String? error;

  const PokemonInfoState({
    this.info,
    this.isLoading = false,
    this.error,
  });

  PokemonInfoState copyWith({
    PokemonInfo? info,
    bool? isLoading,
    String? error,
  }) {
    return PokemonInfoState(
      info: info ?? this.info,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Pokemon info family provider
final pokemonInfoProvider = FutureProvider.family<PokemonInfo, String>(
  (ref, name) async {
    final repository = ref.watch(pokemonRepositoryProvider);
    return repository.fetchPokemonInfo(name: name);
  },
);

// Color cache for Pokemon cards
final pokemonColorProvider =
    StateProvider.family<Color?, int>((ref, pokemonId) => null);