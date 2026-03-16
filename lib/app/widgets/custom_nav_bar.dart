import 'package:flutter/material.dart';
import '../../utils/images.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom; // safe area
    const activeColor = Color(0xff227FA8);
    const inactiveColor = Colors.grey;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding:
            EdgeInsets.fromLTRB(12, 10, 12, 10 + (bottom > 0 ? bottom : 6)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
          border: Border(
            top: BorderSide(color: const Color(0xFFEAEAEA), width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavItem(
              icon: Images.icHome,
              label: "Home",
              index: 0,
              isSelected: currentIndex == 0,
              onTap: onTap,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
            _NavItem(
              icon: Images.icServices,
              label: "Service",
              index: 1,
              isSelected: currentIndex == 1,
              onTap: onTap,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),

            _NavItem(
              icon: Images.icInstant,
              label: "Instant",
              index: 2,
              isSelected: currentIndex == 2,
              onTap: onTap,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),

            _NavItem(
              icon: Images.icBooking,
              label: "Booking",
              index: 3,
              isSelected: currentIndex == 3,
              onTap: onTap,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
            _NavItem(
              icon: Images.icProfile,
              label: "Account",
              index: 4,
              isSelected: currentIndex == 4,
              onTap: onTap,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String icon;
  final String label;
  final int index;
  final bool isSelected;
  final Function(int) onTap;
  final Color activeColor;
  final Color inactiveColor;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(index),
          borderRadius: BorderRadius.circular(14),
          splashColor: activeColor.withOpacity(.08),
          highlightColor: activeColor.withOpacity(.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? activeColor.withOpacity(.10) : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [

                      // ICON
                      AnimatedScale(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        scale: isSelected ? 1.08 : 1.0,
                        child: ImageIcon(
                          AssetImage(icon),
                          size: 22,
                          color: isSelected ? activeColor : inactiveColor,
                        ),
                      ),

                      // NEW Badge for Instant Tab
                      if (index == 2)
                        Positioned(
                          top: -12, // moved higher than before
                          right: -4,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 1.0, end: 1.2),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeInOut,
                            builder: (context, scale, child) {
                              return Transform.scale(
                                scale: scale,
                                child: child,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white, width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 3,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: const Text(
                                "NEW",
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  // LABEL
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? activeColor : inactiveColor,
                      height: 1.1,
                    ),
                    child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// // import 'package:flutter/material.dart';
//
// // import '../../utils/images.dart';
//
// // class CustomBottomNavBar extends StatefulWidget {
// //   final int currentIndex;
// //   final Function(int) onTap;
//
// //   const CustomBottomNavBar({super.key, required this.currentIndex, required this.onTap});
//
// //   @override
// //   _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
// // }
//
// // class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         boxShadow: [
// //           BoxShadow(color: Colors.black12, blurRadius: 5),
// //         ],
// //       ),
// //       child: Stack(
// //         clipBehavior: Clip.none,
// //         children: [
// //           Positioned(
// //             top: -10,
// //             left: MediaQuery.of(context).size.width / 4 * widget.currentIndex + (widget.currentIndex == 0?17:widget.currentIndex == 1?10:widget.currentIndex == 2?15:20),
// //             child: CustomIndicator(),
// //           ),
// //           Padding(
// //             padding: const EdgeInsets.symmetric(vertical: 12),
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceAround,
// //               children: [
// //                 _buildNavItem(Images.icHome, "HOME", 0),
// //                 _buildNavItem(Images.icServices, "SERVICES", 1),
// //                 _buildNavItem(Images.icBooking, "BOOKINGS", 2),
// //                 _buildNavItem(Images.icProfile, "ACCOUNT", 3),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
//
// //   Widget _buildNavItem(String icon, String label, int index) {
// //     bool isSelected = widget.currentIndex == index;
//
// //     return GestureDetector(
// //       onTap: () => widget.onTap(index),
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           ImageIcon(AssetImage(icon), size: 28, color: isSelected ? Color(0xfff207FA8) : Colors.grey),
// //           const SizedBox(height: 4),
// //           Text(label, style: TextStyle(fontSize: 12, color: isSelected ? Color(0xfff207FA8) : Colors.grey)),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// // class CustomIndicator extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       width: 50,
// //       height: 25,
// //       decoration: BoxDecoration(
// //        image: DecorationImage(
// //          image: AssetImage(Images.icIndicator),
// //          fit: BoxFit.fill,
// //        ),
// //       ),
// //     );
// //   }
// // }
//
// import 'package:flutter/material.dart';
//
// import '../../utils/images.dart';
//
// class CustomBottomNavBar extends StatefulWidget {
//   final int currentIndex;
//   final Function(int) onTap;
//
//   const CustomBottomNavBar(
//       {super.key, required this.currentIndex, required this.onTap});
//
//   @override
//   _CustomBottomNavBarState createState() => _CustomBottomNavBarState();
// }
//
// class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//           color: Colors.white,
//           border: Border(
//             top: BorderSide(color: Color(0xFFE6E6E6), width: 1),
//           ),
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(16),
//             topRight: Radius.circular(16),
//           )),
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _buildNavItem(Images.icHome, 0,"Home"),
//             _buildNavItem(Images.icServices, 1,"Service"),
//             _buildNavItem(Images.icBooking, 2,"Booking"),
//             _buildNavItem(Images.icProfile, 3,"Account"),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNavItem(String icon, int index, String label) {
//     bool isSelected = widget.currentIndex == index;
//
//     return GestureDetector(
//       onTap: () => widget.onTap(index),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             height: 50,
//             width: 50,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: isSelected ? const Color(0xFFF2F5F7) : Colors.transparent,
//             ),
//             padding: const EdgeInsets.all(14),
//             child: ImageIcon(
//               AssetImage(icon),
//               size: 24,
//               color: isSelected
//                   ? const Color(0xff227FA8)
//                   : Colors.grey,
//             ),
//           ),
//
//           const SizedBox(height: 4),
//
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 11,
//               fontWeight: FontWeight.w500,
//               color: isSelected
//                   ? const Color(0xff227FA8)
//                   : Colors.grey,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class CustomIndicator extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 50,
//       height: 25,
//       decoration: BoxDecoration(
//         image: DecorationImage(
//           image: AssetImage(Images.icIndicator),
//           fit: BoxFit.fill,
//         ),
//       ),
//     );
//   }
// }
