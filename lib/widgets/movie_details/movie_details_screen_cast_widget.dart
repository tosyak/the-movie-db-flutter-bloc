import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_movie_db/domain/api_client/image_downloader.dart';
import 'package:the_movie_db/widgets/movie_details/movie_details_model.dart';

class MovieDeteilsScreenCastWidget extends StatelessWidget {
  const MovieDeteilsScreenCastWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Series Cast',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: 270,
            child: Scrollbar(
              // thumbVisibility: true,
              // trackVisibility: false,
              child: _ActorList(),
            ),
          ),
          TextButton(onPressed: () {}, child: Text('Full cast & Crew'))
        ],
      ),
    );
  }
}

class _ActorList extends StatelessWidget {
  const _ActorList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cast =
        context.select((MovieDetailsModel model) => model.data.actorData);
    if (cast.isEmpty) return SizedBox.shrink();
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: cast.length,
      itemExtent: 130,
      itemBuilder: (BuildContext context, int index) {
        return _ActorListItemWidget(actorIndex: index);
      },
    );
  }
}

class _ActorListItemWidget extends StatelessWidget {
  final int actorIndex;
  const _ActorListItemWidget({Key? key, required this.actorIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.read<MovieDetailsModel>();
    var actor = model.data.actorData[actorIndex];
    final profilePath = actor.posterPath;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black.withOpacity(0.2)),
            borderRadius: BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: Offset(0, 2))
            ]),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.hardEdge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (profilePath != null)
                Image.network(ImageDownloader.imageUrl(profilePath)),
              SizedBox(height: 5),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        actor.name,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        actor.character,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
