import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'dart:async';

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
  List<MapLatLng> _dataPoints3 = [];
  List<Map<String, dynamic>> _properties3 = [];
  MapLatLng? _currentLocation;
  late MapZoomPanBehavior _zoomPanBehavior;
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  List<String> _allSuggestions = [];

  @override
  void initState() {
    super.initState();
    _zoomPanBehavior = MapZoomPanBehavior(
      focalLatLng: const MapLatLng(36.5, 127.5),
      zoomLevel: 7,
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
      _loadGeoJson3(),
    ]);
    await _getCurrentLocation();
    _allSuggestions = [
      ..._properties1.map((e) => e['NAME'] ?? 'No Name'),
      ..._properties2.map((e) => e['DEPART_NM'] ?? 'No Name'),
      ..._properties3.map((e) => e['업소명'] ?? 'No Name'),
    ];
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadGeoJson1() async {
    final String response =
        await rootBundle.loadString('assets/datas/seaPolice.geojson');
    final data = json.decode(response);
    final List<MapLatLng> points = [];
    final List<Map<String, dynamic>> properties = [];

    for (var feature in data['features']) {
      if (feature['geometry']['type'] == 'Point') {
        var coordinates = feature['geometry']['coordinates'];
        points.add(MapLatLng(
          coordinates[1].toDouble(),
          coordinates[0].toDouble(),
        ));
        properties.add(feature['properties']);
      }
    }

    setState(() {
      _dataPoints1 = points;
      _properties1 = properties;
    });
  }

  Future<void> _loadGeoJson2() async {
    final String response =
        await rootBundle.loadString('assets/datas/ship.geojson');
    final data = json.decode(response);
    final List<MapLatLng> points = [];
    final List<Map<String, dynamic>> properties = [];

    for (var feature in data['features']) {
      if (feature['geometry']['type'] == 'Point') {
        var coordinates = feature['geometry']['coordinates'];
        points.add(MapLatLng(
          coordinates[1].toDouble(),
          coordinates[0].toDouble(),
        ));
        properties.add(feature['properties']);
      }
    }

    setState(() {
      _dataPoints2 = points;
      _properties2 = properties;
    });
  }

  Future<void> _loadGeoJson3() async {
    final String response =
        await rootBundle.loadString('assets/datas/namhaHData.geojson');
    final data = json.decode(response);
    final List<MapLatLng> points = [];
    final List<Map<String, dynamic>> properties = [];

    for (var feature in data['features']) {
      if (feature['geometry']['type'] == 'Point') {
        var coordinates = feature['geometry']['coordinates'];
        points.add(MapLatLng(
          coordinates[1].toDouble(),
          coordinates[0].toDouble(),
        ));
        properties.add(feature['properties']);
      }
    }

    setState(() {
      _dataPoints3 = points;
      _properties3 = properties;
    });
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
    FocusScope.of(context).unfocus();
    for (int i = 0; i < _properties1.length; i++) {
      if (_properties1[i]['NAME'] == query) {
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

    for (int i = 0; i < _properties3.length; i++) {
      if (_properties3[i]['업소명'] == query) {
        _zoomPanBehavior.focalLatLng = _dataPoints3[i];
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
                  : Stack(
                      children: [
                        SfMaps(
                          layers: [
                            MapTileLayer(
                              initialFocalLatLng: const MapLatLng(36.5, 127.5),
                              initialZoomLevel: 7,
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              zoomPanBehavior: _zoomPanBehavior,
                              initialMarkersCount: (_currentLocation != null
                                  ? _dataPoints1.length +
                                      _dataPoints2.length +
                                      _dataPoints3.length +
                                      1
                                  : _dataPoints1.length +
                                      _dataPoints2.length +
                                      _dataPoints3.length),
                              markerBuilder: (BuildContext context, int index) {
                                if (_currentLocation != null &&
                                    index ==
                                        _dataPoints1.length +
                                            _dataPoints2.length +
                                            _dataPoints3.length) {
                                  return MapMarker(
                                    latitude: _currentLocation!.latitude,
                                    longitude: _currentLocation!.longitude,
                                    child: Image.asset(
                                      'assets/icons/yourlocation.png',
                                      width: 30,
                                      height: 30,
                                    ),
                                  );
                                } else if (index < _dataPoints1.length) {
                                  return MapMarker(
                                    latitude: _dataPoints1[index].latitude,
                                    longitude: _dataPoints1[index].longitude,
                                    child: GestureDetector(
                                      onTap: () {
                                        _showMarkerInfo(
                                            context, _properties1[index], true);
                                      },
                                      child: Image.asset(
                                        'assets/icons/policeicon2.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                    ),
                                  );
                                } else if (index <
                                    _dataPoints1.length + _dataPoints2.length) {
                                  int adjustedIndex =
                                      index - _dataPoints1.length;
                                  return MapMarker(
                                    latitude:
                                        _dataPoints2[adjustedIndex].latitude,
                                    longitude:
                                        _dataPoints2[adjustedIndex].longitude,
                                    child: GestureDetector(
                                      onTap: () {
                                        _showMarkerInfo(context,
                                            _properties2[adjustedIndex], false);
                                      },
                                      child: Image.asset(
                                        'assets/icons/shipicon2.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                    ),
                                  );
                                } else {
                                  int adjustedIndex = index -
                                      _dataPoints1.length -
                                      _dataPoints2.length;
                                  return MapMarker(
                                    latitude:
                                        _dataPoints3[adjustedIndex].latitude,
                                    longitude:
                                        _dataPoints3[adjustedIndex].longitude,
                                    child: GestureDetector(
                                      onTap: () {
                                        _showMarkerInfo(context,
                                            _properties3[adjustedIndex], false);
                                      },
                                      child: Image.asset(
                                        'assets/icons/namhaHicon.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            color: Colors.white,
                            padding: const EdgeInsets.all(8.0),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LegendItem(
                                  color: Colors.red,
                                  text: '해양경찰서 데이터',
                                ),
                                LegendItem(
                                  color: Colors.green,
                                  text: '항구 데이터',
                                ),
                                LegendItem(
                                  color: Colors.blue,
                                  text: '남해병원 데이터',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMarkerInfo(
      BuildContext context, Map<String, dynamic> properties, bool isSeaPolice) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            properties['NAME'] ??
                properties['DEPART_NM'] ??
                properties['업소명'] ??
                'Marker Info',
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: properties.entries.where((entry) {
              if (isSeaPolice) {
                return entry.key == 'RNADRES';
              } else if (properties.containsKey('DEPART_NM')) {
                return entry.key == 'SHIP_CNT' || entry.key == 'DEPART_NM';
              } else {
                return entry.key == '전화번호' ||
                    entry.key == '주소' ||
                    entry.key == '업소명';
              }
            }).map((entry) {
              return Text('${entry.key}: ${entry.value}');
            }).toList(),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
                FocusScope.of(context).unfocus();
              },
            ),
          ],
        );
      },
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const LegendItem({required this.color, required this.text, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
