import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/api/api.dart';
import '../model/service_model.dart';
import 'dashboard_controller.dart';

class SearchController extends GetxController {
  final ApiClient apiClient;
  SearchController({required this.apiClient});

  /// SEARCH TEXT
  RxString searchText = "".obs;

  /// LOADING
  RxBool isLoading = false.obs;

  /// STATIC TRENDING SEARCH (NO API)
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

  /// SEARCH RESULT (API)
  RxList<ServiceModel> searchResults = <ServiceModel>[].obs;

  /// RECENT SEARCH
  RxList<String> recentSearches = <String>[].obs;

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    loadRecentSearches(); // ✅ only this
  }
  void clearSearch() {
    searchText.value = '';
    Get.find<DashBoardController>()
        .serviceModelSearchList
        .clear();
  }



  // ================= SEARCH =================
  void onSearchChanged(String value) {
    final query = value.trim();
    searchText.value = query;

    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
    }

    _debounce = Timer(const Duration(milliseconds: 600), () {
      final dashboard = Get.find<DashBoardController>();

      if (query.isNotEmpty) {
        print("SEARCH QUERY => $query");
        dashboard.getSearchList(query); // ✅ ONLY STRING
        addRecentSearch(query);
      } else {
        dashboard.serviceModelSearchList.clear();
      }
    });
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
