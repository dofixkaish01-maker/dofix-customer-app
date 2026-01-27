import 'dart:async';
import 'package:do_fix/app/widgets/custom_button_widget.dart';
import 'package:do_fix/controllers/auth_controller.dart';
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
  const LoginVerificationScreen({super.key, this.phoneNo});

  @override
  State<LoginVerificationScreen> createState() =>
      _LoginVerificationScreenState();
}

class _LoginVerificationScreenState extends State<LoginVerificationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();

  Timer? _timer;
  int _remainingTime = 60;
  bool _isResendEnabled = false;

  static const Color primaryBlue = Color(0xff227FA8);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _isResendEnabled = false;
    _remainingTime = 60;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        setState(() => _isResendEnabled = true);
        timer.cancel();
      }
    });
  }

  void _resendOtp() {
    if (!_isResendEnabled) return;

    Get.find<AuthController>()
        .sendOtpApi(Get.find<AuthController>().phoneNumber.value)
        .then((_) => _startTimer());
  }

  @override
  Widget build(BuildContext context) {
    final PinTheme otpPinTheme = PinTheme(
      shape: PinCodeFieldShape.box,
      fieldHeight: 50,
      fieldWidth: 50,
      borderRadius: BorderRadius.circular(Dimensions.radius10),
      borderWidth: 1,

      activeColor: primaryBlue,
      selectedColor: primaryBlue,
      inactiveColor: primaryBlue,

      activeFillColor: Colors.white,
      selectedFillColor: primaryBlue.withOpacity(0.08),
      inactiveFillColor: Colors.white,

      errorBorderColor: Colors.red,
    );

    return GetBuilder<AuthController>(
      builder: (controller) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Images.icLoginBg),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Color(0xff227FA8).withOpacity(0.25), // 👈 shadow color
                  BlendMode.srcATop,
                ),
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
                      width: 120,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      width: Get.width,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft:
                          Radius.circular(Dimensions.radius40),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(
                            Dimensions.paddingSizeDefault),
                        child: Column(
                          children: [
                            sizedBox50(),

                            Text(
                              "OTP Verification",
                              style: albertSansBold.copyWith(
                                fontSize: Dimensions.fontSize30,
                                color: primaryBlue,
                              ),
                            ),

                            sizedBox8(),

                            Text(
                              "Please enter OTP shared on your mobile number",
                              style:
                              albertSansBold.copyWith(
                                fontSize:
                                Dimensions.fontSize12,
                                color: primaryBlue,
                              ),
                            ),

                            sizedBox30(),

                            PinCodeTextField(
                              appContext: context,
                              length: 4,
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              animationType: AnimationType.slide,
                              enableActiveFill: true,

                              textStyle: const TextStyle(
                                color: primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),

                              pinTheme: otpPinTheme,

                              backgroundColor: Colors.transparent,
                              animationDuration:
                              const Duration(milliseconds: 300),

                              validator: (value) {
                                if (value == null || value.length != 4) {
                                  return "Enter valid 4 digit OTP";
                                }
                                return null;
                              },

                              beforeTextPaste: (text) => true,
                            ),

                            sizedBox20(),

                            CustomButtonWidget(
                              buttonText: "VERIFY",
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  controller.VerifyOtp(
                                    widget.phoneNo ?? "",
                                    _otpController.text.trim(),
                                  );
                                }
                              },
                            ),

                            sizedBox20(),

                            TextButton(
                              onPressed:
                              _isResendEnabled ? _resendOtp : null,
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                      "Didn’t receive a code? ",
                                      style:
                                  albertSansBold.copyWith(
                                  fontSize:
                                  Dimensions.fontSize12,
                                  color: primaryBlue,
                                ),
                              ),
                                    TextSpan(
                                      text: _isResendEnabled
                                          ? "Resend"
                                          : "Resend in $_remainingTime sec",
                                      style:
                                      albertSansBold.copyWith(
                                        fontSize:
                                        Dimensions.fontSize12,
                                        color: primaryBlue,
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
      },
    );
  }
}
