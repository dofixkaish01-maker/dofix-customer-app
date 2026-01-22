import 'dart:async';
import 'package:do_fix/app/widgets/custom_button_widget.dart';
import 'package:do_fix/app/widgets/custom_textfield.dart';
import 'package:do_fix/controllers/auth_controller.dart';
import 'package:do_fix/helper/route_helper.dart';
import 'package:do_fix/utils/dimensions.dart';
import 'package:do_fix/utils/images.dart';
import 'package:do_fix/utils/sizeboxes.dart';
import 'package:do_fix/utils/styles.dart';
import 'package:do_fix/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class LoginVerificationScreen extends StatefulWidget {
  final String? phoneNo;
  LoginVerificationScreen({super.key, this.phoneNo});

  @override
  State<LoginVerificationScreen> createState() =>
      _LoginVerificationScreenState();
}

class _LoginVerificationScreenState extends State<LoginVerificationScreen> {
  final _phoneController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _otpController = TextEditingController();

  Timer? _timer;
  int _remainingTime = 60;
  bool _isResendEnabled = false;

  @override
  void initState() {
    super.initState();
    _otpController.clear();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isResendEnabled = false;
      _remainingTime = 60;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _isResendEnabled = true;
          _timer?.cancel();
        }
      });
    });
  }

  void _resendOtp() {
    if (_isResendEnabled) {
      // Get.find<AuthController>()
      //     .sendOtpApiFirebase(Get.find<AuthController>().phoneNumber.value)
      //     .then((value) {
      //   _startTimer();
      // });
// TODO : Backend API for resend OTP
      Get.find<AuthController>()
          .sendOtpApi(Get.find<AuthController>().phoneNumber.value)
          .then((value) {
        _startTimer();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (controller) {
      return Scaffold(
        resizeToAvoidBottomInset: false,
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
                      child: Column(
                        children: [
                          sizedBox50(),
                          Text(
                            "OTP Verification",
                            style: albertSansBold.copyWith(
                                fontSize: Dimensions.fontSize30),
                          ),
                          sizedBox8(),
                          Text(
                            "Please enter OTP shared on your mobile number",
                            style: albertSansRegular.copyWith(
                                fontSize: Dimensions.fontSize12),
                          ),
                          sizedBox30(),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            child: PinCodeTextField(
                              length: 4,
                              appContext: context,
                              keyboardType: TextInputType.number,
                              animationType: AnimationType.slide,
                              controller: _otpController,
                              pinTheme: PinTheme(
                                shape: PinCodeFieldShape.box,
                                fieldHeight: 50,
                                fieldWidth: 50,
                                borderWidth: 1,
                                activeBorderWidth: 1,
                                inactiveBorderWidth: 1,
                                errorBorderWidth: 1,
                                selectedBorderWidth: 1,
                                borderRadius:
                                    BorderRadius.circular(Dimensions.radius10),
                                selectedColor: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                selectedFillColor: Colors.white,
                                errorBorderColor: redColor,
                                inactiveFillColor: Colors.white,
                                inactiveColor: Theme.of(context).primaryColor,
                                activeColor: Theme.of(context).primaryColor,
                                activeFillColor: Colors.white,
                              ),
                              animationDuration:
                                  const Duration(milliseconds: 300),
                              backgroundColor: Colors.transparent,
                              enableActiveFill: true,
                              validator: (value) {
                                if (_otpController.text.length != 4) {
                                  return 'Please enter a valid 4-digit OTP';
                                }
                                return null;
                              },
                              beforeTextPaste: (text) => true,
                            ),
                          ),
                          sizedBox20(),
                          CustomButtonWidget(
                            buttonText: "VERIFY",
                            onPressed: () {
                              // TODO : Firebase and API OTP
                              // controller.verifyOtpFirebase(
                              //     otp: _otpController.text.trim(),
                              //     phone: widget.phoneNo ?? "");
                              controller.VerifyOtp(widget.phoneNo ?? "",
                                  _otpController.text.trim());

                            },
                          ),
                          sizedBox20(),
                          TextButton(
                            onPressed: _isResendEnabled ? _resendOtp : null,
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Didn’t received a code? ",
                                    style: albertSansRegular.copyWith(
                                      fontSize: Dimensions.fontSize12,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                  TextSpan(
                                    text: _isResendEnabled
                                        ? "Resend"
                                        : "Resend in $_remainingTime seconds",
                                    style: albertSansBold.copyWith(
                                      fontSize: Dimensions.fontSize12,
                                      color: Theme.of(context).primaryColor,
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
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
