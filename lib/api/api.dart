import 'package:dio/dio.dart';


import '../domains/song_model.dart';

class ApiService {
  final Dio _dio = Dio();

  ApiService() {
    _dio.options.baseUrl = 'https://saavn.dev/api/search';
    _dio.options.connectTimeout = const Duration(seconds: 20);
  }

  Future<List<Song>> getSongData(String query) async {
    try {
      final response = await _dio
          .get('/songs', queryParameters: {'query': query, 'limit': 100});

      if (response.data['success']) {
        final results = response.data['data']['results'] as List;
        print('Api response : $results');
        // return results.map((songData) => Song.fromJson(songData)).toList();

        List<Song> songs = [];
        for (var songData in results) {
          try {
            songs.add(Song.fromJson(songData));
          } catch (e) {
            continue;
          }
        }
        return songs;
      } else {
        print('Response received, but success is false');
        return [];
      }
    } catch (e) {
      print('Error on Api fetching: $e');
      return [];
    }
  }
}
