import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:moodly_client/theme/app_theme.dart';
import 'package:moodly_client/widgets/entry_card.dart';
import 'package:moodly_client/widgets/mood_utils.dart';

class AllEntriesScreen extends StatefulWidget {
  const AllEntriesScreen({super.key});

  @override
  State<AllEntriesScreen> createState() => _AllEntriesScreenState();
}

enum SortOption { dateAsc, dateDesc, moodAsc, moodDesc }

class _AllEntriesScreenState extends State<AllEntriesScreen> {
  List<Map<String, dynamic>> dayEntries = [];
  SortOption selectedSort = SortOption.dateDesc;
  late ScrollController _scrollController;
  bool _showScrollToTopButton = false;

  int _currentPage = 1;
  final int _limit = 3;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  final Map<SortOption, String> sortApiMap = {
    SortOption.dateAsc: '+dayEntryDate',
    SortOption.dateDesc: '-dayEntryDate',
    SortOption.moodAsc: '+mood',
    SortOption.moodDesc: '-mood',
  };

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    loadData(isInitial: true);
  }

  void _scrollListener() {
    if (_scrollController.offset > 300 && !_showScrollToTopButton) {
      setState(() {
        _showScrollToTopButton = true;
      });
    } else if (_scrollController.offset <= 300 && _showScrollToTopButton) {
      setState(() {
        _showScrollToTopButton = false;
      });
    }

    // Infinite scroll
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      loadData(page: _currentPage);
    }
  }

  Future<void> loadData({int page = 1, bool isInitial = false}) async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final sortParam = sortApiMap[selectedSort];
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5000/api/v1/days/all?page=$page&limit=$_limit&sort=$sortParam',
        ),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<Map<String, dynamic>> parsedResults =
            List<Map<String, dynamic>>.from(decoded['results']);

        setState(() {
          if (isInitial) {
            dayEntries = parsedResults;
          } else {
            dayEntries.addAll(parsedResults);
          }

          _currentPage = decoded['next']?['page'] ?? _currentPage;
          _hasMoreData = decoded['next'] != null;
        });
      } else {
        debugPrint('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body:
          dayEntries.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: dayEntries.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: SvgPicture.asset(
                              'assets/icons/icon_sorting.svg',
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                theme.colorScheme.secondary,
                                BlendMode.srcIn,
                              ),
                            ),
                            onPressed: () => _showSortMenu(context),
                          ),
                        ],
                      ),
                    );
                  }
                  if (index == dayEntries.length + 1) {
                    // Bottom spinner
                    return _hasMoreData
                        ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                        : const SizedBox.shrink();
                  }
                  final day = dayEntries[index - 1];
                  final mood = day['mood'];
                  final journalEntries = List<Map<String, dynamic>>.from(
                    day['journalEntries'] ?? [],
                  )..sort(
                    (a, b) => DateTime.parse(
                      a['entryDateAndTime'],
                    ).compareTo(DateTime.parse(b['entryDateAndTime'])),
                  );
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat(
                                'dd.MM.yyyy',
                              ).format(DateTime.parse(day['dayEntryDate'])),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            if (mood != -1 && mood >= 0 && mood <= 7)
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: MoodUtils.moodColors[mood],
                                  shape: BoxShape.circle,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: SvgPicture.asset(
                                    'assets/icons/icon_mood_$mood.svg',
                                    colorFilter: ColorFilter.mode(
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              )
                            else
                              const SizedBox(width: 36, height: 36),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...journalEntries.map((entry) {
                          final entryDate = DateTime.parse(
                            entry['entryDateAndTime'],
                          );
                          final time = DateFormat('HH:mm').format(entryDate);

                          final imagesData =
                              (entry['images'] as List<dynamic>? ?? [])
                                  .where(
                                    (img) =>
                                        img != null && img['imageData'] != null,
                                  )
                                  .map<Uint8List>(
                                    (img) => base64Decode(img['imageData']),
                                  )
                                  .toList();

                          return EntryCard(
                            title: entry['name'] ?? '',
                            text: entry['entryText'] ?? '',
                            time: time,
                            imageBytes: imagesData,
                            backgroundColor: getAccentBackgroundColor(
                              Theme.of(context).primaryColor,
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
      floatingActionButton:
          _showScrollToTopButton
              ? FloatingActionButton(
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                  );
                },
                tooltip: 'Scroll to top',
                shape: const CircleBorder(),
                child: SvgPicture.asset(
                  'assets/icons/icon_arrow_upward.svg',
                  width: 32,
                  height: 32,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.onPrimary,
                    BlendMode.srcIn,
                  ),
                ),
              )
              : null,
    );
  }

  String _getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.dateAsc:
        return 'Date ↑';
      case SortOption.dateDesc:
        return 'Date ↓';
      case SortOption.moodAsc:
        return 'Mood ↑';
      case SortOption.moodDesc:
        return 'Mood ↓';
    }
  }

  void _showSortMenu(BuildContext context) async {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final SortOption? selected = await showMenu<SortOption>(
      context: context,
      position: RelativeRect.fromLTRB(
        overlay.size.width - 56,
        kToolbarHeight + 8,
        16,
        0,
      ),
      color: Theme.of(context).canvasColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items:
          SortOption.values.map((option) {
            final isSelected = option == selectedSort;

            return PopupMenuItem<SortOption>(
              value: option,
              child: Container(
                decoration:
                    isSelected
                        ? BoxDecoration(
                          color: getAccentBackgroundColor(
                            Theme.of(context).primaryColor,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        )
                        : null,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text(
                  _getSortLabel(option),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
    );

    if (selected != null && selected != selectedSort) {
      setState(() {
        selectedSort = selected;
        _currentPage = 1; 
        _hasMoreData = true;
        dayEntries.clear();
      });
      loadData();
    }
  }
}
