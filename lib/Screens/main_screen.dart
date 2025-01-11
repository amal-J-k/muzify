import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../applications/music_player/music_player_bloc.dart';
//import 'analytics.dart';
import 'details_screen.dart';
import 'emotion_screen.dart';
import 'home_screen.dart';


AudioPlayer audioPlayer = AudioPlayer();

class MainScreen extends StatelessWidget {
  final ValueNotifier<int> selectedIndexNotifier = ValueNotifier(0);
  final HomeScreen homeScreen = HomeScreen();

  final _pages = [
    const Placeholder(),
    const EmotionScreen(),
    //const EmotionAnalyticsScreen(),
  ];

  MainScreen({super.key});

  void _onItemTapped(int index) {
    selectedIndexNotifier.value = index;
  }

  @override
  Widget build(BuildContext context) {
    _pages[0] = homeScreen;
    context.read<MusicPlayerBloc>().add(FetchMusic(query: "malayalam"));
    return ValueListenableBuilder<int>(
      valueListenable: selectedIndexNotifier,
      builder: (context, index, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Musify',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            backgroundColor: Colors.indigo.shade800,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: index == 0
                      ? MediaQuery.of(context).size.height - 225
                      : MediaQuery.of(context).size.height - 140,
                  child: _pages[index],
                ),
                SizedBox(
                  height: index == 0 ? 80 : 0,
                  child: const BottomMusicPlayer(),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.computer),
                label: 'AI',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics_outlined),
                label: 'Analytics',
              ),
            ],
            currentIndex: index,
            selectedItemColor: Colors.indigo.shade800,
            unselectedItemColor: Colors.grey,
            backgroundColor: Colors.white,
            elevation: 8,
            onTap: (index) => _onItemTapped(index),
          ),
        );
      },
    );
  }
}

class BottomMusicPlayer extends StatelessWidget {
  const BottomMusicPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.indigo.shade800,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.skip_previous, color: Colors.white),
            onPressed: () {
              context.read<MusicPlayerBloc>().add(PreviousMusic());
            },
          ),
          BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
            buildWhen: (previous, current) => current is MusicPlaying,
            builder: (context, state) {
              if (state is MusicPlaying) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width * .5,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (ctx) => DetailsScreen(song: state.song),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50)),
                            child: Image.network(
                              state.song.imageUrl,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.error),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        GestureDetector(
                          onHorizontalDragEnd: (details) {
                            if (details.primaryVelocity != null) {
                              if (details.primaryVelocity! < 0) {
                                context
                                    .read<MusicPlayerBloc>()
                                    .add(NextMusic());
                              } else if (details.primaryVelocity! > 0) {
                                context
                                    .read<MusicPlayerBloc>()
                                    .add(PreviousMusic());
                              }
                            }
                          },
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width / 3.2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  state.song.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                ),
                                Text(
                                  state.song.authorName,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return const Text(
                  'No song playing',
                  style: TextStyle(color: Colors.white),
                );
              }
            },
          ),
          Row(
            children: [
              BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
                buildWhen: (previous, current) =>
                    current is MusicPlaying || current is MusicPaused,
                builder: (context, state) {
                  if (state is MusicPlaying) {
                    return IconButton(
                      icon: const Icon(Icons.pause, color: Colors.white),
                      onPressed: () {
                        context.read<MusicPlayerBloc>().add(PauseMusic());
                      },
                    );
                  } else {
                    return IconButton(
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      onPressed: () {
                        context.read<MusicPlayerBloc>().add(ResumeMusic());
                      },
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white),
                onPressed: () {
                  context.read<MusicPlayerBloc>().add(NextMusic());
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
