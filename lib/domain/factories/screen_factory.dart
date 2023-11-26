import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:the_movie_db/domain/blocs/auth_bloc.dart';
import 'package:the_movie_db/domain/blocs/movie_list_bloc.dart';
import 'package:the_movie_db/widgets/auth/auth_view_cubit.dart';
import 'package:the_movie_db/widgets/auth/auth_widget.dart';
import 'package:the_movie_db/widgets/loader_screen/loader_widget.dart';
import 'package:the_movie_db/widgets/loader_screen/loder_view_cubit.dart';
import 'package:the_movie_db/widgets/main_screen/main_screen_widget.dart';
import 'package:the_movie_db/widgets/movie_details/movie_details_model.dart';
import 'package:the_movie_db/widgets/movie_details/movie_details_widget.dart';
import 'package:the_movie_db/widgets/movie_list/movie_list_cubit.dart';
import 'package:the_movie_db/widgets/movie_list/movie_list_widget.dart';
import 'package:the_movie_db/widgets/movie_trailer/movie_trailer_widget.dart';

class ScreenFactory {
  AuthBloc? _authBloc;

  Widget makeLoader() {
    final authBloc = _authBloc ?? AuthBloc(AuthCheckStatusInProgressState());
    _authBloc = authBloc;
    return BlocProvider<LoaderViewCubit>(
      create: (_) => LoaderViewCubit(
        LoaderViewCubitState.unknown,
        authBloc,
      ),
      child: const LoaderWidget(),
      // lazy: false,
    );
  }

  Widget makeAuth() {
    final authBloc = _authBloc ?? AuthBloc(AuthCheckStatusInProgressState());
    _authBloc = authBloc;
    return BlocProvider<AuthViewCubit>(
      create: (_) => AuthViewCubit(
        AuthViewCubitFormFillInProgressState(),
        authBloc,
      ),
      child: AuthWidget(),
    );
  }

  Widget makeMainScreen() {
    _authBloc?.close();
    _authBloc = null;
    return MainScreenWidget();
  }

  Widget makeMovieDetails(int movieId) {
    return ChangeNotifierProvider(
      create: (_) => MovieDetailsModel(movieId),
      child: const MovieDetailsWidget(),
    );
  }

  Widget makeMovieTrailer(String youTubeKey) {
    return MovieTrailerWidget(youTubeKey: youTubeKey);
  }

  Widget makeNewsList() {
    return Center(
      child: Container(
        child: Text('News'),
      ),
    );
  }

  Widget makeMovieList() {
    return BlocProvider(
      create: (_) => MovieListCubit(
        movieListBloc: MovieListBloc(
          MovieListState.initial(),
        ),
      ),
      child: MovieListWidget(),
    );
  }

  Widget makeTvShowList() {
    return Center(
      child: Container(
        child: Text('TV Show'),
      ),
    );
  }
}
