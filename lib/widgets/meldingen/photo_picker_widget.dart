import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/storage_service.dart';

class PhotoPickerWidget extends StatefulWidget {
  final List<File> selectedPhotos;
  final Function(List<File>) onPhotosChanged;
  final int maxPhotos;

  const PhotoPickerWidget({
    Key? key,
    required this.selectedPhotos,
    required this.onPhotosChanged,
    this.maxPhotos = 5,
  }) : super(key: key);

  @override
  State<PhotoPickerWidget> createState() => _PhotoPickerWidgetState();
}

class _PhotoPickerWidgetState extends State<PhotoPickerWidget> {
  final StorageService _storageService = StorageService();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Foto\'s toevoegen (optioneel)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Oswald',
                color: Color(0xFF481d39),
              ),
            ),
            Text(
              '${widget.selectedPhotos.length}/${widget.maxPhotos}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.camera_alt,
                label: 'Camera',
                color: const Color(0xFFf5a623),
                onTap: widget.selectedPhotos.length < widget.maxPhotos
                    ? _pickFromCamera
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.photo_library,
                label: 'Galerij',
                color: const Color(0xFF481d39),
                onTap: widget.selectedPhotos.length < widget.maxPhotos
                    ? _pickFromGallery
                    : null,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Photo grid
        if (widget.selectedPhotos.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: widget.selectedPhotos.length,
            itemBuilder: (context, index) {
              return _PhotoThumbnail(
                photo: widget.selectedPhotos[index],
                onDelete: () => _deletePhoto(index),
              );
            },
          ),
      ],
    );
  }

  Future<void> _pickFromCamera() async {
    final photo = await _storageService.pickPhotoFromCamera();
    if (photo != null) {
      setState(() {
        final updatedPhotos = List<File>.from(widget.selectedPhotos)..add(photo);
        widget.onPhotosChanged(updatedPhotos);
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final remainingSlots = widget.maxPhotos - widget.selectedPhotos.length;
    final photos = await _storageService.pickMultiplePhotos(maxImages: remainingSlots);

    if (photos.isNotEmpty) {
      setState(() {
        final updatedPhotos = List<File>.from(widget.selectedPhotos)..addAll(photos);
        widget.onPhotosChanged(updatedPhotos);
      });
    }
  }

  void _deletePhoto(int index) {
    setState(() {
      final updatedPhotos = List<File>.from(widget.selectedPhotos)..removeAt(index);
      widget.onPhotosChanged(updatedPhotos);
    });
  }
}

/// Action button voor camera/galerij
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey[300] : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDisabled ? Colors.grey[400]! : color,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isDisabled ? Colors.grey[600] : color,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDisabled ? Colors.grey[600] : color,
                fontFamily: 'Oswald',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thumbnail van een geselecteerde foto
class _PhotoThumbnail extends StatelessWidget {
  final File photo;
  final VoidCallback onDelete;

  const _PhotoThumbnail({
    Key? key,
    required this.photo,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Photo
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            photo,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),

        // Delete button
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CompactPhotoPickerButton extends StatelessWidget {
  final VoidCallback onTap;
  final int photoCount;

  const CompactPhotoPickerButton({
    Key? key,
    required this.onTap,
    this.photoCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF481d39),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.add_a_photo,
              color: Color(0xFF481d39),
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              photoCount > 0 ? '$photoCount foto\'s toegevoegd' : 'Foto\'s toevoegen',
              style: const TextStyle(
                fontSize: 16,
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
}