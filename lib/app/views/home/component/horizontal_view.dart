import 'package:do_fix/app/views/services/service_details_screen.dart';
import 'package:do_fix/controllers/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../model/service_model.dart';
import '../../../../utils/dimensions.dart';
import '../../../../widgets/custom_image_viewer.dart';

class HorizontalAnimatedList extends StatefulWidget {
  final Services data;
  final String heading;
  final double imageHeight;
  const HorizontalAnimatedList(
      {super.key,
      required this.data,
      required this.heading,
      required this.imageHeight});

  @override
  State<HorizontalAnimatedList> createState() => _HorizontalAnimatedListState();
}

class _HorizontalAnimatedListState extends State<HorizontalAnimatedList> {
  List<ServiceModel> _items = [];

  @override
  void initState() {
    super.initState();
    _items = widget.data.data ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  widget.heading,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Albert Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          SizedBox(
            height: 195,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6.0,
                  ),
                  child: SizedBox(
                    width: 140,
                    child: HorizontalComponent(
                      height: widget.imageHeight,
                      category: _items[index],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HorizontalComponent extends StatelessWidget {
  final ServiceModel category;
  final double height;
  const HorizontalComponent({
    super.key,
    required this.category,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.find<DashBoardController>().serviceModel = category;
        Get.find<DashBoardController>().update();
        Future.delayed(Duration(milliseconds: 1));
        Get.to(() => ServiceDetails());
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radius5),
            topRight: Radius.circular(Dimensions.radius5),
          ),
        ),
        child: Stack(
          children: [
            // Image
            CustomNetworkImageWidget(
              onlyTopRadius: true,
              imagePadding: 0,
              width: 140,
              height: height,
              image: category.thumbnailFullPath ?? "",
            ),
            // Gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              top: 0,
              child: Container(
                width: 140,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(Dimensions.radius5),
                    topRight: Radius.circular(Dimensions.radius5),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Text content at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          category.name ?? "",
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Albert Sans',
                            fontWeight: FontWeight.w400,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 12,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
