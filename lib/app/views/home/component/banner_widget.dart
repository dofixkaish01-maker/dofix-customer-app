import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class BannerComponent extends StatefulWidget {
  final List<BannerItem> bannerList;

  const BannerComponent({
    super.key,
    required this.bannerList,
  });

  @override
  State<BannerComponent> createState() => _BannerComponentState();
}

class _BannerComponentState extends State<BannerComponent> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.bannerList.isEmpty) return const SizedBox();

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 160,
              viewportFraction: 1,
              autoPlay: widget.bannerList.length > 1,
              autoPlayInterval: const Duration(seconds: 3),
              enableInfiniteScroll: widget.bannerList.length > 1,
              onPageChanged: (index, reason) {
                setState(() => _currentIndex = index);
              },
            ),
            items: widget.bannerList.map((item) {
              return InkWell(
                onTap: item.onTap,
                child: SizedBox(
                  width: double.infinity,
                  child: Image.network(
                    item.imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 6),

          // Indicator
          if (widget.bannerList.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.bannerList.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentIndex == index ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? Colors.black
                        : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}
class BannerItem {
  final String imageUrl;
  final VoidCallback onTap;
  final String redirectId;
  final String bannertype;

  BannerItem({
    required this.imageUrl,
    required this.onTap,
    required this.redirectId,
    required this.bannertype,
  });
}