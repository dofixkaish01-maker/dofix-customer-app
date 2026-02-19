import 'package:do_fix/controllers/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../../model/service_model.dart';
import '../../../../widgets/custom_image_viewer.dart';
import '../../../../utils/dimensions.dart';

class HorizontalAnimatedList extends StatefulWidget {
  final Services data;
  final String heading;
  final double imageHeight;

  const HorizontalAnimatedList({
    super.key,
    required this.data,
    required this.heading,
    required this.imageHeight,
  });

  @override
  State<HorizontalAnimatedList> createState() => _HorizontalAnimatedListState();
}

class _HorizontalAnimatedListState extends State<HorizontalAnimatedList> {
  List<ServiceModel> _items = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _items = widget.data.data ?? [];
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// HEADING
        if (widget.heading.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              widget.heading,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),

        const SizedBox(height: 12),

        /// AUTO SLIDER
        CarouselSlider.builder(
          itemCount: _items.length,
          itemBuilder: (context, index, realIndex) {
            final service = _items[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: HorizontalComponent(
                height: widget.imageHeight,
                category: service,
              ),
            );
          },
          options: CarouselOptions(
            height: widget.imageHeight + 60,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 700),
            enlargeCenterPage: true,
            viewportFraction: 0.55,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),

        /// DOT INDICATOR
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_items.length, (index) {
            final isActive = index == _currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              width: isActive ? 18 : 6,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF207FA7) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Horizontal Card Component
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          await Get.find<DashBoardController>().getServicesDetails(category.id.toString());
        },
        child: Ink(
          width: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [

                /// IMAGE
                Positioned.fill(
                  child: CustomNetworkImageWidget(
                    imagePadding: 0,
                    width: 160,
                    height: height,
                    image: category.thumbnailFullPath ?? "",
                    fit: BoxFit.cover,
                  ),
                ),

                /// GRADIENT OVERLAY
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.black.withOpacity(0.35),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                /// SERVICE NAME + CTA
                Positioned(
                  bottom: 12,
                  left: 8,
                  right: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        category.name ?? "",
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),

                      /// CTA badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Text(
                          "View Service",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
