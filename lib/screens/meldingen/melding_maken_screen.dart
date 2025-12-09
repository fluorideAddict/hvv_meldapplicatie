import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mb;
import '../../services/melding_service.dart';
import '../../widgets/meldingen/category_selector.dart';
import '../../widgets/meldingen/photo_picker_widget.dart';

class MeldingMakenScreen extends StatefulWidget {
  const MeldingMakenScreen({Key? key}) : super(key: key);

  @override
  State<MeldingMakenScreen> createState() => _MeldingMakenScreenState();
}

class _MeldingMakenScreenState extends State<MeldingMakenScreen> {
  final MeldingService _meldingService = MeldingService();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Form state
  String? _selectedCategory;
  List<File> _selectedPhotos = [];
  bool _isLoadingLocation = true;
  bool _isSubmitting = false;

  // Location state
  double? _latitude;
  double? _longitude;
  String _address = '';
  mb.MapboxMap? _mapController;

  // Page controller voor multi-step form
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _addressController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// Haal de huidige GPS locatie op
  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Locatie toestemming geweigerd');
          return;
        }
      }

      // Get position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _address = 'Locatie: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        _addressController.text = _address;
        _isLoadingLocation = false;
      });

      print('✅ Location acquired: $_latitude, $_longitude');
    } catch (e) {
      print('❌ Error getting location: $e');
      setState(() => _isLoadingLocation = false);
      _showError('Kon locatie niet ophalen');
    }
  }

  /// Ga naar de volgende pagina
  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Ga naar de vorige pagina
  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Valideer en verzend de melding
  Future<void> _submitMelding() async {
    // Validatie
    if (_selectedCategory == null) {
      _showError('Selecteer een categorie');
      return;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showError('Voeg een beschrijving toe');
      return;
    }

    if (_latitude == null || _longitude == null) {
      _showError('Locatie niet gevonden');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await _meldingService.createMelding(
        category: _selectedCategory!,
        description: _descriptionController.text.trim(),
        latitude: _latitude!,
        longitude: _longitude!,
        address: _addressController.text.trim(),
        photoFiles: _selectedPhotos.isNotEmpty ? _selectedPhotos : null,
      );

      if (result['success']) {
        _showSuccessDialog();
      } else {
        _showError(result['error'] ?? 'Er is een fout opgetreden');
      }
    } catch (e) {
      _showError('Er is een fout opgetreden: $e');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog() {
    // Lijst met verkeersveiligheid facts
    final facts = [
      'Wist je dat 30 km/u zones het aantal ongevallen met 40% verminderen?',
      'Fietshelmen verkleinen het risico op hoofdletsel met 70%!',
      'Goede straatverlichting vermindert verkeersongevallen met 30%.',
      'Zebrapadden met verlichting zijn 50% veiliger dan zonder.',
      'Reflecterende kleding maakt je 3x beter zichtbaar in het donker.',
      'Drempels verlagen de snelheid gemiddeld met 20 km/u.',
      'Rotonde\'s zijn 50% veiliger dan klassieke kruispunten.',
      'Bromfietsers met helm hebben 40% minder kans op ernstig letsel.',
      'Snelheidsduivels veroorzaken 30% van alle verkeersongevallen.',
      'Goede fietspaden verminderen fietsongevallen met 50%.',
      'LED-straatverlichting verbetert zichtbaarheid met 60%.',
      'Oversteekplaatsen met signalisatie zijn 70% veiliger.',
      'Schoolzones met 30 km/u zijn bewezen veiliger voor kinderen.',
      'Verkeersborden met reflectie zijn \'s nachts 4x beter zichtbaar.',
      'Goed onderhouden wegen verminderen ongevallen met 25%.',
    ];

    final randomFact = (facts..shuffle()).first;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFeae2d5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Melding verzonden!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF481d39),
            fontFamily: 'Oswald',
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Color(0xFF4CAF50),
              size: 80,
            ),
            const SizedBox(height: 16),
            const Text(
              'Bedankt voor je melding!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF481d39),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFf5a623).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFf5a623),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    '💡 Verkeersveiligheid tip',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF481d39),
                      fontFamily: 'Oswald',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    randomFact,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF481d39),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
            },
            child: const Text(
              'Terug naar home',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF481d39),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFbd213f),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFeae2d5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFbd213f),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nieuwe melding',
          style: TextStyle(
            fontFamily: 'Oswald',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),

          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (page) {
                setState(() => _currentPage = page);
              },
              children: [
                _buildLocationPage(),
                _buildCategoryPage(),
                _buildDescriptionPage(),
                _buildPhotosPage(),
              ],
            ),
          ),

          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      color: const Color(0xFFbd213f),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index == _currentPage;
          final isCompleted = index < _currentPage;

          return Expanded(
            child: Container(
              margin: EdgeInsets.only(left: index > 0 ? 8 : 0),
              height: 6,
              decoration: BoxDecoration(
                color: isCompleted || isActive
                    ? const Color(0xFFf5a623)
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLocationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Waar is het probleem?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Oswald',
              color: Color(0xFF481d39),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We gebruiken je huidige locatie. Je kunt deze later aanpassen.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          if (_isLoadingLocation)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(
                  color: Color(0xFF481d39),
                ),
              ),
            )
          else ...[
            // Map
            Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF481d39), width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: mb.MapWidget(
                  onMapCreated: (controller) {
                    _mapController = controller;
                    if (_latitude != null && _longitude != null) {
                      controller.setCamera(
                        mb.CameraOptions(
                          center: mb.Point(
                            coordinates: mb.Position(_longitude!, _latitude!),
                          ),
                          zoom: 15,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Address input
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Adres of locatie',
                prefixIcon: const Icon(Icons.location_on, color: Color(0xFF481d39)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF481d39), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF481d39), width: 2),
                ),
              ),
              onChanged: (value) => _address = value,
            ),

            const SizedBox(height: 12),

            // Refresh location button
            OutlinedButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.refresh),
              label: const Text('Ververs locatie'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF481d39),
                side: const BorderSide(color: Color(0xFF481d39), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: CategorySelector(
        selectedCategory: _selectedCategory,
        onCategorySelected: (category) {
          setState(() => _selectedCategory = category);
        },
      ),
    );
  }

  Widget _buildDescriptionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Beschrijf het probleem',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Oswald',
              color: Color(0xFF481d39),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hoe concreter, hoe beter de gemeente kan helpen!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          TextField(
            controller: _descriptionController,
            maxLines: 8,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Bijvoorbeeld: Grote gaten in het wegdek die gevaarlijk zijn voor fietsers...',
              filled: true,
              fillColor: Colors.white.withOpacity(0.6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF481d39), width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF481d39), width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Foto\'s toevoegen',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Oswald',
              color: Color(0xFF481d39),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Foto\'s helpen de gemeente het probleem beter te begrijpen.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          PhotoPickerWidget(
            selectedPhotos: _selectedPhotos,
            onPhotosChanged: (photos) {
              setState(() => _selectedPhotos = photos);
            },
            maxPhotos: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      color: Colors.white.withOpacity(0.8),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentPage > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousPage,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF481d39),
                    side: const BorderSide(color: Color(0xFF481d39), width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Vorige',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Oswald',
                    ),
                  ),
                ),
              ),
            if (_currentPage > 0) const SizedBox(width: 16),
            Expanded(
              flex: _currentPage > 0 ? 1 : 1,
              child: ElevatedButton(
                onPressed: _currentPage < 3
                    ? _nextPage
                    : _isSubmitting
                    ? null
                    : _submitMelding,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFf5a623),
                  foregroundColor: const Color(0xFF481d39),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF481d39)),
                  ),
                )
                    : Text(
                  _currentPage < 3 ? 'Volgende' : 'Verzenden',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Oswald',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}