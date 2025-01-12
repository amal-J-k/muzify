import 'dart:developer';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmotionData {
  final String emotion;
  final int count;
  final Color color;

  EmotionData({
    required this.emotion,
    required this.count,
    required this.color,
  });
}

class EmotionAnalyticsScreen extends StatefulWidget {
  const EmotionAnalyticsScreen({super.key});

  @override
  _EmotionAnalyticsScreenState createState() => _EmotionAnalyticsScreenState();
}

class _EmotionAnalyticsScreenState extends State<EmotionAnalyticsScreen> {
  List<EmotionData> data = [];
  ValueNotifier<bool> isFetched = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    initializeSharedPreferences(); // Initialize SharedPreferences
  }

  Future<void> initializeSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getInt('angry') == null) await prefs.setInt('angry', 0);
    if (prefs.getInt('disgusted') == null) await prefs.setInt('disgusted', 0);
    if (prefs.getInt('fearful') == null) await prefs.setInt('fearful', 0);
    if (prefs.getInt('happy') == null) await prefs.setInt('happy', 0);
    if (prefs.getInt('neutral') == null) await prefs.setInt('neutral', 0);
    if (prefs.getInt('sad') == null) await prefs.setInt('sad', 0);
    if (prefs.getInt('surprised') == null) await prefs.setInt('surprised', 0);

    await loadData();
  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int angry = prefs.getInt('angry') ?? 0;
    int disgusted = prefs.getInt('disgusted') ?? 0;
    int fearful = prefs.getInt('fearful') ?? 0;
    int happy = prefs.getInt('happy') ?? 0;
    int neutral = prefs.getInt('neutral') ?? 0;
    int sad = prefs.getInt('sad') ?? 0;
    int surprised = prefs.getInt('surprised') ?? 0;

    log('Sad count: $sad');

    data = [
      EmotionData(emotion: 'Angry', count: angry, color: Colors.red),
      EmotionData(emotion: 'Disgusted', count: disgusted, color: Colors.green),
      EmotionData(emotion: 'Fearful', count: fearful, color: Colors.purple),
      EmotionData(emotion: 'Happy', count: happy, color: Colors.yellow),
      EmotionData(emotion: 'Neutral', count: neutral, color: Colors.blue),
      EmotionData(emotion: 'Sad', count: sad, color: Colors.grey),
      EmotionData(emotion: 'Surprised', count: surprised, color: Colors.orange),
    ];

    isFetched.value = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emotion Analytics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ValueListenableBuilder(
          valueListenable: isFetched,
          builder: (context, value, child) {
            if (value) {
              return Column(
                children: [
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: data.isNotEmpty
                            ? data.map((e) => e.count).reduce((a, b) => a > b ? a : b).toDouble()
                            : 10,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: SideTitles(
                            showTitles: true,
                            margin: 16,
                            getTitles: (double value) {
                              switch (value.toInt()) {
                                case 0:
                                  return 'Angry';
                                case 1:
                                  return 'Disgusted';
                                case 2:
                                  return 'Fearful';
                                case 3:
                                  return 'Happy';
                                case 4:
                                  return 'Neutral';
                                case 5:
                                  return 'Sad';
                                case 6:
                                  return 'Surprised';
                                default:
                                  return '';
                              }
                            },
                          ),
                          leftTitles: SideTitles(showTitles: true),
                        ),
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: false),
                        barGroups: data
                            .asMap()
                            .entries
                            .map(
                              (e) => BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                y: e.value.count.toDouble(),
                                colors: [e.value.color],
                                width: 20,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ],
                          ),
                        )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}