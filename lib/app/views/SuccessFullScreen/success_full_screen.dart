import 'package:do_fix/app/views/dashboard/dashboard_screen.dart';
import 'package:do_fix/app/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/dashboard_controller.dart';
import '../../../utils/images.dart';

class SuccessFullScreen extends StatelessWidget {
  const SuccessFullScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashBoardController>(builder: (controller) {
      return SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomAppBar(
            title: "Booking Confirmed",
            isBackButtonExist: true,
            isCartButtonExist: false,
            isSearchButtonExist: false,
            onBackPressed: () {
              Get.offAll(() => DashboardScreen(pageIndex: 0));
            },
          ),
          body: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                Images.icsuccessfull,
                scale: 3,
              ),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.offAll(() => DashboardScreen(pageIndex: 0));
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Back To Home",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      );

      Material(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: <Widget>[
                // SliverAppBar(
                //   automaticallyImplyLeading: false,
                //   pinned: true,
                //   backgroundColor: Colors.white,
                //   expandedHeight: 135.0,
                //   flexibleSpace: FlexibleSpaceBar(
                //     background: Padding(
                //       padding: const EdgeInsets.symmetric(
                //           horizontal: Dimensions.paddingSizeDefault),
                //       child: Column(
                //         children: [
                //           sizedBox65(),
                //           Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //             children: [
                //               Image.asset(Images.iclogo, height: 70, width: 70),
                //               CustomNotificationButton(
                //                 icon: Icons.shopping_cart,
                //                 tap: () {},
                //                 color: Theme.of(context).primaryColor,
                //               )
                //             ],
                //           ),
                //           InkWell(
                //             splashColor: Colors.grey.withOpacity(0.5),
                //             onTap: () => Get.offAll(() => DashboardScreen(pageIndex: 0)),
                //             child: Row(
                //
                //               children: [
                //                 Expanded(child: Align(
                //                     alignment: Alignment.bottomLeft,
                //                     child: Icon(Icons.arrow_back, color: Colors.black, size: Dimensions.fontSize18))),
                //
                //                 Expanded(
                //                   flex: 2,
                //                   child: Text(
                //                     "Booking Successful",
                //                     maxLines: 1,
                //                     overflow: TextOverflow.ellipsis,
                //                     style: albertSansRegular.copyWith(
                //                         fontSize: Dimensions.fontSize14,
                //                         color: Theme.of(context).hintColor),
                //                   ),
                //                 ),
                //                   SizedBox(width: 10,)
                //               ],
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                SliverToBoxAdapter(
                  child: Container(
                    width: Get.size.width,
                    height: Get.size.height,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      image: DecorationImage(
                          image: AssetImage(Images.icsuccessfull),
                          fit: BoxFit.contain),
                    ),
                  ),
                ),
              ],
            ),

            // Floating Button at Bottom
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.offAll(() => DashboardScreen(pageIndex: 0));
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Back To Home",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
