import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:the_movie_db/configuration/configuration.dart';
import 'package:the_movie_db/domain/api_client/movie_api_client.dart';
import 'package:the_movie_db/domain/entity/movie.dart';
import 'package:the_movie_db/domain/entity/popular_movie_response.dart';

abstract class MovieListEvent {}

class MovieListEventLoadNextPage extends MovieListEvent {
  final String locale;
  MovieListEventLoadNextPage({
    required this.locale,
  });
}

class MovieListEventLoadReset extends MovieListEvent {}

class MovieListEventLoadSearchMovie extends MovieListEvent {
  final String query;

  MovieListEventLoadSearchMovie({
    required this.query,
  });
}

class MovieListContainer {
  final List<Movie> movies;
  final int currentPage;
  final int totalPage;

  bool get isComplete => currentPage >= totalPage;

  const MovieListContainer.initial()
      : movies = const <Movie>[],
        currentPage = 0,
        totalPage = 1;

  MovieListContainer({
    required this.movies,
    required this.currentPage,
    required this.totalPage,
  });

  @override
  bool operator ==(covariant MovieListContainer other) {
    if (identical(this, other)) return true;

    return listEquals(other.movies, movies) &&
        other.currentPage == currentPage &&
        other.totalPage == totalPage;
  }

  @override
  int get hashCode =>
      movies.hashCode ^ currentPage.hashCode ^ totalPage.hashCode;

  MovieListContainer copyWith({
    List<Movie>? movies,
    int? currentPage,
    int? totalPage,
  }) {
    return MovieListContainer(
      movies: movies ?? this.movies,
      currentPage: currentPage ?? this.currentPage,
      totalPage: totalPage ?? this.totalPage,
    );
  }
}

class MovieListState {
  final MovieListContainer popularMovieContainer;
  final MovieListContainer searchMovieContainer;
  final String searchQuery;

  const MovieListState.initial()
      : popularMovieContainer = const MovieListContainer.initial(),
        searchMovieContainer = const MovieListContainer.initial(),
        searchQuery = '';

  bool get isSearchMode => searchQuery.isNotEmpty;
  List<Movie> get movies =>
      isSearchMode ? searchMovieContainer.movies : popularMovieContainer.movies;

  MovieListState({
    required this.popularMovieContainer,
    required this.searchMovieContainer,
    required this.searchQuery,
  });

  MovieListState copyWith({
    MovieListContainer? popularMovieContainer,
    MovieListContainer? searchMovieContainer,
    String? searchQuery,
  }) {
    return MovieListState(
      popularMovieContainer:
          popularMovieContainer ?? this.popularMovieContainer,
      searchMovieContainer: searchMovieContainer ?? this.searchMovieContainer,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  bool operator ==(covariant MovieListState other) {
    if (identical(this, other)) return true;

    return other.popularMovieContainer == popularMovieContainer &&
        other.searchMovieContainer == searchMovieContainer &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode =>
      popularMovieContainer.hashCode ^
      searchMovieContainer.hashCode ^
      searchQuery.hashCode;
}

class MovieListBloc extends Bloc<MovieListEvent, MovieListState> {
  final _movieApiClient = MovieApiClient();

  MovieListBloc(
    MovieListState initialState,
  ) : super(initialState) {
    on<MovieListEvent>(
      (event, emit) async {
        if (event is MovieListEventLoadNextPage) {
          await onMovieListEventLoadNextPage(event, emit);
        } else if (event is MovieListEventLoadReset) {
          await onMovieListEventLoadReset(event, emit);
        } else if (event is MovieListEventLoadSearchMovie) {
          onMovieListEventLoadSearchMovie(event, emit);
        }
      },
      transformer: sequential(),
    );
  }

  Future<void> onMovieListEventLoadNextPage(
    MovieListEventLoadNextPage event,
    Emitter<MovieListState> emit,
  ) async {
    if (state.isSearchMode) {
      final container =
          await _loadNextPage(state.searchMovieContainer, (nextPage) async {
        final result = await _movieApiClient.searchMovie(
          nextPage,
          event.locale,
          state.searchQuery,
          Configuration.apiKey,
        );
        return result;
      });
      if (container != null) {
        final newState = state.copyWith(searchMovieContainer: container);
        emit(newState);
      }
    } else {
      final container =
          await _loadNextPage(state.popularMovieContainer, (nextPage) async {
        final result = await _movieApiClient.popularMovie(
          nextPage,
          event.locale,
          Configuration.apiKey,
        );
        return result;
      });
      if (container != null) {
        final newState = state.copyWith(popularMovieContainer: container);
        emit(newState);
      }
    }
  }

  Future<MovieListContainer?> _loadNextPage(
    MovieListContainer container,
    Future<PopularMovieResponse> Function(int) loader,
  ) async {
    if (container.isComplete) return null;
    final nextPage = container.currentPage + 1;
    final result = await loader(nextPage);
    final movies = List<Movie>.from(container.movies)..addAll(result.movies);
    final newContainer = container.copyWith(
      movies: movies,
      currentPage: result.page,
      totalPage: result.totalPages,
    );
    return newContainer;
  }

  Future<void> onMovieListEventLoadReset(
    MovieListEventLoadReset event,
    Emitter<MovieListState> emit,
  ) async {
    emit(const MovieListState.initial());
  }

  Future<void> onMovieListEventLoadSearchMovie(
    MovieListEventLoadSearchMovie event,
    Emitter<MovieListState> emit,
  ) async {
    if (state.searchQuery == event.query) return;
    final newState = state.copyWith(
      searchQuery: event.query,
      searchMovieContainer: MovieListContainer.initial(),
    );
    emit(newState);
  }
}
