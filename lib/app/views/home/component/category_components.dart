import 'package:do_fix/app/views/dashboard/dashboard_screen.dart';
import 'package:do_fix/controllers/dashboard_controller.dart';
import 'package:do_fix/model/category_model.dart';
import 'package:do_fix/utils/dimensions.dart';
import 'package:do_fix/utils/sizeboxes.dart';
import 'package:do_fix/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/custom_image_viewer.dart';

class CategoryComponents extends StatelessWidget {
  CategoryModel? categoryList = CategoryModel(data: []);
  bool? isShowSeeAll;
  double? width;
  CategoryComponents(
      {super.key, this.categoryList, this.isShowSeeAll = true, this.width});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
              visible: isShowSeeAll!,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Explore Service",
                    style: albertSansRegular.copyWith(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.offAll(DashboardScreen(
                          key: GlobalKey<DashboardScreenState>(),
                          pageIndex: 1));
                    },
                    child: Text(
                      "See All",
                      style: albertSansRegular.copyWith(
                        fontSize: Dimensions.fontSize13,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: (categoryList?.data ?? []).isNotEmpty,
              child: SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: 10.0, // Horizontal spacing
                  runSpacing: 8.0, // Vertical spacing
                  children:
                      List.generate((categoryList?.data ?? []).length, (i) {
                    return SizedBox(
                      width: width,
                      height: 115,
                      child: GestureDetector(
                        onTap: () {
                          debugPrint(
                              "Category ID: ${(categoryList?.data ?? [])[i].id}");
                          print(
                              'Selected ID: ${(categoryList?.data ?? [])[i].id}');
                          Get.find<DashBoardController>()
                              .getCategoriesToSubCategories(
                                  id: (categoryList?.data ?? [])[i]
                                      .id
                                      .toString(),
                                  limit: '10',
                                  offset: "1");
                          //eb69594b-df12-4519-adc5-01ef73e5eae2
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            sizedBox10(),
                            CustomNetworkImageWidget(
                              fit: BoxFit.cover,
                              imagePadding: 0,
                              width: width,
                              height: 70,
                              image: categoryList?.data?[i].imageFullPath ?? "",
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                              ),
                              child: Text(
                                textAlign: TextAlign.center,
                                categoryList?.data?[i].name ?? "",
                                maxLines: 2,
                                style: albertSansRegular.copyWith(
                                  fontSize: 11,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w300,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            // Visibility(
            //     visible: (categoryList?.data ?? []).isEmpty,
            //     child: Center(
            //       child: CircularProgressIndicator(),
            //     )),
          ],
        ),
      ),
    );
  }
}
