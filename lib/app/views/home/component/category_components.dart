import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../../controllers/dashboard_controller.dart';
import '../../../../model/category_model.dart';
import '../../../../utils/dimensions.dart';
import '../../../../utils/styles.dart';
import '../../../../widgets/custom_image_viewer.dart';
import '../../dashboard/dashboard_screen.dart';

class CategoryComponents extends StatelessWidget {
  const CategoryComponents({
    super.key,
    required this.categoryList,
    this.isShowSeeAll = true,
    required this.width,
  });

  final CategoryModel categoryList;
  final bool isShowSeeAll;
  final double width;

  @override
  Widget build(BuildContext context) {
    final list = categoryList.data;

    if (list == null || list.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isShowSeeAll)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Explore Service",
                  style: albertSansRegular.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Get.offAll(
                      DashboardScreen(
                        key: GlobalKey<DashboardScreenState>(),
                        pageIndex: 1,
                      ),
                    );
                  },
                  child: Text(
                    "See All",
                    style: albertSansRegular.copyWith(
                      fontSize: Dimensions.fontSize13,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 8),

          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: List.generate(list.length, (i) {
              final cat = list[i];

              return SizedBox(
                width: width,
                height: 115,
                child: GestureDetector(
                  onTap: () {
                    Get.find<DashBoardController>()
                        .getCategoriesToSubCategories(
                      id: cat.id.toString(),
                      limit: '10',
                      offset: "1",
                    );
                  },
                  child: Column(
                    children: [
                      CustomNetworkImageWidget(
                        fit: BoxFit.cover,
                        width: width,
                        height: 80,
                        image: cat.imageFullPath ?? "",
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat.name ?? "",
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: albertSansRegular.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w300,
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
