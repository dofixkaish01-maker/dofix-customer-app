import 'package:do_fix/app/widgets/custom_button_widget.dart';
import 'package:do_fix/app/widgets/custom_textfield.dart';
import 'package:do_fix/controllers/auth_controller.dart';
import 'package:do_fix/controllers/dashboard_controller.dart';
import 'package:do_fix/utils/dimensions.dart';
import 'package:do_fix/utils/images.dart';
import 'package:do_fix/utils/sizeboxes.dart';
import 'package:do_fix/utils/styles.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../model/pages_model.dart';
import '../HtmlPage/html_pages.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isTermsAccepted = false;
  final _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (controller) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(Images.icLoginBg),
              fit: BoxFit.cover,
            ),
          ),
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
                        topLeft: Radius.circular(Dimensions.radius40),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(
                        Dimensions.paddingSizeDefault,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            sizedBox50(),
                            Text(
                              "Login",
                              style: albertSansBold.copyWith(
                                fontSize: Dimensions.fontSize30,
                              ),
                            ),
                            sizedBox8(),
                            Text(
                              "Enter your phone number to login",
                              style: albertSansRegular.copyWith(
                                fontSize: Dimensions.fontSize15,
                              ),
                            ),
                            sizedBox30(),

                            /// PHONE FIELD
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
                                  return 'Enter valid 10 digit number';
                                }
                                return null;
                              },
                            ),

                            sizedBox30(),

                            /// SEND OTP BUTTON (DISABLED UNTIL T&C ACCEPTED)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Checkbox(
                                  activeColor:Color(0xff227FA8),
                                  value: isTermsAccepted,
                                  onChanged: (value) {
                                    setState(() {
                                      isTermsAccepted = value ?? false;
                                    });
                                  },
                                ),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                      ),
                                      children: [
                                        const TextSpan(
                                            text: "I agree to the "),
                                        TextSpan(
                                          text: "Terms & Conditions",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            decoration:
                                            TextDecoration.underline,
                                          ),
                                          recognizer:
                                          TapGestureRecognizer()
                                            ..onTap = () {
                                              Get.to(
                                                    () => HtmlContentScreen(
                                                  title:
                                                  "Terms & Conditions",
                                                  htmlContent:
                                                  (Get.find<
                                                      DashBoardController>()
                                                      .apiResponse
                                                      .content
                                                      .termsAndConditions ??
                                                      PageInfo(
                                                        id: '',
                                                        key: '',
                                                        value: '',
                                                        type: '',
                                                        isActive: 0,
                                                        createdAt:
                                                        '',
                                                        updatedAt:
                                                        '',
                                                        translations:
                                                        [],
                                                      ))
                                                      .value,
                                                ),
                                              );
                                            },
                                        ),
                                        const TextSpan(text: " and "),
                                        TextSpan(
                                          text: "Privacy Policy",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            decoration:
                                            TextDecoration.underline,
                                          ),
                                          recognizer:
                                          TapGestureRecognizer()
                                            ..onTap = () {
                                              Get.to(
                                                    () => HtmlContentScreen(
                                                  title:
                                                  "Privacy Policy",
                                                  htmlContent:
                                                  (Get.find<
                                                      DashBoardController>()
                                                      .apiResponse
                                                      .content
                                                      .privacyPolicy ??
                                                      PageInfo(
                                                        id: '',
                                                        key: '',
                                                        value: '',
                                                        type: '',
                                                        isActive: 0,
                                                        createdAt:
                                                        '',
                                                        updatedAt:
                                                        '',
                                                        translations:
                                                        [],
                                                      ))
                                                      .value,
                                                ),
                                              );
                                            },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            sizedBox20(),

                            /// TERMS & CONDITIONS SECTION (BOTTOM)
                            CustomButtonWidget(
                              buttonText: "SEND OTP",
                              onPressed: isTermsAccepted
                                  ? () {
                                if (_formKey.currentState!.validate()) {
                                  controller.sendOtpApi(
                                    _phoneController.text.trim(),
                                  );
                                }
                              }
                              : null, // important for disabling button
                              color: Theme.of(context).primaryColor, width:  MediaQuery.of(context).size.width - 40,
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

