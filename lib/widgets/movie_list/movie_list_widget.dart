import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_movie_db/domain/api_client/image_downloader.dart';
import 'package:the_movie_db/ui/navigation/main_navigation.dart';
import 'package:the_movie_db/widgets/movie_list/movie_list_cubit.dart';

class MovieListWidget extends StatefulWidget {
  const MovieListWidget({Key? key}) : super(key: key);

  @override
  State<MovieListWidget> createState() => _MovieListWidgetState();
}

class _MovieListWidgetState extends State<MovieListWidget> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    context.read<MovieListCubit>().setupLocale(locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        _MovieListWidget(),
        _SearchWidget(),
      ],
    );
  }
}

class _SearchWidget extends StatelessWidget {
  const _SearchWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MovieListCubit>();
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
        // controller: _searchController,
        onChanged: cubit.searchMovie,
        decoration: InputDecoration(
          labelText: 'Search',
          filled: true,
          fillColor: Colors.white.withAlpha(235),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}

class _MovieListWidget extends StatelessWidget {
  const _MovieListWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<MovieListCubit>();
    return ListView.builder(
      padding: EdgeInsets.only(top: 70),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: cubit.state.movies.length,
      itemExtent: 163,
      itemBuilder: (BuildContext context, int index) {
        cubit.showMovieAtIndex(index);
        return _MovieListRowWidget(
          index: index,
        );
      },
    );
  }
}

class _MovieListRowWidget extends StatelessWidget {
  final int index;
  const _MovieListRowWidget({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MovieListCubit>();
    final movie = cubit.state.movies[index];
    final posterPath = movie.posterPath;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black.withOpacity(0.2)),
                borderRadius: BorderRadius.all(Radius.circular(10)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  )
                ]),
            clipBehavior: Clip.hardEdge,
            child: Row(
              children: [
                if (posterPath != null)
                  Image.network(
                    ImageDownloader.imageUrl(posterPath),
                    width: 95,
                  ),
                SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        movie.title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 5),
                      Text(
                        movie.releaseDate,
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 20),
                      Text(
                        movie.overview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 10,
                )
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              onTap: () => _onMovieTap(context, movie.id),
            ),
          )
        ],
      ),
    );
  }

  void _onMovieTap(BuildContext context, int movieId) {
    // final id = _movies[index].id;
    Navigator.of(context).pushNamed(
      MainNavigationRouteNames.movieDetails,
      arguments: movieId,
    );
  }
}
