import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'Screens/main_screen.dart';
import 'applications/music_player/music_player_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MusicPlayerBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.white,
        ),
        home: MainScreen(),
      ),
    );
  }
}
