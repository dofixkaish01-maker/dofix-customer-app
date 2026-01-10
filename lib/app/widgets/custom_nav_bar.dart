// import 'package:flutter/material.dart';

// import '../../utils/images.dart';

// class CustomBottomNavBar extends StatefulWidget {
//   final int currentIndex;
//   final Function(int) onTap;

//   const CustomBottomNavBar({super.key, required this.currentIndex, required this.onTap});

//   @override
//   _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
// }

// class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(color: Colors.black12, blurRadius: 5),
//         ],
//       ),
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           Positioned(
//             top: -10,
//             left: MediaQuery.of(context).size.width / 4 * widget.currentIndex + (widget.currentIndex == 0?17:widget.currentIndex == 1?10:widget.currentIndex == 2?15:20),
//             child: CustomIndicator(),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 12),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildNavItem(Images.icHome, "HOME", 0),
//                 _buildNavItem(Images.icServices, "SERVICES", 1),
//                 _buildNavItem(Images.icBooking, "BOOKINGS", 2),
//                 _buildNavItem(Images.icProfile, "ACCOUNT", 3),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNavItem(String icon, String label, int index) {
//     bool isSelected = widget.currentIndex == index;

//     return GestureDetector(
//       onTap: () => widget.onTap(index),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ImageIcon(AssetImage(icon), size: 28, color: isSelected ? Color(0xfff207FA8) : Colors.grey),
//           const SizedBox(height: 4),
//           Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Color(0xfff207FA8) : Colors.grey)),
//         ],
//       ),
//     );
//   }
// }

// class CustomIndicator extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 50,
//       height: 25,
//       decoration: BoxDecoration(
//        image: DecorationImage(
//          image: AssetImage(Images.icIndicator),
//          fit: BoxFit.fill,
//        ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../../utils/images.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar(
      {super.key, required this.currentIndex, required this.onTap});

  @override
  _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE6E6E6), width: 1),
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          )),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Images.icHome, 0),
            _buildNavItem(Images.icServices, 1),
            _buildNavItem(Images.icBooking, 2),
            _buildNavItem(Images.icProfile, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(String icon, int index) {
    bool isSelected = widget.currentIndex == index;

    return GestureDetector(
      onTap: () => widget.onTap(index),
      child: isSelected
          ? Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xFFF2F5F7)),
              padding: EdgeInsets.all(14),
              child: ImageIcon(AssetImage(icon),
                  size: 24, color: Color(0xfff207FA8)))
          : Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(14),
              child: ImageIcon(AssetImage(icon), size: 24, color: Colors.grey)),
    );
  }
}

class CustomIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 25,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Images.icIndicator),
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}
