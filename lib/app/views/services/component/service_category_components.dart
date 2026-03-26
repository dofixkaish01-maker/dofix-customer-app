import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/dashboard_controller.dart';
import '../../../../model/all_category_model.dart';
import '../../../../widgets/custom_image_viewer.dart';
import '../../home/SubScreens/category_to_services.dart';

class ServiceCategoryComponents extends StatelessWidget {
  const ServiceCategoryComponents({
    super.key,
    required this.allCategoryModel,
    this.isShowSeeAll = true,
    required this.width,
  });

  final AllCategoryModel? allCategoryModel;
  final bool isShowSeeAll;
  final double width;

  @override
  Widget build(BuildContext context) {
    final list = allCategoryModel?.content?.data;

    if (list == null || list.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isShowSeeAll)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                "Explore Services",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 12,
            children: List.generate(list.length, (i) {
              final cat = list[i];

              return SizedBox(
                width: width,
                height: 142,
                child: GestureDetector(
                  onTap: () {
                    final controller = Get.find<DashBoardController>();
                    controller.selectedCategoryName = cat.name ?? "";
                    controller.getCategoriesToSubCategories(
                      id: cat.id.toString(),
                      limit: '10',
                      offset: "1",
                    );
                    Get.to(() => const CategoryToServices());
                  },
                  child: Column(
                    children: [
                      CustomNetworkImageWidget(
                        width: width,
                        height: 100,
                        image: cat.imageFullPath ?? "",
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat.name ?? "",
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}