import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controllers/auth_controller.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../model/pages_model.dart';
import '../../../utils/dimensions.dart';
import '../../../utils/sizeboxes.dart';
import '../../../utils/styles.dart';
import '../../../utils/theme.dart';
import '../HtmlPage/html_pages.dart';
import 'package:do_fix/app/views/home/refer screen/refer_earn_screen.dart';

import '../helpSupport/help_and_support_screen.dart';

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
              child: Text(
                "No",
                style: TextStyle(color: Colors.red),
              ),
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
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ///  Icon
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                  size: 30,
                ),
              ),

              const SizedBox(height: 18),

              /// Title
              const Text(
                "Confirm Logout",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 10),

              /// Description
              const Text(
                "Are you sure you want to log out from your account?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 28),

              /// Buttons
              Row(
                children: [
                  /// Cancel
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.grey.withOpacity(0.4),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Cancel
                      },
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  /// Logout
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Get.back(); // dialog close
                        authController.logout(); //  same controller call
                      },
                      child: const Text(
                        "Log Out",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashBoardController>(builder: (controller) {
      return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,

          floatingActionButton: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final isTablet = w >= 600;

              return Padding(
                // bottom nav / safe spacing
                padding: EdgeInsets.only(bottom: isTablet ? 80 : 65),
                child: FloatingActionButton.extended(
                  backgroundColor: const Color(0xFF207FA7),
                  onPressed: () {
                    Get.to(() => const HelpSupportScreen());
                  },
                  label: Row(
                    children: [
                      const Icon(Icons.support_agent_rounded, color: Colors.white),
                      const SizedBox(width: 7),
                      Text(
                        'Help & Support',
                        style: GoogleFonts.roboto(color: Colors.white),
                      )
                    ],
                  ),
                ),
              );
            },
          ),

          body: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              final isTablet = w >= 600;

              // responsive paddings + max width for tablet/iPad
              final horizontalPadding = isTablet ? 24.0 : 16.0;
              final contentMaxWidth = isTablet ? 520.0 : double.infinity;

              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentMaxWidth),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          // ensures Spacer works + button stays at bottom if content is short
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              //Profile setting
                              SizedBox(height: isTablet ? 24 : 20),

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
                                //Profile setting
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Profile Settings",
                                        style: albertSansRegular.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.black,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),

                              sizedBox30(),

                              //Ratings
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
                              //Manage Addresses
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
                                onTap: () async {
                                  await controller.getPagesData();
                                  Get.to(() => HtmlContentScreen(
                                    title: "About DoFix",
                                    htmlContent:
                                    controller.apiResponse.content.aboutUs?.value ?? "",
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
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.black,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),

                              sizedBox30(),

                              GestureDetector(
                                onTap: () {
                                  openUrl("https://dofix.in/privacy-policy");
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Privacy Policy",
                                        style: albertSansRegular.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.black,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),

                              sizedBox30(),

                              GestureDetector(
                                onTap: () {
                                  openUrl("https://dofix.in/terms");
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Terms & Conditions",
                                        style: albertSansRegular.copyWith(
                                          fontSize: Dimensions.fontSizeDefault,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.black,
                                      size: 18,
                                    ),
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
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.black,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),

                              sizedBox30(),

                              SizedBox(height: isTablet ? 48 : 40),

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
                                    showLogoutDialog(); //  FIXED
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
                    ),
                  ),
                ),
              );
            },
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
      //             ...
      //           ],
      //         ),
      //       ),
      //     )
      //   ],
      // );
    });
  }
// void _showAccountHelpBottomSheet() {
//   const supportNumber = "8383849293";
//
//   Get.bottomSheet(
//     Container(
//       padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // drag handle
//           Container(
//             width: 40,
//             height: 4,
//             margin: const EdgeInsets.only(bottom: 12),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(2),
//             ),
//           ),
//
//           const Text(
//             "Help & Support",
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//
//           const SizedBox(height: 6),
//
//           const Text(
//             "Need help with your account or services?\nWe’re here to help you.",
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 13,
//               color: Colors.black54,
//             ),
//           ),
//
//           const SizedBox(height: 20),
//
//           // Call Support
//           ListTile(
//             leading: const CircleAvatar(
//               backgroundColor: Color(0xFFE8F5E9),
//               child: Icon(Icons.call, color: Colors.green),
//             ),
//             title: const Text(
//               "Call Support",
//               style: TextStyle(fontWeight: FontWeight.w500),
//             ),
//             subtitle: const Text("Talk directly with our support team"),
//             onTap: () async {
//               final uri = Uri.parse("tel:+91$supportNumber");
//               if (await canLaunchUrl(uri)) {
//                 await launchUrl(uri);
//               }
//             },
//           ),
//
//           const SizedBox(height: 8),
//
//           // WhatsApp Support
//           ListTile(
//             leading: const CircleAvatar(
//               backgroundColor: Color(0xFFE0F2F1),
//               child: Icon(Icons.chat, color: Colors.teal),
//             ),
//             title: const Text(
//               "WhatsApp Support",
//               style: TextStyle(fontWeight: FontWeight.w500),
//             ),
//             subtitle: const Text("Chat with us on WhatsApp"),
//             onTap: () async {
//               final uri = Uri.parse(
//                 "https://wa.me/91$supportNumber?text="
//                     "Hi, I need some assistance with my account. Could you please let me know how you can help me?",
//               );
//
//               if (await canLaunchUrl(uri)) {
//                 await launchUrl(
//                   uri,
//                   mode: LaunchMode.externalApplication,
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//     ),
//     isScrollControlled: true,
//   );
// }
}

class NewCustomButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String buttonText;
  final Color? color;
  final IconData? icon;
  final bool transparent;
  final double? width;
  final Color borderSideColor;
  final Color textColor;

  const NewCustomButtonWidget({
    super.key,
    required this.onPressed,
    required this.buttonText,
    this.color,
    this.icon,
    this.transparent = false,
    this.width,
    required this.borderSideColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 52, // little taller for premium feel
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          elevation: MaterialStateProperty.all(transparent ? 0 : 4),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14), // smooth premium curve
            ),
          ),
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (states) {
              if (transparent) return Colors.transparent;
              if (states.contains(MaterialState.disabled)) {
                return Colors.grey.shade400;
              }
              return color ?? Colors.red; // default red
            },
          ),
          foregroundColor: MaterialStateProperty.all(textColor),
          side: MaterialStateProperty.all(
            BorderSide(
              color: borderSideColor, //  red border
              width: 1.5,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              buttonText,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> openUrl(String url) async {
  final Uri uri = Uri.parse(url);

  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw Exception('Could not launch $url');
  }
}