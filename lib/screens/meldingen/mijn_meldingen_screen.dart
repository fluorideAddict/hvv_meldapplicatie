import 'package:flutter/material.dart';
import '../../models/melding_model.dart';
import '../../services/melding_service.dart';
import '../../widgets/meldingen/melding_card.dart';
import '../profiel_screen.dart';
import '../home_screen.dart';

class MijnMeldingenScreen extends StatefulWidget {
  const MijnMeldingenScreen({Key? key}) : super(key: key);

  @override
  State<MijnMeldingenScreen> createState() => _MijnMeldingenScreenState();
}

class _MijnMeldingenScreenState extends State<MijnMeldingenScreen> {
  final MeldingService _meldingService = MeldingService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFeae2d5),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFbd213f),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logoHVV2.png',
                    height: 50,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                StreamBuilder<List<Melding>>(
                  stream: _meldingService.getUserMeldingen(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF481d39),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Color(0xFFbd213f),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Er is een fout opgetreden',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                snapshot.error.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'Je hebt nog geen meldingen gemaakt',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    }

                    final meldingen = snapshot.data!;

                    return Column(
                      children: [
                        _buildStatisticsHeader(meldingen.length),

                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              await Future.delayed(const Duration(milliseconds: 500));
                            },
                            color: const Color(0xFF481d39),
                            child: ListView.builder(
                              padding: const EdgeInsets.only(top: 8, bottom: 80),
                              itemCount: meldingen.length,
                              itemBuilder: (context, index) {
                                final melding = meldingen[index];
                                return MeldingCard(
                                  melding: melding,
                                  onTap: () => _showMeldingDetails(context, melding),
                                  onDelete: () => _confirmDelete(context, melding),
                                  showDeleteButton: true,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: const Color(0xFFbd213f),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                                      (route) => false,
                                );
                              },
                              icon: const Icon(
                                Icons.home,
                                color: Colors.black,
                                size: 32,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                              },
                              icon: const Icon(
                                Icons.public,
                                color: Colors.black,
                                size: 32,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                              },
                              icon: const Icon(
                                Icons.inbox,
                                color: Colors.black,
                                size: 32,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.pushReplacement(
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsHeader(int totalMeldingen) {
    return Container(
      color: const Color(0xFFeae2d5), // Zelfde kleur als achtergrond
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.notifications_active,
              color: Color(0xFF481d39),
              size: 26,
            ),
            const SizedBox(width: 12),
            const Text(
              'Totaal',
              style: TextStyle(
                fontSize: 22,
                color: Color(0xFF481d39),
                fontWeight: FontWeight.bold,
                fontFamily: 'Oswald',
              ),
            ),
            const SizedBox(width: 10),
            Text(
              totalMeldingen.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF481d39),
                fontFamily: 'Oswald',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMeldingDetails(BuildContext context, Melding melding) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => MeldingDetailPopup(melding: melding),
    );
  }

  void _confirmDelete(BuildContext context, Melding melding) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFeae2d5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Melding verwijderen?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF481d39),
            fontFamily: 'Oswald',
            fontSize: 22,
          ),
        ),
        content: const Text(
          'Weet je zeker dat je deze melding wilt verwijderen? Dit kan niet ongedaan worden gemaakt.',
          style: TextStyle(
            color: Color(0xFF481d39),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuleren',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteMelding(melding);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFbd213f),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Verwijderen',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMelding(Melding melding) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Melding wordt verwijderd...'),
        duration: Duration(seconds: 1),
        backgroundColor: Color(0xFF481d39),
      ),
    );

    final success = await _meldingService.deleteMelding(melding.id);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Melding verwijderd'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Kon melding niet verwijderen'),
          backgroundColor: Color(0xFFbd213f),
        ),
      );
    }
  }
}

class MeldingDetailPopup extends StatelessWidget {
  final Melding melding;

  const MeldingDetailPopup({
    Key? key,
    required this.melding,
  }) : super(key: key);

  String _getFormattedDateTime() {
    final months = [
      'januari', 'februari', 'maart', 'april', 'mei', 'juni',
      'juli', 'augustus', 'september', 'oktober', 'november', 'december'
    ];

    final day = melding.createdAt.day;
    final month = months[melding.createdAt.month - 1];
    final year = melding.createdAt.year;
    final hour = melding.createdAt.hour.toString().padLeft(2, '0');
    final minute = melding.createdAt.minute.toString().padLeft(2, '0');

    return '$day $month $year om $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFeae2d5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFF481d39),
                    size: 28,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF481d39).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFF481d39),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        MeldingCategories.getCategoryById(melding.category)?['icon'] ?? '📋',
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          melding.getCategoryDisplayName(),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF481d39),
                                            fontFamily: 'Oswald',
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: Color(0xFF481d39),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _getFormattedDateTime(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF481d39),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),

                          Text(
                            melding.description,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF481d39),
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 16),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 18,
                                color: Color(0xFFbd213f),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  melding.address,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 18,
                                color: Color(0xFF481d39),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Status: ',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _getStatusText(melding.status),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF481d39),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          if (melding.photoUrls.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(
                                  Icons.photo_library,
                                  size: 18,
                                  color: Color(0xFFf5a623),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Bijgevoegde foto\'s (${melding.photoUrls.length})',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF481d39),
                                    fontFamily: 'Oswald',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 1,
                              ),
                              itemCount: melding.photoUrls.length,
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    melding.photoUrls[index],
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Color(0xFF481d39),
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.error_outline,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'pending':
        return 'In behandeling';
      case 'reviewed':
        return 'Bekeken';
      case 'resolved':
        return 'Opgelost';
      default:
        return 'Onbekend';
    }
  }
}