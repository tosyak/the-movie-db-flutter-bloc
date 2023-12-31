// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:the_movie_db/domain/blocs/movie_list_bloc.dart';
import 'package:the_movie_db/domain/entity/movie.dart';

class MovieListRowData {
  final int id;
  final String? posterPath;
  final String title;
  final String releaseDate;
  final String overview;
  MovieListRowData({
    required this.id,
    required this.posterPath,
    required this.title,
    required this.releaseDate,
    required this.overview,
  });
}

class MovieListCubitState {
  final List<MovieListRowData> movies;
  final String localeTag;
  MovieListCubitState({
    required this.movies,
    required this.localeTag,
  });

  @override
  bool operator ==(covariant MovieListCubitState other) {
    if (identical(this, other)) return true;

    return listEquals(other.movies, movies) && other.localeTag == localeTag;
  }

  @override
  int get hashCode => movies.hashCode ^ localeTag.hashCode;

  MovieListCubitState copyWith({
    List<MovieListRowData>? movies,
    String? localeTag,
  }) {
    return MovieListCubitState(
      movies: movies ?? this.movies,
      localeTag: localeTag ?? this.localeTag,
    );
  }
}

class MovieListCubit extends Cubit<MovieListCubitState> {
  final MovieListBloc movieListBloc;
  late final StreamSubscription<MovieListState> movieListBlocSubscription;
  late DateFormat _dateFormat;
  Timer? searchDebounce;
  MovieListCubit({
    required this.movieListBloc,
  }) : super(MovieListCubitState(
          movies: <MovieListRowData>[],
          localeTag: '',
        )) {
    Future.microtask(
      () {
        _onState(movieListBloc.state);
        movieListBlocSubscription = movieListBloc.stream.listen(_onState);
      },
    );
  }

  void _onState(MovieListState state) {
    final movies = state.movies.map(_makeRowData).toList();
    final newState = this.state.copyWith(movies: movies);
    emit(newState);
  }

  void setupLocale(String localeTag) {
    if (state.localeTag == localeTag) return;
    final newState = state.copyWith(localeTag: localeTag);
    emit(newState);
    _dateFormat = DateFormat.yMMMMd(localeTag);
    movieListBloc.add(MovieListEventLoadReset());
    movieListBloc.add(MovieListEventLoadNextPage(locale: localeTag));
  }

  void showMovieAtIndex(int index) {
    if (index < state.movies.length - 1) return;
    movieListBloc.add(MovieListEventLoadNextPage(locale: state.localeTag));
  }

  void searchMovie(String text) async {
    searchDebounce?.cancel();
    searchDebounce = Timer(Duration(seconds: 1), () async {
      movieListBloc.add(MovieListEventLoadSearchMovie(query: text));
      movieListBloc.add(MovieListEventLoadNextPage(locale: state.localeTag));
    });
  }

  @override
  Future<void> close() {
    movieListBlocSubscription.cancel();
    return super.close();
  }

  MovieListRowData _makeRowData(Movie movie) {
    final releaseDate = movie.releaseDate;
    final releaseDateTitle =
        releaseDate != null ? _dateFormat.format(releaseDate) : '';
    return MovieListRowData(
      id: movie.id,
      posterPath: movie.posterPath,
      title: movie.title,
      releaseDate: releaseDateTitle,
      overview: movie.overview,
    );
  }
}
