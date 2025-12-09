import 'package:flutter/material.dart';
import '../../models/melding_model.dart';

class CategorySelector extends StatelessWidget {
  final String? selectedCategory;
  final Function(String) onCategorySelected;

  const CategorySelector({
    Key? key,
    this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Wat is het probleem?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Oswald',
            color: Color(0xFF481d39),
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: MeldingCategories.categories.length,
          itemBuilder: (context, index) {
            final category = MeldingCategories.categories[index];
            final isSelected = selectedCategory == category['id'];

            return _CategoryCard(
              category: category,
              isSelected: isSelected,
              onTap: () => onCategorySelected(category['id'] as String),
            );
          },
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    Key? key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF481d39).withOpacity(0.1)
              : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF481d39)
                : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Emoji icon
              Text(
                category['icon'] as String,
                style: const TextStyle(fontSize: 36),
              ),
              const SizedBox(height: 8),
              // Category name
              Text(
                category['name'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: const Color(0xFF481d39),
                  fontFamily: 'Oswald',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compacte versie van category selector (horizontale scroll)
class CompactCategorySelector extends StatelessWidget {
  final String? selectedCategory;
  final Function(String) onCategorySelected;

  const CompactCategorySelector({
    Key? key,
    this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: MeldingCategories.categories.length,
        itemBuilder: (context, index) {
          final category = MeldingCategories.categories[index];
          final isSelected = selectedCategory == category['id'];

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _CompactCategoryChip(
              category: category,
              isSelected: isSelected,
              onTap: () => onCategorySelected(category['id'] as String),
            ),
          );
        },
      ),
    );
  }
}

class _CompactCategoryChip extends StatelessWidget {
  final Map<String, dynamic> category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CompactCategoryChip({
    Key? key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF481d39)
              : Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF481d39)
                : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              category['icon'] as String,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 8),
            Text(
              category['name'] as String,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF481d39),
                fontFamily: 'Oswald',
              ),
            ),
          ],
        ),
      ),
    );
  }
}