import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MovieTrailerWidget extends StatefulWidget {
  final String youTubeKey;
  MovieTrailerWidget({Key? key, required this.youTubeKey}) : super(key: key);

  @override
  State<MovieTrailerWidget> createState() => _MovieTrailerWidgetState();
}

class _MovieTrailerWidgetState extends State<MovieTrailerWidget> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.youTubeKey,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
        ),
        builder: (context, player) {
          return Scaffold(
              appBar: AppBar(
                title: Text('Trailer'),
              ),
              backgroundColor: Colors.black,
              body: Center(
                child: player,
              ));
        });
  }
}
