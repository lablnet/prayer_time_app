import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prayer_time_app/components/custom_app_bar.dart';

class QiblaPage extends StatefulWidget {
  @override
  _QiblaPageState createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  final _locationStreamController = StreamController<LocationStatus>.broadcast();

  @override
  void initState() {
    super.initState();
    _checkLocationStatus();
  }

  @override
  void dispose() {
    _locationStreamController.close();
    FlutterQiblah().dispose();
    super.dispose();
  }

  Future<void> _checkLocationStatus() async {
    final locationStatus = await FlutterQiblah.checkLocationStatus();
    if (locationStatus.enabled && locationStatus.status == LocationPermission.denied) {
      await FlutterQiblah.requestPermissions();
    }
    _locationStreamController.sink.add(locationStatus);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, "Qibla Direction", back: false),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [const Color(0xFF0f0f1e), const Color(0xFF1a1a2e)]
                : [const Color(0xFFf5f7fa), const Color(0xFFc3cfe2)],
          ),
        ),
        child: StreamBuilder(
          stream: _locationStreamController.stream,
          builder: (context, AsyncSnapshot<LocationStatus> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data!.enabled == true) {
              switch (snapshot.data!.status) {
                case LocationPermission.always:
                case LocationPermission.whileInUse:
                  return QiblaCompass();
                case LocationPermission.denied:
                  return _buildErrorState("Location permission denied");
                case LocationPermission.deniedForever:
                  return _buildErrorState("Location permission permanently denied");
                default:
                  return Container();
              }
            } else {
              return _buildErrorState("Please enable location services");
            }
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _checkLocationStatus(),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}

class QiblaCompass extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FlutterQiblah.qiblahStream,
      builder: (_, AsyncSnapshot<QiblahDirection> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final qiblahDirection = snapshot.data!;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${qiblahDirection.direction.toInt()}°",
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text("Direction to Kaaba", style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 40),
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Transform.rotate(
                    angle: ((qiblahDirection.direction ?? 0) * (math.pi / 180) * -1),
                    child: Image.asset('assets/logo.png', width: 250, opacity: const AlwaysStoppedAnimation(0.2)), // Background logo
                  ),
                  Transform.rotate(
                    angle: ((qiblahDirection.qiblah ?? 0) * (math.pi / 180) * -1),
                    child: const Icon(Icons.navigation, size: 100, color: Color(0xFFe94560)),
                  ),
                  const Icon(Icons.brightness_1, size: 20, color: Colors.white),
                  Transform.rotate(
                    angle: ((qiblahDirection.direction ?? 0) * (math.pi / 180) * -1),
                    child: CustomPaint(
                      size: const Size(300, 300),
                      painter: CompassPainter(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    "Wave your device in a figure-8 motion to calibrate the compass if accuracy is low.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
