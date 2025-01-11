part of 'music_player_bloc.dart';

@immutable
sealed class MusicPlayerEvent {}

class FetchMusic extends MusicPlayerEvent {
  final String query;

  FetchMusic({required this.query});
}

class PlayMusic extends MusicPlayerEvent {
  final int musicIndex;
  final Song? song;

  PlayMusic({
    required this.musicIndex,
    this.song,
  });
}

class StopMusic extends MusicPlayerEvent {}

class ResumeMusic extends MusicPlayerEvent {}

class PauseMusic extends MusicPlayerEvent {}

class NextMusic extends MusicPlayerEvent {}

class PreviousMusic extends MusicPlayerEvent {}

class SeekMusic extends MusicPlayerEvent {
  final Duration position;

  SeekMusic({required this.position});
}

class UpdateMusicPosition extends MusicPlayerEvent {
  final Duration position;

  UpdateMusicPosition({required this.position});
}
