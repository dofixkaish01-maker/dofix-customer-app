import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/api/api.dart';
import 'dashboard_controller.dart';

class SearchController extends GetxController {
  final ApiClient apiClient;
  SearchController({required this.apiClient});

  /// SEARCH TEXT
  RxString searchText = "".obs;

  /// STATES
  RxBool isSearching = false.obs;
  RxBool isSearchCompleted = false.obs;

  /// STATIC TRENDING SEARCH
  RxList<String> trendingSearches = <String>[
    "AC Service, Repair & Installation",
    "Plumber Services",
    "Electrician Service",
    "Carpenter",
    "Home Cleaning",
    "Bathroom Cleaning",
    "Washing Machine Repair",
    "Refrigerator Repair",
  ].obs;

  /// RECENT SEARCH
  RxList<String> recentSearches = <String>[].obs;

  Timer? _debounce;
  final textController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadRecentSearches();
  }

  void clearSearch() {
    textController.clear(); // <-- TextField ka text clear karega
    searchText.value = '';
    isSearching.value = false;
    isSearchCompleted.value = false;
    Get.find<DashBoardController>().serviceModelSearchList.clear();
  }

  // ================= SEARCH =================
  void onSearchChanged(String value) {
    final query = value.trim();
    searchText.value = query;

    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 600), () async {
      final dashboard = Get.find<DashBoardController>();

      if (query.isNotEmpty) {
        isSearching.value = true;
        isSearchCompleted.value = false;

        await dashboard.getSearchList(query);

        /// SORTING
        final list = dashboard.serviceModelSearchList;
        final lowerQuery = query.toLowerCase();

        list.sort((a, b) {
          int scoreA = _getScore(a.name ?? "", lowerQuery);
          int scoreB = _getScore(b.name ?? "", lowerQuery);

          return scoreB.compareTo(scoreA);
        });

        isSearching.value = false;
        isSearchCompleted.value = true;

        if (query.length > 2) {
          addRecentSearch(query);
        }
      } else {
        dashboard.serviceModelSearchList.clear();
        isSearchCompleted.value = false;
      }
    });
  }
  void setSearchFromChip(String value) {
    textController.text = value;
    textController.selection = TextSelection.fromPosition(
      TextPosition(offset: value.length),
    );
    onSearchChanged(value);
  }

  // ================= RECENT SEARCH =================
  Future<void> loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    recentSearches.value = prefs.getStringList("recent_search") ?? [];
  }

  Future<void> addRecentSearch(String value) async {
    if (value.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    recentSearches.remove(value);
    recentSearches.insert(0, value);

    if (recentSearches.length > 8) {
      recentSearches.removeLast();
    }

    await prefs.setStringList("recent_search", recentSearches);
  }

  Future<void> removeRecentSearch(String value) async {
    final prefs = await SharedPreferences.getInstance();

    recentSearches.remove(value);

    await prefs.setStringList("recent_search", recentSearches);
  }

  Future<void> clearRecentSearch() async {
    final prefs = await SharedPreferences.getInstance();
    recentSearches.clear();
    await prefs.remove("recent_search");
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
int _getScore(String name, String query) {
  final lowerName = name.toLowerCase();

  if (lowerName == query) {
    return 3; // exact match
  } else if (lowerName.startsWith(query)) {
    return 2; // best match
  } else if (lowerName.contains(query)) {
    return 1; // related
  } else {
    return 0;
  }
}