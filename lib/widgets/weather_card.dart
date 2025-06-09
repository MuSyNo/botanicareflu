// lib/widgets/weather_card.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key});

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  double? temperature;
  String? condition;
  String? time;
  bool isLoading = true;
  bool hasError = false;

  final double latitude = 3.0738;
  final double longitude = 101.5183;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final current = data['current_weather'];
        setState(() {
          temperature = (current['temperature'] as num).toDouble();
          condition = _mapWeatherCode(current['weathercode']);
          time = DateFormat.jm().format(DateTime.parse(current['time']));
          isLoading = false;
          hasError = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  String _mapWeatherCode(int code) {
    if (code < 2) return 'Clear';
    if (code < 3) return 'Mostly Clear';
    if (code < 5) return 'Partly Cloudy';
    if (code < 7) return 'Cloudy';
    if (code < 10) return 'Overcast';
    if (code < 60) return 'Rainy';
    if (code < 70) return 'Snow';
    if (code < 90) return 'Storm';
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : hasError
            ? const Center(child: Text('Failed to load weather data.'))
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weather Forecast',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Temperature: ${temperature?.toStringAsFixed(1)} °C'),
            Text('Condition: $condition'),
            Text('Updated: $time'),
          ],
        ),
      ),
    );
  }
}
