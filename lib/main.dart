import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter GeoJSON Map',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MapPage(),
    );
  }
}

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  List<MapLatLng> _dataPoints = [];
  List<Map<String, dynamic>> _properties = [];
  late MapZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    super.initState();
    _zoomPanBehavior = MapZoomPanBehavior();
    _loadGeoJson();
  }

  Future<void> _loadGeoJson() async {
    final String response =
        await rootBundle.loadString('assets/output_geojson_file2.geojson');
    final data = json.decode(response);
    final List<MapLatLng> points = [];
    final List<Map<String, dynamic>> properties = [];

    for (var feature in data['features']) {
      if (feature['geometry']['type'] == 'Point') {
        var coordinates = feature['geometry']['coordinates'];
        points.add(MapLatLng(coordinates[1], coordinates[0]));
        properties.add(feature['properties']);
      }
    }

    setState(() {
      _dataPoints = points;
      _properties = properties;
      _zoomPanBehavior = MapZoomPanBehavior(
        focalLatLng: _dataPoints.isNotEmpty
            ? _dataPoints[0]
            : const MapLatLng(35.0, 127.0),
        zoomLevel: 3,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter GeoJSON Map'),
      ),
      body: Center(
        child: SizedBox(
          width: 500,
          height: 500,
          child: _dataPoints.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SfMaps(
                  layers: [
                    MapTileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      zoomPanBehavior: _zoomPanBehavior,
                      initialMarkersCount: _dataPoints.length,
                      markerBuilder: (BuildContext context, int index) {
                        String tooltipMessage =
                            _properties[index]['NAME'] ?? 'No Name';
                        return MapMarker(
                          latitude: _dataPoints[index].latitude,
                          longitude: _dataPoints[index].longitude,
                          child: Tooltip(
                            message: tooltipMessage,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 24,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
