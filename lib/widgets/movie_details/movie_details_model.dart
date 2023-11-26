// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_movie_db/domain/api_client/api_client_exeption.dart';
import 'package:the_movie_db/domain/entity/movie_details.dart';
import 'package:the_movie_db/domain/services/auth_service.dart';
import 'package:the_movie_db/domain/services/localize_model.dart';
import 'package:the_movie_db/domain/services/movie_service.dart';
import 'package:the_movie_db/ui/navigation/main_navigation.dart';

class MovieDetailsPosterData {
  final String? backdropPath;
  final String? posterPath;
  final bool isFavorite;
  IconData get favoriteIcon =>
      isFavorite ? Icons.favorite : Icons.favorite_outline;

  MovieDetailsPosterData({
    this.backdropPath,
    this.posterPath,
    this.isFavorite = false,
  });

  MovieDetailsPosterData copyWith({
    String? backdropPath,
    String? posterPath,
    bool? isFavorite,
  }) {
    return MovieDetailsPosterData(
      backdropPath: backdropPath ?? this.backdropPath,
      posterPath: posterPath ?? this.posterPath,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class MovieDetailsMovieNameData {
  final String name;
  final String year;

  MovieDetailsMovieNameData({
    required this.name,
    required this.year,
  });
}

class MovieDetailsScoreData {
  final String? trailerKey;
  final double voteAverage;

  MovieDetailsScoreData({
    this.trailerKey,
    required this.voteAverage,
  });
}

class MovieDetailsCrewData {
  String name;
  String job;
  MovieDetailsCrewData({
    required this.name,
    required this.job,
  });
}

class MovieDetailsActorData {
  String name;
  String character;
  String? posterPath;
  MovieDetailsActorData({
    required this.name,
    required this.character,
    this.posterPath,
  });
}

class MovieDetailsData {
  String title = '';
  bool isLoading = true;
  String overview = '';
  String tagLine = '';
  MovieDetailsPosterData posterData = MovieDetailsPosterData();
  MovieDetailsMovieNameData nameData =
      MovieDetailsMovieNameData(name: '', year: '');
  MovieDetailsScoreData scoreData = MovieDetailsScoreData(voteAverage: 0.0);
  String summery = '';
  List<List<MovieDetailsCrewData>> crewData = [];
  List<MovieDetailsActorData> actorData = [];
}

class MovieDetailsModel extends ChangeNotifier {
  final _authService = AuthService();
  final _movieService = MovieService();

  final int movieId;
  final data = MovieDetailsData();
  final _localeStorage = LocalizeModelStorage();
  late DateFormat _dateFormat;

  MovieDetailsModel(this.movieId);

  Future<void> setupLocale(BuildContext context, Locale locale) async {
    if (!_localeStorage.updateLocale(locale)) return;

    _dateFormat = DateFormat.yMMMMd(_localeStorage.localeTag);
    updateData(null, false);
    await loadDetails(context);
  }

  void updateData(MovieDetails? details, bool isFavorite) {
    data.title = details?.title ?? 'Загрузка...';
    data.isLoading = details == null;
    if (details == null) {
      notifyListeners();
      return;
    }
    data.overview = details.overview ?? '';
    data.tagLine = details.tagline ?? '';
    data.posterData = MovieDetailsPosterData(
        isFavorite: isFavorite,
        backdropPath: details.backdropPath,
        posterPath: details.posterPath);
    var year = details.releaseDate?.year.toString();
    year = year != null ? ' ($year)' : '';
    data.nameData = MovieDetailsMovieNameData(name: details.title, year: year);
    var videos = details.videos.results
        .where((video) => video.type == 'Trailer' && video.site == 'YouTube');
    final trailerKey = videos.isNotEmpty == true ? videos.first.key : null;
    data.scoreData = MovieDetailsScoreData(
      voteAverage: details.voteAverage,
      trailerKey: trailerKey,
    );
    data.summery = makeSummery(details);
    data.crewData = makeCrewData(details);
    data.actorData = details.credits.cast
        .map((e) => MovieDetailsActorData(
              name: e.name,
              character: e.character,
              posterPath: e.profilePath,
            ))
        .toList();

    notifyListeners();
  }

  String makeSummery(MovieDetails details) {
    final releaseDate = details.releaseDate;
    var text = <String>[];

    if (releaseDate != null) {
      text.add(_dateFormat.format(releaseDate));
    }

    if (details.productionCountries.isNotEmpty) {
      text.add('(${details.productionCountries.first.name})');
    }

    final runtime = details.runtime ?? 0;
    final duration = Duration(minutes: runtime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    text.add('${hours}h ${minutes}m');

    if (details.genres.isNotEmpty) {
      var genreName = <String>[];
      for (var genre in details.genres) {
        genreName.add(genre.name);
      }
      text.add(genreName.join(', '));
    }
    return text.join(' ');
  }

  List<List<MovieDetailsCrewData>> makeCrewData(MovieDetails details) {
    var crew = details.credits.crew
        .map((e) => MovieDetailsCrewData(name: e.name, job: e.job))
        .toList();

    crew = crew.length > 4 ? crew.sublist(0, 4) : crew;
    var crewChunk = <List<MovieDetailsCrewData>>[];
    for (var i = 0; i < crew.length; i += 2) {
      crewChunk.add(crew.sublist(i, i + 2 > crew.length ? crew.length : i + 2));
    }
    return crewChunk;
  }

  Future<void> loadDetails(BuildContext context) async {
    try {
      final details = await _movieService.loadDetails(
        locale: _localeStorage.localeTag,
        movieId: movieId,
      );

      updateData(details.details, details.isFavorite);
    } on ApiClientException catch (e) {
      _handleApiClientException(e, context);
    }
  }

  Future<void> toggleFavorite(BuildContext context) async {
    data.posterData =
        data.posterData.copyWith(isFavorite: !data.posterData.isFavorite);

    notifyListeners();

    try {
      await _movieService.updateFavorite(
        movieId: movieId,
        isFavorite: data.posterData.isFavorite,
      );
    } on ApiClientException catch (e) {
      _handleApiClientException(e, context);
    }
  }

  void _handleApiClientException(
      ApiClientException exception, BuildContext context) {
    switch (exception.type) {
      case ApiClientExceptionType.sessionExpired:
        _authService.logout();
        MainNavigation.resetNavigation(context);
        break;

      default:
        print(exception);
    }
  }
}
