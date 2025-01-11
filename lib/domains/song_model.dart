class Song {
  final String name;
  final String imageUrl;
  final String downloadUrl;
  final String authorName;
  final int duration;

  Song({
    required this.authorName,
    required this.name,
    required this.imageUrl,
    required this.downloadUrl,
    required this.duration,
  });

  // Factory constructor to create a Song object from JSON
  factory Song.fromJson(Map<String, dynamic> json) {
    // Extract image and download URL from the JSON
    final imageUrl = json['image'] != null && json['image'].isNotEmpty
        ? json['image'][2]['url']
        : '';

    // Extract the highest quality download URL
    final downloadUrl =
        json['downloadUrl'] != null && json['downloadUrl'].isNotEmpty
            ? json['downloadUrl'].last['url']
            : '';

    final authorName =
        json['artists'] != null && json['artists']['primary'] != null && json['artists']['primary'][0]['name'] != null
            ? json['artists']['primary'][0]['name']
            : 'author';

    return Song( 
      name: json['name'] ?? '',
      imageUrl: imageUrl,
      downloadUrl: downloadUrl,
      authorName: authorName,
      duration: json['duration'] ?? 0,
    );
  }
}
