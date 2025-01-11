import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../api/api.dart';
import '../../domains/song_model.dart';

part 'music_player_event.dart';
part 'music_player_state.dart';

class MusicPlayerBloc extends Bloc<MusicPlayerEvent, MusicPlayerState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  int currentMusicIndex = -1;
  List<Song> _songs = [];

  List<Song> get songs => List.unmodifiable(_songs);

  MusicPlayerBloc() : super(MusicPlayerInitial()) {
    _audioPlayer.onPositionChanged.listen((position) {
      add(UpdateMusicPosition(position: position));
    });
    on<FetchMusic>(fetchMusic);
    on<PlayMusic>(playMusic);
    on<PauseMusic>(pauseMusic);
    on<ResumeMusic>(resumeMusic);
    on<NextMusic>(nextMusic);
    on<PreviousMusic>(previousMusic);
    on<SeekMusic>(seekMusic);
    on<UpdateMusicPosition>(updateMusicPosition);
    on<StopMusic>(stopMusic);
  }

  FutureOr<void> fetchMusic(
      FetchMusic event, Emitter<MusicPlayerState> emit) async {
    emit(MusicFetching());
    print('music fetching for ${event.query}');
    _songs = await ApiService().getSongData(event.query);

    log('fetch song length :${_songs.length.toString()}');

    emit(MusicFetched(songs: _songs));
  }

  FutureOr<void> playMusic(
      PlayMusic event, Emitter<MusicPlayerState> emit) async {
    int previousMusicIndex = currentMusicIndex;
    if (event.song != null) {
      emit(
        MusicPlaying(
          currentMusicIndex: 0,
          previousMusicIndex: 0,
          song: event.song!,
        ),
      );
      await _audioPlayer.play(UrlSource(event.song!.downloadUrl));
    } else {
      if (_songs.isNotEmpty) {
        if (event.musicIndex < 0 && _songs.length > 1) {
          currentMusicIndex = 0;
        } else {
          currentMusicIndex = event.musicIndex;
        }
        emit(
          MusicPlaying(
            currentMusicIndex: currentMusicIndex,
            previousMusicIndex: previousMusicIndex,
            song: _songs[currentMusicIndex],
          ),
        );
        await _audioPlayer
            .play(UrlSource(_songs[event.musicIndex].downloadUrl));
      }
    }
  }

  FutureOr<void> stopMusic(
      StopMusic event, Emitter<MusicPlayerState> emit) async {
    await _audioPlayer.stop();
    currentMusicIndex = -1;
    emit(MusicStopped());
  }

  FutureOr<void> pauseMusic(
      PauseMusic event, Emitter<MusicPlayerState> emit) async {
    emit(MusicPaused(currentMusicIndex: currentMusicIndex));
    await _audioPlayer.pause();
  }

  FutureOr<void> resumeMusic(
      ResumeMusic event, Emitter<MusicPlayerState> emit) async {
    if (currentMusicIndex > -1) {
      emit(MusicPlaying(
        currentMusicIndex: currentMusicIndex,
        previousMusicIndex: 0,
        song: _songs[currentMusicIndex],
      ));
      _audioPlayer.resume();
    }
  }

  FutureOr<void> nextMusic(
      NextMusic event, Emitter<MusicPlayerState> emit) async {
    if (_songs.isNotEmpty) {
      int next = (currentMusicIndex + 1) % _songs.length;
      emit(MusicPlaying(
        previousMusicIndex: currentMusicIndex,
        currentMusicIndex: next,
        song: _songs[next],
      ));
      await _audioPlayer.play(UrlSource(_songs[next].downloadUrl));
      currentMusicIndex = next;
    }
  }

  FutureOr<void> previousMusic(
      PreviousMusic event, Emitter<MusicPlayerState> emit) async {
    int previous = (currentMusicIndex - 1) % _songs.length;
    if (_songs.isNotEmpty) {
      emit(MusicPlaying(
        currentMusicIndex: previous,
        previousMusicIndex: currentMusicIndex,
        song: _songs[previous],
      ));
      await _audioPlayer.play(UrlSource(_songs[previous].downloadUrl));
      currentMusicIndex = previous;
    }
  }

  FutureOr<void> seekMusic(
      SeekMusic event, Emitter<MusicPlayerState> emit) async {
    await _audioPlayer.seek(event.position);
  }

  FutureOr<void> updateMusicPosition(
      UpdateMusicPosition event, Emitter<MusicPlayerState> emit) {
    emit(MusicPositionChanged(position: event.position));
  }
}
