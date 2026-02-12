import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Weather',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  static const platform = MethodChannel('com.weatherapp/navigation');
  
  String _city = "London";
  Map<String, dynamic>? _weatherData;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(Uri.parse('https://wttr.in/$_city?format=j1'));
      if (response.statusCode == 200) {
        setState(() {
          _weatherData = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = "Failed to load weather: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Error: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _goBack() async {
    try {
      await platform.invokeMethod('goBack');
    } on PlatformException catch (e) {
      debugPrint("Failed to go back: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Weather"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: "Enter City",
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  setState(() => _city = value);
                  _fetchWeather();
                }
              },
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red))
            else if (_weatherData != null)
              _buildWeatherInfo()
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherInfo() {
    final current = _weatherData!['current_condition'][0];
    final area = _weatherData!['nearest_area'][0];
    
    return Column(
      children: [
        Text(
          "City: ${area['areaName'][0]['value']}",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Text(
          "Temp: ${current['temp_C']}°C",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text("Condition: ${current['weatherDesc'][0]['value']}"),
        Text("Humidity: ${current['humidity']}%"),
      ],
    );
  }
}
