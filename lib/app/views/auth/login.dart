import 'package:do_fix/app/widgets/custom_button_widget.dart';
import 'package:do_fix/app/widgets/custom_textfield.dart';
import 'package:do_fix/controllers/auth_controller.dart';
import 'package:do_fix/controllers/dashboard_controller.dart';
import 'package:do_fix/utils/dimensions.dart';
import 'package:do_fix/utils/images.dart';
import 'package:do_fix/utils/sizeboxes.dart';
import 'package:do_fix/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../model/pages_model.dart';
import '../HtmlPage/html_pages.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (controller) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(Images.icLoginBg), fit: BoxFit.cover)),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: Image.asset(
                    Images.iclogoWhite,
                    height: 100,
                    width: 160,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    width: Get.size.width,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(Dimensions.radius40))),
                    child: Padding(
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            sizedBox50(),
                            Text(
                              "Login",
                              style: albertSansBold.copyWith(
                                  fontSize: Dimensions.fontSize30),
                            ),
                            sizedBox8(),
                            Text(
                              "Enter your phone number to login",
                              style: albertSansRegular.copyWith(
                                  fontSize: Dimensions.fontSize12),
                            ),
                            sizedBox30(),
                            CustomTextField(
                              isNumber: true,
                              inputType: TextInputType.number,
                              controller: _phoneController,
                              isPhone: true,
                              hintText: "Enter your mobile number",
                              validation: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your Phone No';
                                } else if (!RegExp(r'^\d{10}$')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid 10-digit Phone No';
                                }
                                return null;
                              },
                            ),
                            sizedBox20(),
                            CustomButtonWidget(
                              buttonText: "SEND OTP",
                              onPressed: () {
                                // TODO : Firebase and API OTP
                                // controller.sendOtpApiFirebase(
                                //     _phoneController.text.trim());
                                controller.sendOtpApi(
                                  _phoneController.text.trim(),
                                );
                              },
                            ),
                            sizedBox20(),
                            GestureDetector(
                              onTap: () {
                                controller.loginAsGuest();
                              },
                              child: const Text(
                                'Continue as Guest',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            sizedBox20(),
                            const Text(
                              'By logging in, you agree to our ',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 11),
                            ),
                            sizedBox4(),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Get.to(() => HtmlContentScreen(
                                          title: "Terms & Conditions",
                                          htmlContent:
                                              (Get.find<DashBoardController>()
                                                          .apiResponse
                                                          .content
                                                          .termsAndConditions ??
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
                                    child: Text('Terms & Conditions',
                                        style: TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.w600,
                                          fontSize: Dimensions.fontSize12,
                                          color: Colors.black,
                                        )),
                                  ),
                                  const Text(' and ',
                                      style: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        color: Colors.black,
                                        fontSize: Dimensions.fontSize12,
                                      )),
                                  GestureDetector(
                                    onTap: () {
                                      Get.to(() => HtmlContentScreen(
                                          title: "Privacy Policy",
                                          htmlContent:
                                              (Get.find<DashBoardController>()
                                                          .apiResponse
                                                          .content
                                                          .privacyPolicy ??
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
                                    child: Text(
                                      ' Privacy Policy',
                                      style: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.w600,
                                        fontSize: Dimensions.fontSize12,
                                        color: Colors.black,
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
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
