import 'package:flutter/material.dart';
import '../../models/melding_model.dart';

class MeldingCard extends StatelessWidget {
  final Melding melding;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showDeleteButton;

  const MeldingCard({
    Key? key,
    required this.melding,
    this.onTap,
    this.onDelete,
    this.showDeleteButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Category en datum
              Row(
                children: [
                  // Category badge
                  _CategoryBadge(category: melding.category),
                  const Spacer(),
                  // Datum
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        melding.getFormattedDate(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Beschrijving
              Text(
                melding.description,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF481d39),
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Locatie
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: Color(0xFFbd213f),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      melding.address,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Photos preview (als er foto's zijn)
              if (melding.photoUrls.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.photo_library,
                      size: 16,
                      color: Color(0xFFf5a623),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${melding.photoUrls.length} foto${melding.photoUrls.length != 1 ? "\'s" : ""}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFf5a623),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],

              // Delete button (als enabled)
              if (showDeleteButton && onDelete != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 4),
                InkWell(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.delete_outline,
                          color: Color(0xFFbd213f),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Melding verwijderen',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFbd213f),
                            fontFamily: 'Oswald',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Category badge widget
class _CategoryBadge extends StatelessWidget {
  final String category;

  const _CategoryBadge({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryData = MeldingCategories.getCategoryById(category);
    final icon = categoryData?['icon'] ?? '📋';
    final name = categoryData?['name'] ?? category;

    return Container(
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
            icon,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 6),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF481d39),
              fontFamily: 'Oswald',
            ),
          ),
        ],
      ),
    );
  }
}

/// Compacte versie van een melding card (voor in de kaart)
class CompactMeldingCard extends StatelessWidget {
  final Melding melding;
  final VoidCallback? onTap;

  const CompactMeldingCard({
    Key? key,
    required this.melding,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _CategoryBadge(category: melding.category),
              const SizedBox(height: 8),
              Text(
                melding.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF481d39),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                melding.getFormattedDate(),
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty state widget als er geen meldingen zijn
class EmptyMeldingenState extends StatelessWidget {
  final String message;
  final String? actionText;
  final VoidCallback? onActionPressed;

  const EmptyMeldingenState({
    Key? key,
    this.message = 'Je hebt nog geen meldingen gemaakt',
    this.actionText,
    this.onActionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.report_problem_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontFamily: 'Oswald',
              ),
            ),
            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onActionPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFf5a623),
                  foregroundColor: const Color(0xFF481d39),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  actionText!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Oswald',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}