import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'profiel_screen.dart';
import 'inbox_screen.dart';
import 'pinned_locations_screen.dart';
import 'faq_screen.dart';
import 'dart:async';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import 'package:geolocator/geolocator.dart' as gl;
import 'meldingen/melding_maken_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/melding_service.dart';
import '../services/pin_service.dart';
import '../models/melding_model.dart';
import '../listeners/melding_click_listener.dart';
import '../widgets/meldingen/melding_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MeldingService _meldingService = MeldingService();
  final PinService _pinService = PinService();
  mb.MapboxMap? mapboxMapController;
  StreamSubscription? userPositionStream;
  StreamSubscription<List<Melding>>? meldingenStream;
  mb.PointAnnotationManager? pointAnnotationManager;
  Uint8List? mapMarkerImageData;
  final Map<String, Melding> _annotationsMap = {};
  Melding? _selectedMelding;
  bool _showMeldingCard = false;
  gl.Position? _currentPosition;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    // Zet mapbox token uit .env
    final token = dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';
    if (token.isNotEmpty) {
      mb.MapboxOptions.setAccessToken(token);
      /*print('Mapbox token set: ${token.substring(0, 20)}...');
    } else {
      print('No Mapbox token found in .env');*/
    }

    _determinePosition();
  }

  @override
  void dispose() {
    meldingenStream?.cancel();
    userPositionStream?.cancel();
    super.dispose();
  }

  Future<void> _pinCurrentLocation() async {
    if (_currentPosition == null) {
      _showTopNotification(
        context,
        'Locatie nog niet beschikbaar, probeer het opnieuw',
        isError: true,
      );
      return;
    }

    final success = await _pinService.pinLocation(
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
    );

    if (success) {
      _showTopNotification(
        context,
        'Locatie gepind!',
        isError: false,
      );
    } else {
      final count = await _pinService.getPinCount();
      if (count >= 10) {
        _showTopNotification(
          context,
          'Maximum aantal pins bereikt (10). Verwijder eerst oude pins.',
          isError: true,
        );
      } else {
        _showTopNotification(
          context,
          'Kon locatie niet pinnen, probeer het opnieuw',
          isError: true,
        );
      }
    }
  }

  // Notificatie van boven met fade-out animatie
  void _showTopNotification(BuildContext context, String message, {required bool isError}) {
    final overlay = Overlay.of(context);
    OverlayEntry? overlayEntry;
    OverlayEntry? fadeOutEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 80,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: isError
                      ? const Color(0xFFbd213f)
                      : const Color(0xFFf5a623),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isError ? Icons.error_outline : Icons.check_circle_outline,
                    color: isError
                        ? const Color(0xFFbd213f)
                        : const Color(0xFFf5a623),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF481d39),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Fade out animatie na 2.5 seconden
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (overlayEntry != null) {
        overlayEntry.remove();
      }

      fadeOutEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: MediaQuery.of(context).padding.top + 80,
          left: 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              tween: Tween(begin: 1.0, end: 0.0),
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, -20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              onEnd: () {
                if (fadeOutEntry != null) {
                  fadeOutEntry!.remove();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: isError
                        ? const Color(0xFFbd213f)
                        : const Color(0xFFf5a623),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isError ? Icons.error_outline : Icons.check_circle_outline,
                      color: isError
                          ? const Color(0xFFbd213f)
                          : const Color(0xFFf5a623),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF481d39),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      overlay.insert(fadeOutEntry!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFeae2d5),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 100,
        height: 100,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MeldingMakenScreen(),
              ),
            );
          },
          backgroundColor: const Color(0xFFeae2d5),
          elevation: 0,
          shape: const CircleBorder(
              side: BorderSide(
                color: Color(0xFFbd213f),
                width: 5.0,
              )
          ),
          child: const Icon(
            Icons.priority_high,
            color: Color(0xFF481d39),
            size: 50,
          ),
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFbd213f),
        shape: const CircularNotchedRectangle(),
        notchMargin: -10,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.home, color: Colors.black, size: 32),
                  onPressed: () {},
                ),
                _buildPinIconWithBadge(),
                const SizedBox(width: 48), // space for FAB
                _buildInboxIconWithBadge(),
                IconButton(
                  icon: const Icon(Icons.person, color: Colors.black, size: 32),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfielScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),

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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FaqScreen(),
                        ),
                      );
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
                  ),
                ),

                // Floating action button voor pin maken
                Positioned(
                  bottom: 100,
                  right: 24,
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: FloatingActionButton(
                      onPressed: _pinCurrentLocation,
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
                //show melding card
                if (_showMeldingCard && _selectedMelding != null)
                  Positioned(
                    bottom: 175,
                    left: 16,
                    right: 16,
                    child: MeldingCard(
                      melding: _selectedMelding!,
                      showDeleteButton: false,
                      onClose: () {
                        setState(() {
                          _showMeldingCard = false;
                          _selectedMelding = null;
                        });
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinIconWithBadge() {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PinnedLocationsScreen(),
            ),
          );
        },
        icon: const Icon(
          Icons.push_pin,
          color: Colors.black,
          size: 32,
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('pinned_locations')
          .where('userId', isEqualTo: currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final pinCount = snapshot.data?.docs.length ?? 0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PinnedLocationsScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.push_pin,
                color: Colors.black,
                size: 32,
              ),
            ),
            if (pinCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFf5a623),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      pinCount > 9 ? '9+' : '$pinCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildInboxIconWithBadge() {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return IconButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InboxScreen(),
            ),
          );
        },
        icon: const Icon(
          Icons.inbox,
          color: Colors.black,
          size: 32,
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('notifications')
          .where('userId', isEqualTo: currentUser.uid)
          .where('isRead', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data?.docs.length ?? 0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InboxScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.inbox,
                color: Colors.black,
                size: 32,
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFf5a623),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _onMapCreated(mb.MapboxMap controller) async {
    final ByteData bytes = await rootBundle.load("assets/images/map-marker2.png");
    mapMarkerImageData = bytes.buffer.asUint8List();
    pointAnnotationManager = await controller.annotations.createPointAnnotationManager();

    pointAnnotationManager!.addOnPointAnnotationClickListener(
      MeldingPointClickListener(_annotationsMap, _onMeldingTapped),
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

  void _onMeldingTapped(Melding melding) {
    print("Tapped melding id: ${melding.id}");
    setState(() {
      _selectedMelding = melding;
      _showMeldingCard = true;
    });
  }

  void _showMeldingenOnMap() async {
    meldingenStream?.cancel();
    meldingenStream = _meldingService.getAllMeldingen().listen((List<Melding> meldingen) async {
      if (!mounted) return;

      pointAnnotationManager?.deleteAll();

      for (final melding in meldingen) {
        final pointAnnotationOptions = mb.PointAnnotationOptions(
          geometry: mb.Point(
            coordinates: mb.Position(
              melding.longitude,
              melding.latitude,
            ),
          ),
          image: mapMarkerImageData,
        );
        mb.PointAnnotation? pointAnnotation = await pointAnnotationManager?.create(pointAnnotationOptions);
        if (pointAnnotation != null) {
          _annotationsMap[pointAnnotation.id] = melding;
        }
      }
    }, onError: (e, stack) {
      print("Meldingen stream error: $e");
      print(stack.toString());
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    gl.LocationPermission permission;

    serviceEnabled = await gl.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await gl.Geolocator.checkPermission();
    if (permission == gl.LocationPermission.denied) {
      permission = await gl.Geolocator.requestPermission();
      if (permission == gl.LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == gl.LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    gl.LocationSettings locationSettings = gl.LocationSettings(
      accuracy: gl.LocationAccuracy.high,
      distanceFilter: 100,
    );

    userPositionStream?.cancel();
    userPositionStream = gl.Geolocator.getPositionStream(
        locationSettings: locationSettings).listen(
          (gl.Position? position) {
        if (position != null) {
          setState(() {
            _currentPosition = position;
          });

          if (mapboxMapController != null) {
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
        }
      },
    );
  }
}