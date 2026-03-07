import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import '../../../../../controllers/search_controller.dart';
import '../../../../../controllers/dashboard_controller.dart';
import '../../../../widgets/networkimg_summerize/network_Image_with_shimmer.dart';

class SearchScreen extends StatelessWidget {
  SearchScreen({super.key});

  final SearchController controller =
      Get.put(SearchController(apiClient: Get.find()));

  final DashBoardController dashboard = Get.find<DashBoardController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF207FA8),
        elevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SizedBox(
            height: 42,
            child: Obx(() => TextField(
                  autofocus: true,
                  controller: controller.textController,
                  onChanged: controller.onSearchChanged,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: "Search services",
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: controller.searchText.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: controller.clearSearch,
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                )),
          ),
        ),
      ),
      body: Column(
        children: [
          /// CONTENT
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await dashboard.getFeaturedCategories(
                    limit: "10",
                    offset: "1",
                    forDashboard: false); // categories refresh
                controller.clearSearch(); // search reset
              },
              child: Obx(() {
                /// EMPTY SEARCH
                if (controller.searchText.value.isEmpty) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _title("Trending Searches"),
                        _trendingList(),
                        if (controller.recentSearches.isNotEmpty) ...[
                          _title("Recent Searches"),
                          _recentSearch(),
                        ],
                        _title("Browse Categories"),
                        GetBuilder<DashBoardController>(
                          builder: (dashboard) => _categoryGrid(dashboard),
                        ),
                      ],
                    ),
                  );
                }

                /// SEARCH RESULT AREA
                return GetBuilder<DashBoardController>(
                  builder: (dashboard) {
                    if (dashboard.isLoginLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (controller.isSearchCompleted.value &&
                        dashboard.serviceModelSearchList.isEmpty) {
                      return const Center(child: Text("No service found"));
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: dashboard.serviceModelSearchList.length,
                      itemBuilder: (_, index) {
                        final item = dashboard.serviceModelSearchList[index];

                        return GestureDetector(
                          onTap: () async {
                            await dashboard.getServicesDetails(item.id ?? "");
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),

                            child: Padding(
                              padding: const EdgeInsets.all(12),

                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  /// IMAGE
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: SizedBox(
                                      width: 85,
                                      height: 85,
                                      child: NetworkImageWithShimmer(
                                        imageUrl: item.coverImageFullPath ?? "",
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  /// CONTENT
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [

                                        /// SERVICE NAME
                                        Text(
                                          item.name ?? "",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),

                                        const SizedBox(height: 6),

                                        /// DESCRIPTION
                                        Text(
                                          item.shortDescription ?? "",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),

                                        const SizedBox(height: 10),

                                        /// BOTTOM ROW
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [

                                            /// OPTIONAL TAG
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF207FA8)
                                                    .withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                "Service",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF207FA8),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),

                                            /// VIEW BUTTON
                                            GestureDetector(
                                              onTap: () async {
                                                await dashboard.getServicesDetails(item.id ?? "");
                                              },
                                              child: Container(
                                                width: 90, // <-- width badhaya
                                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF207FA8),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Text(
                                                  "View",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ================= WIDGETS =================

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );

  /// TRENDING KEYWORDS (Flipkart style)
  Widget _trendingList() => SizedBox(
        height: 48,
        child: Obx(() => ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: controller.trendingSearches.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                final text = controller.trendingSearches[index];

                return ActionChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(text),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                      ),
                    ],
                  ),
                  onPressed: () => controller.setSearchFromChip(text),
                );
              },
            )),
      );

  Widget _recentSearch() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(() => Wrap(
              spacing: 8,
              children: controller.recentSearches
                  .map((e) => ActionChip(
                        avatar: const Icon(
                          Icons.history,
                          size: 18,
                        ),
                        label: Text(e),
                        onPressed: () => controller.setSearchFromChip(e),
                      ))
                  .toList(),
            )),
      );

  Widget _categoryGrid(DashBoardController dashboard) {
    final list = dashboard.categoryList?.data;

    if (list == null || list.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.92,
        ),
        itemBuilder: (_, index) {
          final cat = list[index];

          return InkWell(
            onTap: () => controller.onSearchChanged(cat.name ?? ""),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// IMAGE
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: NetworkImageWithShimmer(
                      imageUrl: cat.imageFullPath ?? "",
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                /// TEXT
                Text(
                  cat.name ?? "",
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
