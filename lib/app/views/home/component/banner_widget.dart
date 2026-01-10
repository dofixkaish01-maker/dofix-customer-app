import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class BannerComponent extends StatefulWidget {
  final List<BannerItem> bannerList;
  BannerComponent({
    super.key,
    required this.bannerList,
  });

  @override
  _BannerComponentState createState() => _BannerComponentState();
}

class _BannerComponentState extends State<BannerComponent> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return widget.bannerList.length == 1
        ? InkWell(
            onTap: widget.bannerList.first.onTap,
            child: Container(
              height: 150,
              margin: EdgeInsets.all(
                8.0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  10,
                ),
                image: DecorationImage(
                  image: NetworkImage(
                    widget.bannerList.first.imageUrl.toString(),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
        : Column(
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  scrollPhysics: widget.bannerList.length.toInt() > 1
                      ? null
                      : NeverScrollableScrollPhysics(),
                  height: 160,
                  autoPlay: true,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.9,
                  autoPlayInterval: Duration(seconds: 3),
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                items: widget.bannerList.map((imagePath) {
                  return InkWell(
                    onTap: imagePath.onTap,
                    child: Container(
                      margin: EdgeInsets.all(
                        8.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(
                            imagePath.imageUrl.toString(),
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Custom Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.bannerList.asMap().entries.map((
                  entry,
                ) {
                  int index = entry.key;
                  return Container(
                    width: _currentIndex == index
                        ? 20
                        : 8, // Active indicator is wider
                    height: 8,
                    margin: EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color:
                          _currentIndex == index ? Colors.black : Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }).toList(),
              ),
            ],
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
