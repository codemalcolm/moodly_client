import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:moodly_client/models/day_entry_model.dart';
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

class DayEntryUnpopulated {
  final String id;
  final String dayEntryDate;
  final int? mood;
  final List<dynamic> journalEntries;
  final List<dynamic> dailyTasks;

  DayEntryUnpopulated({
    required this.id,
    required this.dayEntryDate,
    this.mood,
    required this.journalEntries,
    required this.dailyTasks,
  });

  factory DayEntryUnpopulated.fromJson(Map<String, dynamic> json) {
    return DayEntryUnpopulated(
      id: json['_id'] as String,
      dayEntryDate: json['dayEntryDate'] as String,
      mood: json['mood'] as int?,
      journalEntries: json['journalEntries'],
      dailyTasks: json['dailyTasks'],
    );
  }
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  int? selectedMoodIndex;
  bool showMoodSelector = true;
  DayEntryUnpopulated? _dayEntry;
  bool _isLoadingDayEntry = false;

  List<File> _images = [];
  final imagePicker = ImagePicker();

  Future<void> selectImage() async {
    final picked = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _images.add(File(picked.path));
      });
    }
  }

  final _nameController = TextEditingController();
  final _textController = TextEditingController();

  Future<void> _pickImages() async {
    final pickedFiles = await CustomImageSelector.pickMultipleImages();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _images.addAll(pickedFiles);
      });
    }
  }

  Future<void> fetchDayEntryMood(DateTime date) async {
    setState(() {
      _isLoadingDayEntry = true;
      _dayEntry = null;
    });

    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final uri = Uri.parse(
      'http://10.0.2.2:5000/api/v1/days/mood?date=$formattedDate',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        print("❗");
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['dayEntry'] != null) {
          setState(() {
            _dayEntry = DayEntryUnpopulated.fromJson(jsonResponse['dayEntry']);
            print(_dayEntry);

            if (_dayEntry!.mood != -1) {
              setState(() {
                selectedMoodIndex = _dayEntry!.mood;
                showMoodSelector = false;
              });
            } else {
              setState(() {
                selectedMoodIndex = null;
                showMoodSelector = true;
              });
            }
          });
        }
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoadingDayEntry = false;
      });
    }
  }

  // Future<void> updateMood(int moodIndex) async {
  //   final uri = Uri.parse(
  //     'http://10.0.2.2:5000/api/v1/days/${_dayEntry!.id}/mood',
  //   );
  //   final Map<String, dynamic> requestBody = {"mood": moodIndex.toString()};

  //   try {
  //     final response = await http.patch(
  //       uri,
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode(requestBody),
  //     );

  //     if (response.statusCode != 200) {
  //       print("Failed to update mood:");
  //     }
  //   } catch (e) {
  //     setState(() {
  //       print("Error updating mood: $e");
  //     });
  //   }
  // }

  Future<void> _submitForm() async {
    final name = _nameController.text.trim();
    final text = _textController.text.trim();
    final int? index = selectedMoodIndex;

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
        await updateMood(index);
        final data = jsonDecode(response.body);
        final journalEntryId = data?['journalEntry']['_id'];

        // 2. Upload images (if any)
        if (_images.isNotEmpty) {
          print("❗ works");
          try {
            final uploadUri = Uri.parse(
              'http://10.0.2.2:5000/api/v1/entries/$journalEntryId/images',
            );
            final request = http.MultipartRequest('POST', uploadUri);

            for (var image in _images) {
              final mimeType =
                  lookupMimeType(image.path)?.split('/') ?? ['image', 'jpeg'];
              request.files.add(
                await http.MultipartFile.fromPath(
                  'file',
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
          } catch (e) {
            print("❗ Error uploading images : $e");
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
        fetchDayEntryMood(selectedDateTime);
      });
    }
    ;
  }

  String get formattedDateTime {
    return DateFormat('dd.MM.yyyy - HH:mm').format(selectedDateTime);
  }

  void removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> updateMood(int? moodIndex) async {
    final uri = Uri.parse('http://10.0.2.2:5000/api/v1/days/${_dayEntry!.id}');
    final Map<String, dynamic> requestBody = {"mood": moodIndex.toString()};

    try {
      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestBody),
      );

      if (response.statusCode != 200) {
        print("Failed to update mood:");
      }
    } catch (e) {
      setState(() {
        print("Error updating mood: $e");
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDayEntryMood(selectedDateTime);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),

        child:
            _isLoadingDayEntry
                ? Center(child: CircularProgressIndicator())
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "New entry for:",
                          style: TextStyle(fontSize: 20),
                        ),
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
                    const SizedBox(height: 12),
                    Text(
                      (selectedMoodIndex != null && !showMoodSelector)
                          ? "Selected mood:"
                          : "Track your mood",
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
                            onMoodSelected: (index) async {
                              setState(() {
                                selectedMoodIndex = index;
                                showMoodSelector = false;
                              });
                            },
                          ),
                        ],
                      ),
                    const SizedBox(height: 18),
                    Text('Title', style: theme.textTheme.titleMedium),
                    CustomTextInput(
                      controller: _nameController,
                      hintText: 'Add an optional title...',
                    ),

                    const SizedBox(height: 18),
                    Text('Entry', style: theme.textTheme.titleMedium),
                    JournalEntryTextField(
                      controller: _textController,
                      hintText: 'Write something...',
                      maxLines: 5,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Add images (${_images.length}/5)',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ...List.generate(_images.length, (index) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _images[index],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap:
                                      () => setState(
                                        () => _images.removeAt(index),
                                      ),
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
                        if (_images.length < 5)
                          GestureDetector(
                            onTap: () async {
                              final picked =
                                  await CustomImageSelector.pickSingleImage();
                              if (picked != null) {
                                setState(() {
                                  _images.add(picked);
                                });
                              }
                            },
                            child: Container(
                              width: 100,
                              height: 100,
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
                    const SizedBox(height: 16),
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
