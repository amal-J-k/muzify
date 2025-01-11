import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../applications/music_player/music_player_bloc.dart';
import '../domains/song_model.dart';

class DetailsScreen extends StatelessWidget {
  final Song song;
  final bool showBackButton;

  const DetailsScreen({
    super.key,
    required this.song,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    Duration totalDuration = const Duration(seconds: 0);
    String imageUrl = '';
    return Scaffold(
      appBar: showBackButton
          ? AppBar(
              title: const Text(
                'Musify',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.indigo.shade800,
              elevation: 0,
              leading: SizedBox(
                width: double.infinity,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  alignment: Alignment.centerLeft,
                  icon: const Icon(
                    CupertinoIcons.back,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            )
          : null,
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade800, Colors.deepPurple.shade200],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
              left: 12.0, right: 12, top: 3.0, bottom: 62),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
                        buildWhen: (previous, current) =>
                            current is MusicPlaying || current is MusicPaused,
                        builder: (context, state) {
                          if (state is! MusicPlaying && state is! MusicPaused) {
                            imageUrl = song.imageUrl;
                          }

                          if (state is MusicPlaying) {
                            imageUrl = state.song.imageUrl;
                          }
                          return Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                  child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.error),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
                    buildWhen: (previous, current) => current is MusicPlaying,
                    builder: (context, state) {
                      if (state is MusicPlaying) {
                        totalDuration = Duration(seconds: state.song.duration);
                      } else {
                        totalDuration = Duration(seconds: song.duration);
                      }
                      return Column(
                        children: [
                          Text(
                            state is MusicPlaying ? state.song.name : song.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state is MusicPlaying
                                ? state.song.authorName
                                : song.authorName,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
                    buildWhen: (previous, current) =>
                        current is MusicPositionChanged,
                    builder: (context, state) {
                      double position = state is MusicPositionChanged
                          ? state.position.inSeconds.toDouble()
                          : 0;
                      if (position > totalDuration.inSeconds.toDouble()) {
                        position = 0;
                      }
                      return Column(
                        children: [
                          Slider(
                            value: position,
                            min: 0,
                            max: totalDuration.inSeconds.toDouble(),
                            onChanged: (value) {
                              context.read<MusicPlayerBloc>().add(
                                    SeekMusic(
                                      position:
                                          Duration(seconds: value.toInt()),
                                    ),
                                  );
                            },
                            activeColor: Colors.white,
                            inactiveColor: Colors.white.withOpacity(0.3),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${(position.toInt() ~/ 60).toString()}:${(position.toInt() % 60).toString().padLeft(2, '0')}",
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.7)),
                                ),
                                Text(
                                  "${totalDuration.inMinutes}:${(totalDuration.inSeconds % 60).toString().padLeft(2, '0')}",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        iconSize: 48,
                        onPressed: () => context
                            .read<MusicPlayerBloc>()
                            .add(PreviousMusic()),
                        icon: const Icon(Icons.skip_previous,
                            color: Colors.white),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
                          buildWhen: (previous, current) =>
                              current is MusicPlaying || current is MusicPaused,
                          builder: (context, state) {
                            bool isNotPlaying = state is MusicPaused;
                            return IconButton(
                              iconSize: 64,
                              icon: Icon(
                                isNotPlaying ? Icons.play_arrow : Icons.pause,
                                color: Colors.deepPurple.shade800,
                              ),
                              onPressed: () => isNotPlaying
                                  ? context
                                      .read<MusicPlayerBloc>()
                                      .add(ResumeMusic())
                                  : context
                                      .read<MusicPlayerBloc>()
                                      .add(PauseMusic()),
                            );
                          },
                        ),
                      ),
                      IconButton(
                        iconSize: 48,
                        onPressed: () =>
                            context.read<MusicPlayerBloc>().add(NextMusic()),
                        icon: const Icon(Icons.skip_next, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
