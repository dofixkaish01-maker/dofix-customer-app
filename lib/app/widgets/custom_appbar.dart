import 'dart:developer';

import 'package:do_fix/app/views/cart_screen/cart_screen.dart';
import 'package:do_fix/controllers/auth_controller.dart';
import 'package:do_fix/controllers/dashboard_controller.dart';
import 'package:do_fix/widgets/search_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../utils/dimensions.dart';
import '../../utils/sizeboxes.dart';
import '../../utils/styles.dart';
import '../../utils/theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool isBackButtonExist;
  final bool isCartButtonExist;
  final bool? isSearchButtonExist;
  final bool showTitle;
  final Function? onBackPressed;
  final Widget? menuWidget;
  final Widget? drawerButton;
  final Color? bgColor;
  final Color? iconColor;
  final bool isAddressExist;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.onBackPressed,
    this.isBackButtonExist = false,
    this.isCartButtonExist = true,
    this.menuWidget,
    this.drawerButton,
    this.bgColor,
    this.iconColor,
    this.isSearchButtonExist,
    this.showTitle = false,
    this.isAddressExist = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(40.0),
        child: Column(
          children: [
            Visibility(
              child: SizedBox(
                height: 10,
              ),
              visible: showTitle,
            ),
            Visibility(
              visible: showTitle,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    title ?? "",
                    textAlign: TextAlign.start,
                    style: albertSansRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              child: SizedBox(
                height: 30,
              ),
              visible: showTitle,
            ),
            Visibility(
              visible: isBackButtonExist,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  if (onBackPressed != null) {
                    onBackPressed!();
                  } else {
                    Get.back();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 35,
                        width: 36,
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4)),
                        child:
                            SvgPicture.asset('assets/icons/ic_arrow_left.svg'),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: Text(
                        title ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Albert Sans',
                          fontWeight: FontWeight.w500,
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ),
            Visibility(
              visible: isSearchButtonExist ?? true,
              child: Padding(
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Get.to(() => SearchScreen());
                      },
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSize10),
                        decoration: BoxDecoration(
                          color: primaryColorDuskyWhite,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radius5),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.search,
                              color: Theme.of(context).hintColor,
                            ),
                            sizedBoxW10(),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Search Service",
                                    style: albertSansRegular.copyWith(
                                        fontSize: Dimensions.fontSize12,
                                        fontWeight: FontWeight.w300,
                                        color: Theme.of(context).hintColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      flexibleSpace: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/header_bg.png',
            fit: BoxFit.cover,
          ),
          GetBuilder<DashBoardController>(builder: (controller) {
            log("Address value in Appbar : ${controller.address} ");
            return FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Visibility(
                          visible: isAddressExist,
                          child: Expanded(
                            child: Row(
                              children: [
                                Visibility(
                                  visible: controller.address != null &&
                                      controller.address!.isNotEmpty,
                                  child: InkWell(
                                    onTap: () {
                                      debugPrint(
                                          "Address value : ${controller.address} ");
                                    },
                                    child: Container(
                                      constraints:
                                          BoxConstraints(maxWidth: 250),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.location_on_sharp,
                                                  color: Colors.white,
                                                  size: Dimensions.fontSize15),
                                              SizedBox(
                                                width: 3,
                                              ),
                                              Flexible(
                                                child: Text(
                                                  controller.shortAddress.value
                                                          .isNotEmpty
                                                      ? controller
                                                          .shortAddress.value
                                                      : "Select Address",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: albertSansRegular
                                                      .copyWith(
                                                    fontSize:
                                                        Dimensions.fontSize14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Container(
                                            constraints:
                                                BoxConstraints(maxWidth: 230),
                                            child: Text(
                                              controller.address?.isNotEmpty ==
                                                      true
                                                  ? controller.address!
                                                  : "",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: albertSansRegular.copyWith(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Visibility(
                          visible: isCartButtonExist,
                          child: IconButton(
                            tooltip: "Cart",
                            onPressed: () async {
                              final authController = Get.find<AuthController>();
                              bool isGuest =
                                  await authController.returnIsGuest();
                              if (isGuest) {
                                authController.checkIfGuest();
                              } else {
                                await Get.find<DashBoardController>()
                                    .getCartListing(
                                        limit: "100",
                                        offset: "1",
                                        isRoute: false,
                                        showLoader: false);
                                Get.to(() => CartScreen());
                              }
                            },
                            icon: Badge(
                              label: Text(
                                "${controller.cartModel.content?.cart?.data?.length == null ? "0" : controller.cartModel.content?.cart?.data?.length}",
                              ),
                              offset: const Offset(6, -4),
                              backgroundColor: Colors.red,
                              child: Container(
                                height: 35,
                                width: 36,
                                padding: EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: SvgPicture.asset(
                                    'assets/icons/ic_buy_cart.svg'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Visibility(
                    //   visible: isBackButtonExist,
                    //   child: GestureDetector(
                    //     behavior: HitTestBehavior.translucent,
                    //     onTap: () {
                    //       if (onBackPressed != null) {
                    //         onBackPressed!();
                    //       } else {
                    //         Get.back();
                    //       }
                    //     },
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.start,
                    //       crossAxisAlignment: CrossAxisAlignment.center,
                    //       children: [
                    //         Container(
                    //           height: 35,
                    //           width: 36,
                    //           padding: EdgeInsets.all(6),
                    //           decoration: BoxDecoration(
                    //               color: Colors.white,
                    //               borderRadius: BorderRadius.circular(4)),
                    //           child: SvgPicture.asset(
                    //               'assets/icons/ic_arrow_left.svg'),
                    //         ),
                    //         SizedBox(
                    //           width: 10,
                    //         ),
                    //         Expanded(
                    //             child: Text(
                    //           title ?? "",
                    //           maxLines: 1,
                    //           overflow: TextOverflow.ellipsis,
                    //           style: TextStyle(
                    //             color: Colors.white,
                    //             fontSize: 16,
                    //             fontFamily: 'Albert Sans',
                    //             fontWeight: FontWeight.w500,
                    //           ),
                    //         )),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight((showTitle || (isSearchButtonExist ?? true)) ? 136 : 130);
}
