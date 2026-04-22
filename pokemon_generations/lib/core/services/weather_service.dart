import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/api_keys.dart';

final weatherServiceProvider = Provider<WeatherService>((ref) => WeatherService(ref));

enum WeatherCondition { clear, clouds, rain, snow, sandstorm, storm }

class WeatherData {
  final WeatherCondition condition;
  final bool isDay;
  final double temperature;
  final String locationName;

  WeatherData({
    required this.condition,
    required this.isDay,
    required this.temperature,
    required this.locationName,
  });
}

class WeatherService {
  final Ref ref;
  // USER: Managed via lib/core/config/api_keys.dart (Git Ignored)
  static const String _apiKey = ApiKeys.openWeatherMap;

  WeatherService(this.ref);

  Future<WeatherData> getCurrentWeather() async {
    try {
      Position? position = await _getCoordinates();
      
      if (position != null) {
        return await _fetchFromOWM(position.latitude, position.longitude);
      } else {
        // Fallback to IP-based location
        return await _fetchFromIP();
      }
    } catch (e) {
      print('[WEATHER] Failed to get weather: $e');
      return WeatherData(
        condition: WeatherCondition.clear,
        isDay: true,
        temperature: 20.0,
        locationName: 'Unknown',
      );
    }
  }

  Future<Position?> _getCoordinates() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (_) {
      return null;
    }
  }

  Future<WeatherData> _fetchFromOWM(double lat, double lon) async {
    if (_apiKey == 'YOUR_OPENWEATHER_API_KEY') {
       // Silent fallback if key is not configured
       return _getFallbackBasedOnTime('Stationary');
    }

    final url = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric';
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return _parseOWM(data);
    }
    throw Exception('OWM request failed');
  }

  Future<WeatherData> _fetchFromIP() async {
    try {
      final res = await http.get(Uri.parse('http://ip-api.com/json'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final lat = data['lat'] as double;
        final lon = data['lon'] as double;
        return await _fetchFromOWM(lat, lon);
      }
    } catch (_) {}
    return _getFallbackBasedOnTime('IP Lookup Failed');
  }

  WeatherData _parseOWM(Map<String, dynamic> data) {
    final main = data['weather'][0]['main'].toString().toLowerCase();
    final clouds = data['clouds']['all'] as int;
    final temp = data['main']['temp'] as double;
    final name = data['name'] as String;
    
    // Check sunrise/sunset for isDay
    final now = DateTime.now().millisecondsSinceEpoch / 1000;
    final sunrise = data['sys']['sunrise'] as int;
    final sunset = data['sys']['sunset'] as int;
    final isDay = now > sunrise && now < sunset;

    WeatherCondition condition = WeatherCondition.clear;
    if (main.contains('rain') || main.contains('drizzle')) {
      condition = WeatherCondition.rain;
    } else if (main.contains('snow')) {
      condition = WeatherCondition.snow;
    } else if (main.contains('thunderstorm')) {
      condition = WeatherCondition.storm;
    } else if (main.contains('sand') || main.contains('dust') || main.contains('ash')) {
      condition = WeatherCondition.sandstorm;
    } else if (clouds > 50 || main.contains('cloud')) {
      condition = WeatherCondition.clouds;
    }

    return WeatherData(
      condition: condition,
      isDay: isDay,
      temperature: temp,
      locationName: name,
    );
  }

  WeatherData _getFallbackBasedOnTime(String debugReason) {
    final hour = DateTime.now().hour;
    final isDay = hour > 6 && hour < 19;
    return WeatherData(
      condition: WeatherCondition.clear,
      isDay: isDay,
      temperature: 20.0,
      locationName: 'Local Time ($debugReason)',
    );
  }
}
