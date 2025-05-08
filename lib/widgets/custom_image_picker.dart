import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CustomImagePicker extends StatefulWidget {
  final List<File> initialImages;
  final Function(List<File>) onImagesChanged;
  final int maxImages;

  const CustomImagePicker({
    super.key,
    this.initialImages = const [],
    required this.onImagesChanged,
    this.maxImages = 5,
  });

  @override
  State<CustomImagePicker> createState() => _CustomImagePickerState();
}

class _CustomImagePickerState extends State<CustomImagePicker> {
  final ImagePicker _picker = ImagePicker();
  late List<File> _imageFiles;

  @override
  void initState() {
    super.initState();
    _imageFiles = List.from(widget.initialImages);
  }

  Future<void> _selectImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        if (widget.maxImages == 1) {
          _imageFiles = [File(picked.path)];
        } else {
          _imageFiles.add(File(picked.path));
        }
      });
      widget.onImagesChanged(_imageFiles);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
    });
    widget.onImagesChanged(_imageFiles);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canAddMore = _imageFiles.length < widget.maxImages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.maxImages > 1)
          Text(
            'Add images (${_imageFiles.length}/${widget.maxImages})',
            style: theme.textTheme.titleMedium,
          ),
        if (widget.maxImages > 1) const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ...List.generate(_imageFiles.length, (index) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _imageFiles[index],
                      width: widget.maxImages == 1 ? 120 : 100,
                      height: widget.maxImages == 1 ? 120 : 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(130, 0, 0, 0),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
            if (canAddMore)
              GestureDetector(
                onTap: _selectImage,
                child: Container(
                  width: widget.maxImages == 1 ? 120 : 100,
                  height: widget.maxImages == 1 ? 120 : 100,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 40,
                    color: theme.iconTheme.color,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
