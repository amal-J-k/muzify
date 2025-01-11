part of 'music_player_bloc.dart';

@immutable
sealed class MusicPlayerState {}

final class MusicPlayerInitial extends MusicPlayerState {}

abstract class MusicPlayerActionState extends MusicPlayerState {}

class MusicFetching extends MusicPlayerState {}

class MusicFetched extends MusicPlayerState {
  final List<Song> songs;

  MusicFetched({required this.songs});
}


class MusicPlaying extends MusicPlayerState {
  final int currentMusicIndex;
  final int previousMusicIndex;
  final Song song;

  MusicPlaying({
    required this.currentMusicIndex,
    required this.previousMusicIndex,
    required this.song,
  });
}


class MusicPaused extends MusicPlayerState {
  final int currentMusicIndex;

  MusicPaused({required this.currentMusicIndex});
}

class MusicStopped extends MusicPlayerActionState {}

class PlayingNextMusic extends MusicPlayerActionState {}

class PlayingPreviousMusic extends MusicPlayerActionState {}

class MusicPositionChanged extends MusicPlayerState {
  final Duration position;

  MusicPositionChanged({required this.position});
}
