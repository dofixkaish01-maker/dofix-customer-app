import 'package:do_fix/controllers/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../model/pages_model.dart';
import '../../../utils/dimensions.dart';
import '../../../utils/sizeboxes.dart';
import '../../../utils/styles.dart';
import '../../../utils/theme.dart';
import '../HtmlPage/html_pages.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Call visitChildElements() here
      // Get.find<DashBoardController>().getPagesData();

      bool isGuest = await authController.returnIsGuest();
      if (isGuest) {
        Get.find<DashBoardController>().isGuest.value = true;
      } else {
        Get.find<DashBoardController>().isGuest.value = false;
      }
    });
  }
  //Delete Dialog
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Account"),
          content:
              Text("Do you really want to delete your account permanently?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await Get.find<DashBoardController>().getUserInfo(false);
                String phoneNumber =
                    Get.find<DashBoardController>().userModel.phone;
                Get.find<AuthController>()
                    .deleteAccount(phoneNumber: phoneNumber);
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }
  //Logout Dialog
  void showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); //  Cancel
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Get.back();
              authController.logout(); // Logout
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
      barrierDismissible: false, // outside tap disable
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashBoardController>(builder: (controller) {
      return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                //Profile setting
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    final authController = Get.find<AuthController>();
                    bool isGuest = await authController.returnIsGuest();
                    if (isGuest) {
                      authController.checkIfGuest();
                    } else {
                      controller.getUserInfo(true);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(
                        "Profile Settings",
                        style: albertSansRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            fontWeight: FontWeight.w400),
                      )),
                      Icon(Icons.arrow_forward_ios,
                          color: Colors.black, size: 18),
                    ],
                  ),
                ),
                sizedBox30(),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Expanded(
                //         child: Text(
                //       "Ratings",
                //       style: albertSansRegular.copyWith(
                //           fontSize: Dimensions.fontSize20),
                //     )),
                //     Icon(Icons.arrow_forward_ios, color: Colors.black),
                //   ],
                // ),
                // sizedBox30(),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Expanded(
                //         child: Text(
                //       "Manage Addresses",
                //       style: albertSansRegular.copyWith(
                //           fontSize: Dimensions.fontSize20),
                //     )),
                //     Icon(Icons.arrow_forward_ios, color: Colors.black),
                //   ],
                // ),
                // sizedBox30(),
                GestureDetector(
                  // onTap: () {
                  //   Get.to(() => HtmlContentScreen(
                  //       title: "About DoFix",
                  //       htmlContent: (controller.apiResponse.content.aboutUs ??
                  //               PageInfo(
                  //                   id: '',
                  //                   key: '',
                  //                   value: '',
                  //                   type: '',
                  //                   isActive: 0,
                  //                   createdAt: '',
                  //                   updatedAt: '',
                  //                   translations: []))
                  //           .value));
                  // },
                  onTap: () async {
                    await controller.getPagesData();
                    Get.to(() => HtmlContentScreen(
                      title: "About DoFix",
                      htmlContent: controller.apiResponse.content.aboutUs?.value ?? "",
                    ));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(
                        "About DoFix",
                        style: albertSansRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            fontWeight: FontWeight.w400),
                      )),
                      Icon(Icons.arrow_forward_ios,
                          color: Colors.black, size: 18),
                    ],
                  ),
                ),
                sizedBox30(),
                GestureDetector(
                  onTap: () {
                    Get.to(() => HtmlContentScreen(
                        title: "Privacy Policy",
                        htmlContent:
                            (controller.apiResponse.content.privacyPolicy ??
                                    PageInfo(
                                        id: '',
                                        key: '',
                                        value: '',
                                        type: '',
                                        isActive: 0,
                                        createdAt: '',
                                        updatedAt: '',
                                        translations: []))
                                .value));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(
                        "Privacy Policy",
                        style: albertSansRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            fontWeight: FontWeight.w400),
                      )),
                      Icon(Icons.arrow_forward_ios,
                          color: Colors.black, size: 18),
                    ],
                  ),
                ),
                sizedBox30(),
                GestureDetector(
                  onTap: () {
                    Get.to(() => HtmlContentScreen(
                        title: "Terms & Conditions",
                        htmlContent: (controller
                                    .apiResponse.content.termsAndConditions ??
                                PageInfo(
                                    id: '',
                                    key: '',
                                    value: '',
                                    type: '',
                                    isActive: 0,
                                    createdAt: '',
                                    updatedAt: '',
                                    translations: []))
                            .value));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(
                        "Terms & Conditions",
                        style: albertSansRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            fontWeight: FontWeight.w400),
                      )),
                      Icon(Icons.arrow_forward_ios,
                          color: Colors.black, size: 18),
                    ],
                  ),
                ),
                sizedBox30(),
                GestureDetector(
                  onTap: () async {
                    final authController = Get.find<AuthController>();
                    bool isGuest = await authController.returnIsGuest();
                    if (isGuest) {
                      authController.checkIfGuest();
                    } else {
                      _showDeleteAccountDialog(context);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(
                        "Delete Account",
                        style: albertSansRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            fontWeight: FontWeight.w400),
                      )),
                      Icon(Icons.arrow_forward_ios,
                          color: Colors.black, size: 18),
                    ],
                  ),
                ),
                // sizedBox30(),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Expanded(
                //         child: Text(
                //       "Complaint center",
                //       style: albertSansRegular.copyWith(
                //           fontSize: Dimensions.fontSize20),
                //     )),
                //     Icon(Icons.arrow_forward_ios, color: Colors.black),
                //   ],
                // ),

                Spacer(),
                Obx(
                      () => controller.isGuest.value
                      ? NewCustomButtonWidget(
                    buttonText: 'Log In',
                    onPressed: () {
                      Get.toNamed('/login');
                    },
                    transparent: true,
                    borderSideColor: primaryBlue,
                    textColor: primaryBlue,
                  )
                      : NewCustomButtonWidget(
                    buttonText: 'Log Out',
                    onPressed: () {
                      showLogoutDialog(); // 🔥 FIXED
                    },
                    transparent: true,
                    borderSideColor: darkRed,
                    textColor: darkRed,
                  ),
                ),
                sizedBox20(),
              ],
            ),
          ),
        ),
      );
      //   CustomScrollView(
      //   slivers: <Widget>[
      //     SliverAppBar(
      //       automaticallyImplyLeading: false,
      //       pinned: true,
      //       backgroundColor: Colors.white,
      //       expandedHeight: 190.0,
      //       flexibleSpace: FlexibleSpaceBar(
      //         background: Padding(
      //           padding: const EdgeInsets.symmetric(
      //               horizontal: Dimensions.paddingSizeDefault),
      //           child: Column(
      //             children: [
      //               sizedBox65(),
      //               Row(
      //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                 crossAxisAlignment: CrossAxisAlignment.center,
      //                 children: [
      //                   Row(
      //                     children: [
      //                       Image.asset(
      //                         Images.iclogo,
      //                         height: 70,
      //                         width: 70,
      //                       ),
      //                     ],
      //                   ),
      //                   CustomNotificationButton(
      //                     icon: Icons.shopping_cart,
      //                     tap: () {},
      //                     color: Theme.of(context).primaryColor,
      //                   )
      //                 ],
      //               ),
      //               InkWell(
      //                 onTap: () {},
      //                 child: Row(
      //                   mainAxisAlignment: MainAxisAlignment.start,
      //                   crossAxisAlignment: CrossAxisAlignment.center,
      //                   children: [
      //                     Icon(Icons.location_on_sharp,
      //                         color: Colors.black, size: Dimensions.fontSize18),
      //                     Expanded(
      //                         child: Text(
      //                       controller.address ?? "",
      //                       maxLines: 1,
      //                       overflow: TextOverflow.ellipsis,
      //                       style: albertSansRegular.copyWith(
      //                           fontSize: Dimensions.fontSize14,
      //                           color: Theme.of(context).hintColor),
      //                     )),
      //                   ],
      //                 ),
      //               ),
      //               SizedBox(height: 20),
      //               Row(
      //                 children: [
      //                   Text("Account",
      //                       style: albertSansRegular.copyWith(
      //                           fontSize: Dimensions.fontSize20)),
      //                 ],
      //               ),
      //             ],
      //           ),
      //         ),
      //       ),
      //       // bottom: PreferredSize(
      //       //   preferredSize: const Size.fromHeight(40.0),
      //       //   child: Padding(
      //       //     padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      //       //     child: Row(
      //       //       children: [
      //       //         Text("Account",
      //       //             style: albertSansRegular.copyWith(
      //       //                 fontSize: Dimensions.fontSize20)),
      //       //       ],
      //       //     ),
      //       //   ),
      //       // ),
      //     ),
      //     SliverToBoxAdapter(
      //       child: Padding(
      //         padding: const EdgeInsets.symmetric(horizontal: 16.0),
      //         child: Column(
      //           children: [
      //             sizedBox20(),
      //             // Row(
      //             //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //             //   children: [
      //             //     Expanded(
      //             //         child: Text(
      //             //       "Profile Settings",
      //             //       style: albertSansRegular.copyWith(
      //             //           fontSize: Dimensions.fontSize20),
      //             //     )),
      //             //     Icon(Icons.arrow_forward_ios, color: Colors.black),
      //             //   ],
      //             // ),
      //             // sizedBox30(),
      //             // Row(
      //             //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //             //   children: [
      //             //     Expanded(
      //             //         child: Text(
      //             //       "Ratings",
      //             //       style: albertSansRegular.copyWith(
      //             //           fontSize: Dimensions.fontSize20),
      //             //     )),
      //             //     Icon(Icons.arrow_forward_ios, color: Colors.black),
      //             //   ],
      //             // ),
      //             // sizedBox30(),
      //             // Row(
      //             //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //             //   children: [
      //             //     Expanded(
      //             //         child: Text(
      //             //       "Manage Addresses",
      //             //       style: albertSansRegular.copyWith(
      //             //           fontSize: Dimensions.fontSize20),
      //             //     )),
      //             //     Icon(Icons.arrow_forward_ios, color: Colors.black),
      //             //   ],
      //             // ),
      //             // sizedBox30(),
      //             GestureDetector(
      //               onTap: () {
      //                 Get.to(() =>
      //                   HtmlContentScreen(
      //                       title: "About FixOn",
      //                       htmlContent:
      //                           (controller.apiResponse.content.aboutUs ??
      //                                   PageInfo(
      //                                       id: '',
      //                                       key: '',
      //                                       value: '',
      //                                       type: '',
      //                                       isActive: 0,
      //                                       createdAt: '',
      //                                       updatedAt: '',
      //                                       translations: []))
      //                               .value));
      //               },
      //               child: Row(
      //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                 children: [
      //                   Expanded(
      //                       child: Text(
      //                     "About FixOn",
      //                     style: albertSansRegular.copyWith(
      //                         fontSize: Dimensions.fontSize20),
      //                   )),
      //                   Icon(Icons.arrow_forward_ios, color: Colors.black),
      //                 ],
      //               ),
      //             ),
      //             sizedBox30(),
      //             GestureDetector(
      //               onTap: () {
      //                 Get.to(() =>
      //                     HtmlContentScreen(
      //                         title: "Privacy Policy",
      //                         htmlContent:
      //                         (controller.apiResponse.content.privacyPolicy ??
      //                             PageInfo(
      //                                 id: '',
      //                                 key: '',
      //                                 value: '',
      //                                 type: '',
      //                                 isActive: 0,
      //                                 createdAt: '',
      //                                 updatedAt: '',
      //                                 translations: []))
      //                             .value));
      //               },
      //               child: Row(
      //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                 children: [
      //                   Expanded(
      //                       child: Text(
      //                     "Privacy Policy",
      //                     style: albertSansRegular.copyWith(
      //                         fontSize: Dimensions.fontSize20),
      //                   )),
      //                   Icon(Icons.arrow_forward_ios, color: Colors.black),
      //                 ],
      //               ),
      //             ),
      //             sizedBox30(),
      //             GestureDetector(
      //               onTap: () {
      //                 Get.to(() =>
      //                     HtmlContentScreen(
      //                         title: "Terms & Conditions",
      //                         htmlContent:
      //                         (controller.apiResponse.content.termsAndConditions ??
      //                             PageInfo(
      //                                 id: '',
      //                                 key: '',
      //                                 value: '',
      //                                 type: '',
      //                                 isActive: 0,
      //                                 createdAt: '',
      //                                 updatedAt: '',
      //                                 translations: []))
      //                             .value));
      //               },
      //               child: Row(
      //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                 children: [
      //                   Expanded(
      //                       child: Text(
      //                     "Terms & Conditions",
      //                     style: albertSansRegular.copyWith(
      //                         fontSize: Dimensions.fontSize20),
      //                   )),
      //                   Icon(Icons.arrow_forward_ios, color: Colors.black),
      //                 ],
      //               ),
      //             ),
      //             // sizedBox30(),
      //             // Row(
      //             //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //             //   children: [
      //             //     Expanded(
      //             //         child: Text(
      //             //       "Complaint center",
      //             //       style: albertSansRegular.copyWith(
      //             //           fontSize: Dimensions.fontSize20),
      //             //     )),
      //             //     Icon(Icons.arrow_forward_ios, color: Colors.black),
      //             //   ],
      //             // ),
      //             sizedBox50(),
      //             CustomButtonWidget(
      //               buttonText: 'Log Out',
      //               onPressed: () {
      //                 Get.find<AuthController>().logout();
      //               },
      //               transparent: true,
      //               borderSideColor: Colors.red,
      //               textColor: Colors.red,
      //             ),
      //           ],
      //         ),
      //       ),
      //     )
      //   ],
      // );
    });
  }
}
class NewCustomButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String buttonText;
  final Color? color;
  final IconData? icon;
  final bool transparent;
  final double? width;

  const NewCustomButtonWidget({
    super.key,
    required this.onPressed,
    required this.buttonText,
    this.color,
    this.icon,
    this.transparent = false,
    this.width, required Color borderSideColor, required Color textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(transparent ? 0 : 2),

          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                (states) {
              if (transparent) {
                return Colors.transparent;
              }
              if (states.contains(MaterialState.disabled)) {
                return Colors.grey.shade400; // ✅ disabled gray
              }
              return color ?? Theme.of(context).primaryColor;
            },
          ),

          foregroundColor: MaterialStateProperty.all(
            transparent
                ? Theme.of(context).primaryColor
                : Colors.white,
          ),

          side: transparent
              ? MaterialStateProperty.all(
            BorderSide(
              color: Theme.of(context).primaryColor,
            ),
          )
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(buttonText),
          ],
        ),
      ),
    );
  }
}
