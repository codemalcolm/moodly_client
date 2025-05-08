import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moodly_client/widgets/custom_button.dart';
import 'package:moodly_client/widgets/custom_image_picker.dart';

class NewEntryScreen extends StatefulWidget {
  const NewEntryScreen({super.key});

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  int? selectedMoodIndex;
  List<File> imageFiles = [];
  final imagePicker = ImagePicker();

  final List<String> moodIconPaths = [
    'assets/icons/icon_mood_angry.svg',
    'assets/icons/icon_mood_good.svg',
    'assets/icons/icon_mood_moody.svg',
    'assets/icons/icon_mood_loving.svg',
    'assets/icons/icon_mood_happy.svg',
    'assets/icons/icon_mood_sad.svg',
    'assets/icons/icon_mood_tired.svg',
    'assets/icons/icon_mood_anxious.svg',
  ];

  Future<void> selectImage() async {
    final picked = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        imageFiles.add(File(picked.path));
      });
    }
  }

  void removeImage(int index) {
    setState(() {
      imageFiles.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text('How do you feel?', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: List.generate(moodIconPaths.length, (index) {
              final isSelected = selectedMoodIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedMoodIndex = index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isSelected
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: SvgPicture.asset(
                    moodIconPaths[index],
                    width: 40,
                    height: 40,
                    colorFilter: ColorFilter.mode(
                      isSelected
                          ? theme.colorScheme.primary
                          : theme.iconTheme.color ?? Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 24),
          TextField(
            decoration: const InputDecoration(
              labelText: 'What is on your mind?',
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Add images (${imageFiles.length}/5)',
              style: theme.textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 12),
          CustomImagePicker(
            initialImages: imageFiles,
            onImagesChanged: (updatedImages) {
              setState(() {
                imageFiles = updatedImages;
              });
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              onPressed: () {
                if (selectedMoodIndex == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a mood')),
                  );
                  return;
                }

                // TODO: Save logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Entry saved (TODO)')),
                );
              },
              label: 'Create entry',
            ),
          ),
        ],
      ),
    );
  }
}
