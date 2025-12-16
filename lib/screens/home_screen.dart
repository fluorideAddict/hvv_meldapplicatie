import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'profiel_screen.dart';
import 'dart:async';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import 'package:geolocator/geolocator.dart' as gl;
import 'meldingen/melding_maken_screen.dart';
import '../services/melding_service.dart';
import '../models/melding_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MeldingService _meldingService = MeldingService();
  mb.MapboxMap? mapboxMapController;
  StreamSubscription? userPositionStream;
  StreamSubscription<List<Melding>>? meldingenStream;
  mb.PointAnnotationManager? pointAnnotationManager;
  Uint8List? mapMarkerImageData;
  List<Melding> renderedMeldingen = <Melding>[];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }
  @override
  void dispose() {
    meldingenStream?.cancel();
    userPositionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFeae2d5),
      body: Column(
        children: [
          // Rode header met logo en vraagteken
          Container(
            color: const Color(0xFFbd213f),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'assets/images/logoHVV2.png',
                        height: 50,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: Help/info pagina openen
                    },
                    icon: const Icon(
                      Icons.help_outline,
                      color: Colors.white,
                      size: 32,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),
          // Content area
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: mb.MapWidget(
                    onMapCreated: _onMapCreated,
                    onTapListener: _onMapTap,
                  ),
                ),
                // Floating action button voor melding maken
                Positioned(
                  bottom: 100,
                  right: 24,
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: FloatingActionButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MeldingMakenScreen(),
                          ),
                        );
                      },
                      backgroundColor: const Color(0xFFf5a623),
                      shape: const CircleBorder(),
                      child: const Icon(
                        Icons.push_pin,
                        color: Color(0xFF481d39),
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Rode footer met 4 iconen
          Container(
            color: const Color(0xFFbd213f),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Home icoon
                    IconButton(
                      onPressed: () {
                        // Al op home
                      },
                      icon: const Icon(
                        Icons.home,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                    // Wereld/globe icoon
                    IconButton(
                      onPressed: () {
                        // TODO: Navigeer naar wereld/ontdek pagina
                      },
                      icon: const Icon(
                        Icons.public,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                    // Inbox/berichten icoon
                    IconButton(
                      onPressed: () {
                        // TODO: Navigeer naar berichten
                      },
                      icon: const Icon(
                        Icons.inbox,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                    // Profiel icoon
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfielScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.person,
                        color: Colors.black,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(mb.MapboxMap controller) async {
    final ByteData bytes = await rootBundle.load("assets/images/map-marker2.png");
    mapMarkerImageData = bytes.buffer.asUint8List();
    pointAnnotationManager = await controller.annotations.createPointAnnotationManager();

    pointAnnotationManager!.addOnPointAnnotationClickListener(
          (mb.PointAnnotation annotation) {
        final userInfo = annotation.userInfo;
        if (userInfo == null) return false;

        final meldingId = userInfo['meldingId'];
        _onMeldingTapped(meldingId);

        return true;
      },
    );

    setState(() {
      mapboxMapController = controller;
    });
    mapboxMapController?.location.updateSettings(
      mb.LocationComponentSettings(
        enabled: true,
      ),
    );
    mapboxMapController?.scaleBar.updateSettings(
      mb.ScaleBarSettings(
        enabled: false,
      ),
    );

    _showMeldingenOnMap();
  }
  Future<void> _onMapTap(mb.ScreenCoordinate screenCoordinate) async {
    final queryGeometry =
    mb.RenderedQueryGeometry.fromScreenCoordinate(screenCoordinate);

    final results = await mapboxMapController?.queryRenderedFeatures(
      queryGeometry,
      mb.RenderedQueryOptions(
        layerIds: null,
        filter: null,
      ),
    );

    if (results == null || results.isEmpty) return;

    for (final queried in results) {
      final sourceFeature = queried?.sourceFeature;
      if (sourceFeature == null) continue;

      final properties = sourceFeature.properties;
      if (properties == null) continue;

      // userInfo from PointAnnotation ends up here
      if (properties.containsKey('meldingId')) {
        final meldingId = properties['meldingId'];
        _onMeldingTapped(meldingId);
        break;
      }
    }
  }

  void _showMeldingenOnMap() async {
    meldingenStream?.cancel();
    //await Future.delayed(const Duration(seconds: 1));
    //List<Melding> meldingenList = <Melding>[];
    //pointAnnotationManager?.deleteAll();
    meldingenStream = _meldingService.getAllMeldingen().listen((List<Melding> meldingen) {
      if (!mounted) return;

      pointAnnotationManager?.deleteAll();

      //TODO: Store all melding data locally? It's ID at least? This way it does not need to be requested everytime
      for (final melding in meldingen) {
        final pointAnnotationOptions = mb.PointAnnotationOptions(
          geometry: mb.Point(
            coordinates: mb.Position(
              melding.longitude,
              melding.latitude,
            ),
          ),
          image: mapMarkerImageData,
          //iconSize: 3.0,
        );
        Future<mb.PointAnnotation>? pointAnnotation = pointAnnotationManager?.create(pointAnnotationOptions);
      }
    }, onError: (e, stack) {
      //Pop up notification?
      print("Meldingen stream error: $e");
      print(stack.toString());
    });
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    gl.LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await gl.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await gl.Geolocator.checkPermission();
    if (permission == gl.LocationPermission.denied) {
      permission = await gl.Geolocator.requestPermission();
      if (permission == gl.LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == gl.LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    gl.LocationSettings locationSettings = gl.LocationSettings(
      accuracy: gl.LocationAccuracy.high,
      distanceFilter: 100,
    );
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.

    userPositionStream?.cancel();
    userPositionStream = gl.Geolocator.getPositionStream(
        locationSettings: locationSettings).listen(
          (
          gl.Position? position,
          ) {
        if (position != null && mapboxMapController != null) {
          mapboxMapController?.setCamera(
              mb.CameraOptions(
                  center: mb.Point(
                      coordinates: mb.Position(
                        position.longitude,
                        position.latitude,
                      )
                  ),
                  zoom: 15,
                  bearing: 0,
                  pitch: 0
              )
          );
        }
      },
    );
  }
}