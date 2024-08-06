import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';

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
  List<MapLatLng> _dataPoints1 = [];
  List<Map<String, dynamic>> _properties1 = [];
  List<MapLatLng> _dataPoints2 = [];
  List<Map<String, dynamic>> _properties2 = [];
  MapLatLng? _currentLocation;
  late MapZoomPanBehavior _zoomPanBehavior;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<String> _allSuggestions = [];
  final List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _zoomPanBehavior = MapZoomPanBehavior(
      enableDoubleTapZooming: true,
      enablePanning: true,
      enablePinching: true,
      maxZoomLevel: 30,
      minZoomLevel: 1,
    );
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _loadGeoJson1(),
      _loadGeoJson2(),
    ]);
    await _getCurrentLocation();
    _allSuggestions = [
      ..._properties1.map((e) => e['name'] ?? 'No Name'),
      ..._properties2.map((e) => e['DEPART_NM'] ?? 'No Name'),
    ];
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadGeoJson1() async {
    final String response =
        await rootBundle.loadString('assets/police.geojson');
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

    _dataPoints1 = points;
    _properties1 = properties;
  }

  Future<void> _loadGeoJson2() async {
    final String response = await rootBundle.loadString('assets/ship.geojson');
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

    _dataPoints2 = points;
    _properties2 = properties;
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = MapLatLng(position.latitude, position.longitude);
    });
  }

  void _searchLocation(String query) {
    FocusScope.of(context).unfocus(); // 가상 키보드 내리기
    for (int i = 0; i < _properties1.length; i++) {
      if (_properties1[i]['name'] == query) {
        _zoomPanBehavior.focalLatLng = _dataPoints1[i];
        _zoomPanBehavior.zoomLevel = 15;
        return;
      }
    }

    for (int i = 0; i < _properties2.length; i++) {
      if (_properties2[i]['DEPART_NM'] == query) {
        _zoomPanBehavior.focalLatLng = _dataPoints2[i];
        _zoomPanBehavior.zoomLevel = 15;
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location not found')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter GeoJSON Map'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                } else {
                  return _allSuggestions.where((String option) {
                    return option
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase());
                  });
                }
              },
              onSelected: (String selection) {
                _searchController.text = selection;
                _searchLocation(selection);
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'Search Location',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        _searchLocation(controller.text);
                      },
                    ),
                  ),
                  onSubmitted: (String value) {
                    _searchLocation(value);
                  },
                );
              },
            ),
          ),
          Expanded(
            child: Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : SfMaps(
                      layers: [
                        MapTileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          zoomPanBehavior: _zoomPanBehavior,
                          initialMarkersCount: (_currentLocation != null
                              ? _dataPoints1.length + _dataPoints2.length + 1
                              : _dataPoints1.length + _dataPoints2.length),
                          markerBuilder: (BuildContext context, int index) {
                            if (_currentLocation != null &&
                                index ==
                                    _dataPoints1.length + _dataPoints2.length) {
                              return MapMarker(
                                latitude: _currentLocation!.latitude,
                                longitude: _currentLocation!.longitude,
                                child: const Icon(
                                  Icons.my_location,
                                  color: Colors.blue,
                                  size: 30,
                                ),
                              );
                            } else if (index < _dataPoints1.length) {
                              String tooltipMessage =
                                  _properties1[index]['name'] ?? 'No Name';
                              return MapMarker(
                                latitude: _dataPoints1[index].latitude,
                                longitude: _dataPoints1[index].longitude,
                                child: GestureDetector(
                                  onTap: () {
                                    _showMarkerInfo(context, tooltipMessage);
                                  },
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 24,
                                  ),
                                ),
                              );
                            } else {
                              int adjustedIndex = index - _dataPoints1.length;
                              String tooltipMessage =
                                  _properties2[adjustedIndex]['DEPART_NM'] ??
                                      'No Name';
                              return MapMarker(
                                latitude: _dataPoints2[adjustedIndex].latitude,
                                longitude:
                                    _dataPoints2[adjustedIndex].longitude,
                                child: GestureDetector(
                                  onTap: () {
                                    _showMarkerInfo(context, tooltipMessage);
                                  },
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Colors.green,
                                    size: 24,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMarkerInfo(BuildContext context, String info) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Marker Info'),
          content: Text(info),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
                FocusScope.of(context).unfocus(); // 가상 키보드 내리기
              },
            ),
          ],
        );
      },
    );
  }
}
