import 'package:do_fix/utils/theme.dart';
import 'package:flutter/material.dart';

import '../../../../utils/images.dart';

class CustomMapLocationWidget extends StatelessWidget {
  const CustomMapLocationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 0, 20),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                const SizedBox(
                  height: 30,
                ),
                Text(
                  'Our Service Locations',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Albert Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16),
                LocationTile(
                    title: 'Address location 1 here',
                    subtitle: 'Address location 1'),
                LocationTile(
                    title: 'Address location 2 here',
                    subtitle: 'Address location 2'),
                LocationTile(
                    title: 'Address location 3 here',
                    subtitle: 'Address location 3'),
                LocationTile(
                    title: 'Address location 4 here',
                    subtitle: 'Address location 4'),
              ],
            ),
          ),
          SizedBox(
            width: 150,
            child: Image.asset(
              Images
                  .indiaMap, // Ensure this path is correct and image is in your assets
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class LocationTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const LocationTile({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.location_on, color: darkRed),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                    fontSize: 14,
                    fontFamily: 'Albert Sans',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                    fontSize: 14,
                    fontFamily: 'Albert Sans',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
