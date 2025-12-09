import 'package:flutter/material.dart';
import '../../models/melding_model.dart';
import '../../services/melding_service.dart';
import '../../widgets/meldingen/melding_card.dart';

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
      appBar: AppBar(
        backgroundColor: const Color(0xFFbd213f),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mijn meldingen',
          style: TextStyle(
            fontFamily: 'Oswald',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Melding>>(
        stream: _meldingService.getUserMeldingen(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF481d39),
              ),
            );
          }

          // Error state
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

          // Empty state
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return EmptyMeldingenState(
              message: 'Je hebt nog geen meldingen gemaakt',
              actionText: 'Maak je eerste melding',
              onActionPressed: () {
                Navigator.pop(context);
                // Trigger melding maken via home screen
              },
            );
          }

          // Success state - show list
          final meldingen = snapshot.data!;

          return Column(
            children: [
              // Statistics header
              _buildStatisticsHeader(meldingen.length),

              // List of meldingen
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    // Stream updates automatically
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
    );
  }

  /// Header met statistieken
  Widget _buildStatisticsHeader(int totalMeldingen) {
    return Container(
      color: const Color(0xFFf5a623).withOpacity(0.2),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.notifications_active,
            label: 'Totaal',
            value: totalMeldingen.toString(),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[400],
          ),
          _buildStatItem(
            icon: Icons.pending,
            label: 'In behandeling',
            value: totalMeldingen.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF481d39), size: 20),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF481d39),
                fontFamily: 'Oswald',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Toon details van een melding
  void _showMeldingDetails(BuildContext context, Melding melding) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MeldingDetailsSheet(melding: melding),
    );
  }

  /// Bevestig verwijderen van een melding
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

  /// Verwijder een melding
  Future<void> _deleteMelding(Melding melding) async {
    // Show loading
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

/// Bottom sheet met melding details
class _MeldingDetailsSheet extends StatelessWidget {
  final Melding melding;

  const _MeldingDetailsSheet({
    Key? key,
    required this.melding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFeae2d5),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF481d39).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF481d39),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          MeldingCategories.getCategoryById(melding.category)?['icon'] ?? '📋',
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          melding.getCategoryDisplayName(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF481d39),
                            fontFamily: 'Oswald',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Beschrijving
                  const Text(
                    'Beschrijving',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF481d39),
                      fontFamily: 'Oswald',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    melding.description,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Color(0xFF481d39),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Locatie
                  _buildDetailRow(
                    icon: Icons.location_on,
                    label: 'Locatie',
                    value: melding.address,
                  ),

                  const SizedBox(height: 12),

                  // Datum
                  _buildDetailRow(
                    icon: Icons.calendar_today,
                    label: 'Gemeld op',
                    value: melding.getFormattedDate(),
                  ),

                  const SizedBox(height: 12),

                  // Status
                  _buildDetailRow(
                    icon: Icons.info_outline,
                    label: 'Status',
                    value: _getStatusText(melding.status),
                  ),

                  // Foto's
                  if (melding.photoUrls.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Foto\'s',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF481d39),
                        fontFamily: 'Oswald',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: melding.photoUrls.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                melding.photoUrls[index],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Close button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF481d39),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Sluiten',
                        style: TextStyle(
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
        },
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF481d39),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF481d39),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
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