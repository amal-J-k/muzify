import 'dart:developer' as dev;
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../api/label.dart';
import '../applications/music_player/music_player_bloc.dart';
import '../domains/song_model.dart';
import 'details_screen.dart';

class EmotionScreen extends StatefulWidget {
  const EmotionScreen({super.key});

  @override
  _EmotionScreenState createState() => _EmotionScreenState();
}

class _EmotionScreenState extends State<EmotionScreen> {
  List<CameraDescription> cameras = [];

  CameraController? _cameraController;
  Song dummySong = Song(
    authorName: 'Dhibu Ninan Thomas',
    name: 'Angu Vaana Konilu',
    imageUrl:
        'https://c.saavncdn.com/504/ARM-Original-Motion-Picture-Soundtrack-Malayalam-2024-20241001211403-500x500.jpg',
    downloadUrl:
        'https://aac.saavncdn.com/504/2db935d8aa80f8289cfebafa5618ef5e_320.mp4',
    duration: 249,
  );

  bool songFetched = false;

  void getSongs(String query) async {
    int randomNumber = Random().nextInt(50);
    print(query);
    String res = "";
    switch (query.toLowerCase()) {
      case 'sad':
        res = motivating[randomNumber];

      case 'happy':
        res = happy[randomNumber];

      case 'angry':
        res = melody[randomNumber];

      case 'disgusted':
        res = inspiring[randomNumber];

      case 'surprised':
        res = neutral[randomNumber];

      case 'fearful':
        res = melody[randomNumber];

      case 'neutral':
        res = inspiring[randomNumber];

      default:
        res = 'malayalam';
    }
    context.read<MusicPlayerBloc>().add(FetchMusic(query: res));
    songFetched = true;
  }

  Future<void> _tfliteInit() async {
    String? res = await Tflite.loadModel(
      model: 'assets/facialmodel.tflite',
      labels: 'assets/labels.txt',
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
    if (res == null) {
      print('Error loading model');
    }

    dev.log("tflite init");
  }

  @override
  void initState() {
    super.initState();
    _initializeAsyncDependencies();
  }

  Future<void> _initializeAsyncDependencies() async {
    await _tfliteInit();
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await
    await Permission.camera.request();
    await Permission.storage.request();
    await _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras.isEmpty || cameras.length <= 1) {
      dev.log('No front-facing camera found');
      return;
    }
    dev.log('Front-facing camera found');

    _cameraController = CameraController(
      cameras[1],
      ResolutionPreset.high,
    );

    try {
      await _cameraController?.initialize();
      _takePhoto();
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  Future<void> _takePhoto() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        XFile image = await _cameraController!.takePicture();
        dev.log('Image taken');
        var recognitions;
        try {
          recognitions = await Tflite.runModelOnImage(
            path: image.path,
            // imageMean: 117, // defaults to 117.0
            // imageStd: 1, // defaults to 1.0
            // numResults: 2, // defaults to 5
            // threshold: 0.1, // defaults to 0.1
            // asynch: true, // defaults to true
          );
        } catch (e) {
          print("Error running model: $e");
          return;
        }

        if (recognitions == null || recognitions.isEmpty) {
          print("No recognitions found");
          return;
        }

        print(recognitions);
        getSongs(recognitions[0]['label']);

        _cameraController?.dispose();
        Tflite.close();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        int count = prefs.getInt(recognitions[0]['label']) ?? 0;

        count++;
        await prefs.setInt(recognitions[0]['label'], count);
      } catch (e) {
        print('Error taking photo: $e');
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    Tflite.close();
    dev.log('tflite closed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.read<MusicPlayerBloc>().add(StopMusic());

    return BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
      buildWhen: (previous, current) =>
          current is MusicFetched || current is MusicFetching,
      builder: (context, state) {
        if (state is MusicFetched && songFetched) {
          dev.log(state.toString());
          final song = state.songs.isNotEmpty ? state.songs[0] : dummySong;
          context.read<MusicPlayerBloc>().add(
                PlayMusic(
                  musicIndex: 0,
                  song: state.songs.isEmpty ? song : null,
                ),
              );
          return DetailsScreen(
            song: song,
            showBackButton: false,
          );
        } else {
          return const Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: LoadingIndicator(
                indicatorType: Indicator.lineScale,
                strokeWidth: 0.5,
                backgroundColor: Colors.transparent,
                colors: [Colors.black],
              ),
            ),
          );
        }
      },
    );
  }
}
