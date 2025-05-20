import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:moodly_client/widgets/custom_button.dart';
import 'package:moodly_client/widgets/custom_image_selector.dart';
import 'package:moodly_client/widgets/custom_text_input.dart';
import 'package:moodly_client/widgets/date_time_picker.dart';
import 'package:moodly_client/widgets/journal_entry_textfield.dart';
import 'package:moodly_client/widgets/moods_card.dart';
import 'package:intl/intl.dart';
import 'package:http_parser/http_parser.dart';

class NewEntryScreen extends StatefulWidget {
  const NewEntryScreen({super.key});
  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

DateTime selectedDateTime = DateTime.now();

class _NewEntryScreenState extends State<NewEntryScreen> {
  int? selectedMoodIndex;
  bool showMoodSelector = true;
  List<File> imageFiles = [];
  final imagePicker = ImagePicker();

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

  final _nameController = TextEditingController();
  final _textController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final List<File> _images = [];

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _images.addAll(pickedFiles.map((xfile) => File(xfile.path)));
      });
    }
  }

  Future<void> _submitForm() async {
    final name = _nameController.text.trim();
    final text = _textController.text.trim();

    print("$name , $text, ${selectedDateTime.toIso8601String()}");

    if (name.isEmpty || text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name and text.')),
      );
      return;
    }

    try {
      // 1. Create the journal entry
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/v1/entries'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'entryText': text,
          'entryDateAndTime': selectedDateTime.toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final journalEntryId = data['_id'];

        // 2. Upload images (if any)
        if (_images.isNotEmpty) {
          final uploadUri = Uri.parse(
            'http://10.0.2.2:5000/api/v1/entries/$journalEntryId/images',
          );
          final request = http.MultipartRequest('POST', uploadUri);

          for (var image in _images) {
            final mimeType =
                lookupMimeType(image.path)?.split('/') ?? ['image', 'jpeg'];
            request.files.add(
              await http.MultipartFile.fromPath(
                'images',
                image.path,
                contentType: MediaType(mimeType[0], mimeType[1]),
              ),
            );
          }

          final uploadResponse = await request.send();

          if (uploadResponse.statusCode != 200 &&
              uploadResponse.statusCode != 201) {
            throw Exception(
              'Image upload failed with status ${uploadResponse.statusCode}',
            );
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Journal entry submitted!')),
        );

        _resetForm();
      } else {
        throw Exception('Failed to submit journal entry');
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _resetForm() {
    _nameController.clear();
    _textController.clear();
    _images.clear();
    selectedDateTime = DateTime.now();
    setState(() {});
  }

  // final imagePicker = ImagePicker();

  // Future<void> selectImage() async {
  //   final picked = await imagePicker.pickImage(
  //     source: ImageSource.gallery,
  //     maxWidth: 800,
  //     imageQuality: 80,
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       imageFiles.add(File(picked.path));
  //     });
  //   }
  // }

  Future<void> pickDateTime() async {
    final newDateTime = await DateTimePicker.pickDateTime(
      context: context,
      initialDateTime: selectedDateTime,
    );
    if (newDateTime != null) {
      setState(() {
        selectedDateTime = newDateTime;
      });
    }
  }

  String get formattedDateTime {
    return DateFormat('dd.MM.yyyy - HH:mm').format(selectedDateTime);
  }

  // void removeImage(int index) {
  //   setState(() {
  //     imageFiles.removeAt(index);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("New entry for:", style: TextStyle(fontSize: 20)),
                GestureDetector(
                  onTap: pickDateTime,
                  child: Row(
                    children: [
                      Text(
                        formattedDateTime,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit_calendar, size: 20),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              (selectedMoodIndex != null && !showMoodSelector)
                  ? "Today's mood:"
                  : "How is your mood today?",
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (selectedMoodIndex != null && !showMoodSelector)
              GestureDetector(
                onTap: () => setState(() => showMoodSelector = true),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SvgPicture.asset(
                      MoodsCard.moods[selectedMoodIndex!],
                      width: 48,
                      height: 48,
                      colorFilter: ColorFilter.mode(
                        theme.colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            if (selectedMoodIndex == null || showMoodSelector)
              Column(
                children: [
                  MoodsCard(
                    selectedMoodIndex: selectedMoodIndex,
                    onMoodSelected: (index) {
                      setState(() {
                        selectedMoodIndex = index;
                        showMoodSelector = false;
                      });
                    },
                  ),
                ],
              ),
            const SizedBox(height: 24),
            Text('Title', style: theme.textTheme.titleMedium),
            CustomTextInput(
              controller: _nameController,
              hintText: 'Add an optional title...',
            ),

            const SizedBox(height: 24),
            Text('Entry', style: theme.textTheme.titleMedium),
            JournalEntryTextField(
              controller: _textController,
              hintText: 'Write something...',
              maxLines: 5,
            ),
            const SizedBox(height: 24),
            Text(
              'Add images (${imageFiles.length}/5)',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            // Wrap(
            //   spacing: 12,
            //   runSpacing: 12,
            //   children: [
            //     ...List.generate(imageFiles.length, (index) {
            //       return Stack(
            //         children: [
            //           ClipRRect(
            //             borderRadius: BorderRadius.circular(8),
            //             child: Image.file(
            //               imageFiles[index],
            //               width: 100,
            //               height: 100,
            //               fit: BoxFit.cover,
            //             ),
            //           ),
            //           Positioned(
            //             top: 4,
            //             right: 4,
            //             child: GestureDetector(
            //               onTap: () => removeImage(index),
            //               child: Container(
            //                 decoration: const BoxDecoration(
            //                   shape: BoxShape.circle,
            //                   color: Color.fromARGB(130, 0, 0, 0),
            //                 ),
            //                 padding: const EdgeInsets.all(4),
            //                 child: const Icon(
            //                   Icons.close,
            //                   size: 16,
            //                   color: Colors.white,
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ],
            //       );
            //     }),
            //     if (imageFiles.length < 5)
            //       GestureDetector(
            //         onTap: () async {
            //           final picked =
            //               await CustomImageSelector.pickSingleImage();
            //           if (picked != null) {
            //             setState(() {
            //               imageFiles.add(picked);
            //             });
            //           }
            //         },
            //         child: Container(
            //           width: 100,
            //           height: 100,
            //           decoration: BoxDecoration(
            //             color: theme.colorScheme.surface,
            //             border: Border.all(color: theme.dividerColor),
            //             borderRadius: BorderRadius.circular(8),
            //           ),
            //           child: Icon(
            //             Icons.add,
            //             size: 40,
            //             color: theme.iconTheme.color,
            //           ),
            //         ),
            //       ),
            //   ],
            // ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                onPressed: _submitForm,
                // onPressed: () {
                //   // if (selectedMoodIndex == null) {
                //   //   ScaffoldMessenger.of(context).showSnackBar(
                //   //     const SnackBar(content: Text('Please select a mood')),
                //   //   );
                //   //   return;
                //   // }

                //   // TODO: Save logic
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     const SnackBar(content: Text('Entry saved (TODO)')),
                //   );
                // },
                label: 'Create entry',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _textController.dispose();
    super.dispose();
  }

  lookupMimeType(String path) {}
}
