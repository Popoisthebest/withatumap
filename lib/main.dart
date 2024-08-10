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
  List<MapLatLng> _dataPoints4 = [];
  List<Map<String, dynamic>> _properties4 = [];
  MapLatLng? _currentLocation;
  late MapZoomPanBehavior _zoomPanBehavior;
  bool _isLoading = true;
  bool _showSeaPolice = true;
  bool _showShipData = true;
  bool _showHospitalData = true;
  bool _showAccommodationData = true;
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
    setState(() {
      _isLoading = true;
    });

    await Future.wait([
      _loadGeoJson1(),
      _loadGeoJson2(),
      _loadGeoJson3(),
      _loadGeoJson4(),
    ]);
    await _getCurrentLocation();
    _allSuggestions = [
      ..._properties1.map((e) => e['NAME'] ?? 'No Name'),
      ..._properties2.map((e) => e['DEPART_NM'] ?? 'No Name'),
      ..._properties3.map((e) => e['업소명'] ?? 'No Name'),
      ..._properties4.map((e) => e['업소명'] ?? 'No Name'),
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

  Future<void> _loadGeoJson4() async {
    final String response =
        await rootBundle.loadString('assets/datas/namhaS.geojson');
    final dataString = response.replaceAll('NaN', 'null');
    final data = json.decode(dataString);
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
      _dataPoints4 = points;
      _properties4 = properties;
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

    for (int i = 0; i < _properties4.length; i++) {
      if (_properties4[i]['업소명'] == query) {
        _zoomPanBehavior.focalLatLng = _dataPoints4[i];
        _zoomPanBehavior.zoomLevel = 15;
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('위치를 찾을 수 없습니다')),
    );
  }

  void _toggleCheckbox(bool? value, String layer) {
    setState(() {
      switch (layer) {
        case 'SeaPolice':
          _showSeaPolice = value ?? false;
          break;
        case 'ShipData':
          _showShipData = value ?? false;
          break;
        case 'HospitalData':
          _showHospitalData = value ?? false;
          break;
        case 'AccommodationData':
          _showAccommodationData = value ?? false;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter GeoJSON Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeData, // Refresh button to reload the map data
          ),
        ],
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
                    labelText: '위치 검색',
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Checkbox(
                        value: _showSeaPolice,
                        onChanged: (value) {
                          _toggleCheckbox(value, 'SeaPolice');
                        },
                      ),
                      const Text('해양경찰서 데이터'),
                    ],
                  ),
                  Column(
                    children: [
                      Checkbox(
                        value: _showShipData,
                        onChanged: (value) {
                          _toggleCheckbox(value, 'ShipData');
                        },
                      ),
                      const Text('항구 데이터'),
                    ],
                  ),
                  Column(
                    children: [
                      Checkbox(
                        value: _showHospitalData,
                        onChanged: (value) {
                          _toggleCheckbox(value, 'HospitalData');
                        },
                      ),
                      const Text('병원 데이터'),
                    ],
                  ),
                  Column(
                    children: [
                      Checkbox(
                        value: _showAccommodationData,
                        onChanged: (value) {
                          _toggleCheckbox(value, 'AccommodationData');
                        },
                      ),
                      const Text('숙박 데이터'),
                    ],
                  ),
                ],
              ),
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
                                  ? _getTotalDataPointCount() + 1
                                  : _getTotalDataPointCount()),
                              markerBuilder: (BuildContext context, int index) {
                                int seaPoliceCount =
                                    _showSeaPolice ? _dataPoints1.length : 0;
                                int shipDataCount =
                                    _showShipData ? _dataPoints2.length : 0;
                                int hospitalDataCount =
                                    _showHospitalData ? _dataPoints3.length : 0;
                                int accommodationDataCount =
                                    _showAccommodationData
                                        ? _dataPoints4.length
                                        : 0;

                                int totalDataPoints = seaPoliceCount +
                                    shipDataCount +
                                    hospitalDataCount +
                                    accommodationDataCount;

                                if (_currentLocation != null &&
                                    index == totalDataPoints) {
                                  return MapMarker(
                                    latitude: _currentLocation!.latitude,
                                    longitude: _currentLocation!.longitude,
                                    child: Image.asset(
                                      'assets/icons/yourlocation.png',
                                      width: 30,
                                      height: 30,
                                    ),
                                  );
                                }

                                if (_showSeaPolice &&
                                    index < _dataPoints1.length) {
                                  return MapMarker(
                                    latitude: _dataPoints1[index].latitude,
                                    longitude: _dataPoints1[index].longitude,
                                    child: GestureDetector(
                                      onTap: () {
                                        _showMarkerInfo(context,
                                            _properties1[index], 'seaPolice');
                                      },
                                      child: Image.asset(
                                        'assets/icons/policeicon2.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                    ),
                                  );
                                }

                                if (_showShipData &&
                                    index <
                                        seaPoliceCount + _dataPoints2.length) {
                                  int adjustedIndex = index - seaPoliceCount;
                                  return MapMarker(
                                    latitude:
                                        _dataPoints2[adjustedIndex].latitude,
                                    longitude:
                                        _dataPoints2[adjustedIndex].longitude,
                                    child: GestureDetector(
                                      onTap: () {
                                        _showMarkerInfo(
                                            context,
                                            _properties2[adjustedIndex],
                                            'ship');
                                      },
                                      child: Image.asset(
                                        'assets/icons/shipicon2.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                    ),
                                  );
                                }

                                if (_showHospitalData &&
                                    index <
                                        seaPoliceCount +
                                            shipDataCount +
                                            _dataPoints3.length) {
                                  int adjustedIndex =
                                      index - seaPoliceCount - shipDataCount;
                                  return MapMarker(
                                    latitude:
                                        _dataPoints3[adjustedIndex].latitude,
                                    longitude:
                                        _dataPoints3[adjustedIndex].longitude,
                                    child: GestureDetector(
                                      onTap: () {
                                        _showMarkerInfo(
                                            context,
                                            _properties3[adjustedIndex],
                                            'hospital');
                                      },
                                      child: Image.asset(
                                        'assets/icons/namhaHicon.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                    ),
                                  );
                                }

                                if (_showAccommodationData &&
                                    index <
                                        seaPoliceCount +
                                            shipDataCount +
                                            hospitalDataCount +
                                            _dataPoints4.length) {
                                  int adjustedIndex = index -
                                      seaPoliceCount -
                                      shipDataCount -
                                      hospitalDataCount;
                                  return MapMarker(
                                    latitude:
                                        _dataPoints4[adjustedIndex].latitude,
                                    longitude:
                                        _dataPoints4[adjustedIndex].longitude,
                                    child: GestureDetector(
                                      onTap: () {
                                        _showMarkerInfo(
                                            context,
                                            _properties4[adjustedIndex],
                                            'accommodation');
                                      },
                                      child: Image.asset(
                                        'assets/icons/namhaSicon.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                    ),
                                  );
                                }

                                return MapMarker(
                                  latitude: 0,
                                  longitude: 0,
                                  child: Container(), // Return an empty marker
                                );
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
                                  iconPath: 'assets/icons/policeicon2.png',
                                  text: '해양경찰서 데이터',
                                ),
                                LegendItem(
                                  iconPath: 'assets/icons/shipicon2.png',
                                  text: '항구 데이터',
                                ),
                                LegendItem(
                                  iconPath: 'assets/icons/namhaHicon.png',
                                  text: '남해병원 데이터',
                                ),
                                LegendItem(
                                  iconPath: 'assets/icons/namhaSicon.png',
                                  text: '숙박 데이터',
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

  int _getTotalDataPointCount() {
    int totalCount = 0;
    if (_showSeaPolice) totalCount += _dataPoints1.length;
    if (_showShipData) totalCount += _dataPoints2.length;
    if (_showHospitalData) totalCount += _dataPoints3.length;
    if (_showAccommodationData) totalCount += _dataPoints4.length;
    return totalCount;
  }

  void _showMarkerInfo(
      BuildContext context, Map<String, dynamic> properties, String type) {
    List<Widget> infoWidgets = [];

    String cleanValue(String? value) {
      if (value == null ||
          value.trim().isEmpty ||
          value == 'N/A' ||
          value == "NaN" ||
          value == "\n") {
        return '제공되지 않음';
      }
      return value;
    }

    if (type == 'seaPolice') {
      infoWidgets.add(Text('주소: ${cleanValue(properties['RNADRES'])}'));
    } else if (type == 'ship') {
      infoWidgets.add(Text('배 갯수: ${cleanValue(properties['SHIP_CNT'])}'));
    } else if (type == 'hospital') {
      infoWidgets.add(Text('전화번호: ${cleanValue(properties['전화번호'])}'));
      infoWidgets.add(Text('주소: ${cleanValue(properties['주소'])}'));
      infoWidgets.add(Text('토요일 시작 시간: ${cleanValue(properties['토요일시작시간'])}'));
      infoWidgets.add(Text('토요일 종료 시간: ${cleanValue(properties['토요일종료시간'])}'));
      infoWidgets.add(Text('공휴일 시작 시간: ${cleanValue(properties['공휴일시작시간'])}'));
      infoWidgets.add(Text('공휴일 종료 시간: ${cleanValue(properties['공휴일종료시간'])}'));
      infoWidgets.add(Text('평일 시작 시간: ${cleanValue(properties['평일시작시간'])}'));
      infoWidgets.add(Text('평일 종료 시간: ${cleanValue(properties['평일종료시간'])}'));
      infoWidgets.add(Text('응급실 여부: ${cleanValue(properties['비고'])}'));
    } else if (type == 'accommodation') {
      infoWidgets.add(Text('전화번호: ${cleanValue(properties['전화번호'])}'));
      infoWidgets.add(Text('주소: ${cleanValue(properties['주소'])}'));
      infoWidgets.add(Text('주차장 여부: ${cleanValue(properties['주차장여부'])}'));
      infoWidgets.add(Text('주차 대수: ${cleanValue(properties['주차대수'])}'));
      infoWidgets.add(Text('애완동물 동행여부: ${cleanValue(properties['애완동물동행여부'])}'));
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(properties['NAME'] ??
              properties['DEPART_NM'] ??
              properties['업소명'] ??
              'Marker Info'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: infoWidgets,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('닫기'),
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
  final String iconPath;
  final String text;

  const LegendItem({required this.iconPath, required this.text, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          iconPath,
          width: 24,
          height: 24,
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
