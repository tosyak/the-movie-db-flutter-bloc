import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_movie_db/widgets/movie_details/movie_details_main_info_widget.dart';
import 'package:the_movie_db/widgets/movie_details/movie_details_model.dart';
import 'package:the_movie_db/widgets/movie_details/movie_details_screen_cast_widget.dart';

class MovieDetailsWidget extends StatefulWidget {
  const MovieDetailsWidget({
    Key? key,
  }) : super(key: key);

  @override
  State<MovieDetailsWidget> createState() => _MovieDetailsWidgetState();
}

class _MovieDetailsWidgetState extends State<MovieDetailsWidget> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    Future.microtask(
        () => context.read<MovieDetailsModel>().setupLocale(context, locale));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _TitleWidget(),
      ),
      body: ColoredBox(
        color: Color.fromRGBO(24, 23, 27, 1.0),
        child: _BodyWidget(),
      ),
    );
  }
}

class _TitleWidget extends StatelessWidget {
  const _TitleWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = context.select((MovieDetailsModel model) => model.data.title);
    return Text(title);
  }
}

class _BodyWidget extends StatelessWidget {
  const _BodyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLoading =
        context.select((MovieDetailsModel model) => model.data.isLoading);

    if (isLoading) {
      return Center(child: const CircularProgressIndicator());
    }
    return ListView(children: [
      MovieDetailsMainInfoWidget(),
      SizedBox(height: 20),
      MovieDeteilsScreenCastWidget(),
    ]);
  }
}
