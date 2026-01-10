import 'package:do_fix/app/widgets/custom_button_widget.dart';
import 'package:do_fix/app/widgets/custom_textfield.dart';
import 'package:do_fix/helper/route_helper.dart';
import 'package:do_fix/utils/dimensions.dart';
import 'package:do_fix/utils/images.dart';
import 'package:do_fix/utils/sizeboxes.dart';
import 'package:do_fix/utils/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class LoginLocationPickScreen extends StatelessWidget {
  LoginLocationPickScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(Images.icLoginBg), fit: BoxFit.cover)),
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
              flex: 3,
              child: Container(
                width: Get.size.width,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(Dimensions.radius40))),
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Column(
                    children: [
                      sizedBox50(),
                      Text(
                        "Set Your Location",
                        style: albertSansBold.copyWith(
                            fontSize: Dimensions.fontSize30),
                      ),
                      sizedBox8(),
                      Image.asset(
                        "assets/images/ic_location_holder.png",
                        width: 220,
                        height: 220,
                      ),
                      sizedBox30(),
                      CustomButtonWidget(
                        icon: Icons.location_on,
                        buttonText: "Continue with Current Location",
                        onPressed: () {
                          Get.offAllNamed(RouteHelper.getDashboardRoute());
                        },
                      ),
                      sizedBox10(),
                      CustomButtonWidget(
                        transparent: true,
                        icon: CupertinoIcons.search,
                        buttonText: "Set Location Manually",
                        onPressed: () {
                          Get.offAllNamed(RouteHelper.getDashboardRoute());
                        },
                      ),
                      sizedBox4(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
