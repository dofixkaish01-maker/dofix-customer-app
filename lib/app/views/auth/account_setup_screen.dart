import 'package:do_fix/app/widgets/custom_button_widget.dart';
import 'package:do_fix/app/widgets/custom_textfield.dart';
import 'package:do_fix/controllers/auth_controller.dart';
import 'package:do_fix/helper/route_helper.dart';
import 'package:do_fix/utils/dimensions.dart';
import 'package:do_fix/utils/images.dart';
import 'package:do_fix/utils/sizeboxes.dart';
import 'package:do_fix/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountSetupScreen extends StatelessWidget {
  final String phone;
  AccountSetupScreen({super.key, required this.phone});
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                            "Account Setup",
                            style: albertSansBold.copyWith(
                                fontSize: Dimensions.fontSize30),
                          ),
                          sizedBox30(),
                          CustomTextField(
                            showTitle: true,
                            capitalization: TextCapitalization.words,
                            controller: _firstNameController,
                            hintText: "First Name",
                            validation: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your First name';
                              } else if (!RegExp(r'^[A-Za-z ]+$')
                                  .hasMatch(value)) {
                                return 'Name can only contain letters and spaces';
                              } else if (value.trim().length < 3) {
                                return 'Name must be at least 3 characters long';
                              }
                              return null;
                            },
                          ),
                          sizedBox30(),
                          CustomTextField(
                            showTitle: true,
                            capitalization: TextCapitalization.words,
                            controller: _lastNameController,
                            hintText: "Last Name",
                            validation: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your Last name';
                              } else if (!RegExp(r'^[A-Za-z ]+$')
                                  .hasMatch(value)) {
                                return 'Name can only contain letters and spaces';
                              } else if (value.trim().length < 3) {
                                return 'Name must be at least 3 characters long';
                              }
                              return null;
                            },
                          ),
                          sizedBox20(),
                          CustomTextField(
                            showTitle: true,
                        hintText: 'Email',
                        controller: _emailController,
                      
                        validation: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          } else if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                          sizedBox30(),
                              CustomButtonWidget(
                            buttonText: "Create",
                            onPressed: () {
                      
                              if (_formKey.currentState!.validate()) {
                                Get.find<AuthController>().register(_emailController.text, _firstNameController.text, _lastNameController.text, phone);
                      
                              }
                            }, width:  MediaQuery.of(context).size.width - 40,
                          ),
                        
                          sizedBox4(),
                         
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
  }
}
