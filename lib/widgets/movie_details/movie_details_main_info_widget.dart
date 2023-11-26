import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_movie_db/domain/api_client/image_downloader.dart';
import 'package:the_movie_db/ui/navigation/main_navigation.dart';
import 'package:the_movie_db/widgets/elements/radial_percent_widget.dart';
import 'package:the_movie_db/widgets/movie_details/movie_details_model.dart';

class MovieDetailsMainInfoWidget extends StatelessWidget {
  const MovieDetailsMainInfoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TopPostersWidget(),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: _MovieNameWidget(),
        ),
        _MovieScoreWidget(),
        _SummeryWidget(),
        _MovieOverview(),
        _Crew(),
      ],
    );
  }
}

class _TopPostersWidget extends StatelessWidget {
  const _TopPostersWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.watch<MovieDetailsModel>();
    final model = context.select((MovieDetailsModel model) => model);

    final posterData =
        context.select((MovieDetailsModel model) => model.data.posterData);

    final backdropPath = posterData.backdropPath;
    final posterPath = posterData.posterPath;

    return AspectRatio(
      aspectRatio: 390 / 220,
      child: Stack(
        children: [
          if (backdropPath != null)
            Image.network(ImageDownloader.imageUrl(backdropPath)),
          if (posterPath != null)
            Positioned(
              top: 15,
              left: 15,
              bottom: 15,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(ImageDownloader.imageUrl(posterPath)),
              ),
            ),
          Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                onPressed: () => model.toggleFavorite(context),
                icon: Icon(posterData.favoriteIcon),
                iconSize: 35,
                color: Colors.red,
                splashColor: Colors.pink,
                splashRadius: 45,
                hoverColor: Colors.blue,
              ))
        ],
      ),
    );
  }
}

class _MovieNameWidget extends StatelessWidget {
  const _MovieNameWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var data = context.select((MovieDetailsModel model) => model.data.nameData);
    return Center(
      child: RichText(
        maxLines: 3,
        textAlign: TextAlign.center,
        text: TextSpan(children: [
          TextSpan(
              text: data.name,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 21,
              )),
          TextSpan(
              text: data.year,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 17,
              )),
        ]),
      ),
    );
  }
}

class _MovieScoreWidget extends StatelessWidget {
  const _MovieScoreWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final movieDetails =
        context.select((MovieDetailsModel model) => model.data.scoreData);
    var voteAverage = movieDetails.voteAverage;

    final trailerKey = movieDetails.trailerKey;
    voteAverage *= 10;

    return Row(
      // crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
            onPressed: () {},
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: RadialPercentWidget(
                    child: Text(voteAverage.toStringAsFixed(0)),
                    fillColor: Color.fromARGB(255, 14, 32, 35),
                    freeColor: Color.fromARGB(255, 30, 65, 37),
                    lineColor: Color.fromARGB(255, 37, 203, 103),
                    lineWidth: 3,
                    percent: voteAverage / 100,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Text('Рейтинг'),
              ],
            )),
        Container(width: 1, height: 15, color: Colors.grey),
        trailerKey != null
            ? TextButton(
                onPressed: () => Navigator.of(context).pushNamed(
                    MainNavigationRouteNames.movieTrailerWidget,
                    arguments: trailerKey),
                child: Row(
                  children: [
                    Icon(Icons.play_arrow),
                    Text('Трейлер'),
                  ],
                ))
            : SizedBox.shrink(),
      ],
    );
  }
}

class _SummeryWidget extends StatelessWidget {
  const _SummeryWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final summery =
        context.select((MovieDetailsModel model) => model.data.summery);

    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(0, 0, 0, 0.1),
        border: Border(
          top: BorderSide(color: Colors.black),
          bottom: BorderSide(color: Colors.black),
        ),
      ),
      child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            summery,
            maxLines: 3,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
          )),
    );
  }
}

class _MovieOverview extends StatelessWidget {
  const _MovieOverview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final overview =
        context.select((MovieDetailsModel model) => model.data.overview);
    final tagLine =
        context.select((MovieDetailsModel model) => model.data.tagLine);

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tagLine, style: TextStyle(color: Colors.grey, fontSize: 18)),
          SizedBox(
            height: 10,
          ),
          Text('Overview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              )),
          SizedBox(height: 10),
          Text(
            overview,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _Crew extends StatelessWidget {
  const _Crew({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var crewChunk =
        context.select((MovieDetailsModel model) => model.data.crewData);

    if (crewChunk.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: Column(
        children: crewChunk
            .map(
              (chunk) => Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: _CrewWidgetRow(employers: chunk),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _CrewWidgetRow extends StatelessWidget {
  final List<MovieDetailsCrewData> employers;
  const _CrewWidgetRow({Key? key, required this.employers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisSize: MainAxisSize.max,
        children: employers
            .map((employee) => _CrewWidgetRowItem(
                  employee: employee,
                ))
            .toList());
  }
}

class _CrewWidgetRowItem extends StatelessWidget {
  final MovieDetailsCrewData employee;
  const _CrewWidgetRowItem({Key? key, required this.employee})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    const nameStyle = TextStyle(
        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400);
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            employee.name,
            style: nameStyle,
          ),
          Text(
            employee.job,
            style: nameStyle,
          )
        ],
      ),
    );
  }
}
