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
    "AC Repair",
    "Plumber",
    "Electrician",
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

        isSearching.value = false;
        isSearchCompleted.value = true;


        addRecentSearch(query);
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
