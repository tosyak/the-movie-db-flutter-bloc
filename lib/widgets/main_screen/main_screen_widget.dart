import 'package:flutter/material.dart';
import 'package:the_movie_db/domain/factories/screen_factory.dart';
import 'package:the_movie_db/domain/services/auth_service.dart';

class MainScreenWidget extends StatefulWidget {
  const MainScreenWidget({Key? key}) : super(key: key);

  @override
  State<MainScreenWidget> createState() => _MainScreenWidgetState();
}

class _MainScreenWidgetState extends State<MainScreenWidget> {
  int _selectedTab = 0;

  final _screenFactory = ScreenFactory();

  final authService = AuthService();

  void onSelectedTab(int index) {
    if (_selectedTab == index) return;
    setState(() {
      _selectedTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TMDB'),
        actions: [
          IconButton(
            onPressed: () => authService.logout(),
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          _screenFactory.makeMovieList(),
          _screenFactory.makeNewsList(),
          _screenFactory.makeTvShowList(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Фильмы'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Новости'),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'Сериалы'),
        ],
        onTap: onSelectedTab,
      ),
    );
  }
}
