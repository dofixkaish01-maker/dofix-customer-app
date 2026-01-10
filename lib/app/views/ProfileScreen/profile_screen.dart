import 'dart:io';

import 'package:do_fix/utils/app_constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../controllers/dashboard_controller.dart';
import '../../../utils/dimensions.dart';
import '../../../utils/styles.dart';
import '../../../widgets/custom_text_field.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_button_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  File? _pickedImage; // Image file
  String image = "";
  FilePickerResult? _result; // File picker result
  @override
  void initState() {
    super.initState();
    final user = Get.find<DashBoardController>().userModel;
    _firstName.text = user.firstName ?? "First Name";
    _lastName.text = user.lastName ?? "Last Name";
    _email.text = user.email ?? "Email";
    _phoneController.text = user.phone ?? "Phone";
    image = user.profileImage ?? "assets/images/person_png.png";
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _pickedImage = File(result.files.single.path!);
        _result = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBar(
          title: "Profile Settings",
          isBackButtonExist: true,
          isSearchButtonExist: false,
          isCartButtonExist: false,
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),

                  /// Avatar Picker
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _pickedImage != null
                          ? FileImage(_pickedImage!)
                          : (image.isNotEmpty && !image.contains("default.png")
                              ? (() {
                                  final link =
                                      AppConstants.imgProfileBaseUrl + image;
                                  print('Profile image link: $link');
                                  print('Profile image link: $image');
                                  return NetworkImage(link);
                                })()
                              : AssetImage("assets/images/person_png.png")
                                  as ImageProvider),
                      // TODO : Update image functionality here
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildLabel("First Name"),
                  CustomTextField(
                    isNumber: false,
                    inputType: TextInputType.name,
                    controller: _firstName,
                    isPhone: false,
                    hintText: "First Name",
                    validation: (value) => value == null || value.isEmpty
                        ? 'Please enter your first name'
                        : null,
                  ),

                  const SizedBox(height: 12),
                  _buildLabel("Last Name"),
                  CustomTextField(
                    isNumber: false,
                    inputType: TextInputType.name,
                    controller: _lastName,
                    isPhone: false,
                    hintText: "Last Name",
                    validation: (value) => value == null || value.isEmpty
                        ? 'Please enter your last name'
                        : null,
                  ),

                  const SizedBox(height: 12),
                  _buildLabel("Phone Number"),
                  CustomTextField(
                    isNumber: true,
                    inputType: TextInputType.phone,
                    controller: _phoneController,
                    readOnly: true,
                    isPhone: true,
                    hintText: "Phone Number",
                    validation: (value) => value == null || value.isEmpty
                        ? 'Please enter your phone number'
                        : null,
                  ),

                  const SizedBox(height: 12),
                  _buildLabel("Email"),
                  CustomTextField(
                    isNumber: false,
                    inputType: TextInputType.emailAddress,
                    controller: _email,
                    isPhone: false,
                    hintText: "Email",
                    validation: (value) => value == null || value.isEmpty
                        ? 'Please enter your email'
                        : null,
                  ),
                  // TODO : Update image button here
                  const SizedBox(height: 20),
                  CustomButtonWidget(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Get.find<DashBoardController>().updateProfile(
                            _firstName.text.trim(),
                            _lastName.text.trim(),
                            _email.text.trim(),
                            _pickedImage);
                      }
                    },
                    buttonText: 'Update',
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: albertSansRegular.copyWith(fontSize: Dimensions.fontSize13),
      ),
    );
  }
}
