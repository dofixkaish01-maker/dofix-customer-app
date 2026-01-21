import 'dart:io';

import 'package:do_fix/utils/app_constants.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/dashboard_controller.dart';
import '../../../utils/dimensions.dart';
import '../../../utils/styles.dart';
import '../../../widgets/custom_text_field.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_button_widget.dart';
import 'package:image_picker/image_picker.dart';


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
  final ImagePicker _picker = ImagePicker();

  File? _pickedImage; // Image file
  String image = "";
  FilePickerResult? _result; // File picker result

  // 🔹 Initial values (important)
  String initialFirstName = '';
  String initialLastName = '';
  String initialEmail = '';
  String initialImage = '';

  bool isChanged = false;

  @override
  void initState() {
    super.initState();

    final user = Get.find<DashBoardController>().userModel;

    initialFirstName = user.firstName ?? '';
    initialLastName = user.lastName ?? '';
    initialEmail = user.email ?? '';
    initialImage = user.profileImage ?? '';

    _firstName.text = initialFirstName;
    _lastName.text = initialLastName;
    _email.text = initialEmail;
    _phoneController.text = user.phone ?? '';
    image = initialImage;

    _addListeners(); // 🔹 ALWAYS LAST
  }

  //check change
  void _addListeners() {
    _firstName.addListener(_checkChanges);
    _lastName.addListener(_checkChanges);
    _email.addListener(_checkChanges);
  }
  void _checkChanges() {
    setState(() {
      isChanged =
          _firstName.text.trim() != initialFirstName ||
          _lastName.text.trim() != initialLastName ||
          _email.text.trim() != initialEmail ||
          _pickedImage != null;
    });
  }
  //pick from camera
  Future<void> _pickFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
        isChanged = true;
      });
    }
  }
  //pick from gallery
  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
        isChanged = true;
      });
    }
  }
  //pick image
  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _pickedImage = File(result.files.single.path!);
        _result = result;
        isChanged = true;
      });
    }
  }
  //show image picker sheet
  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take Photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

//if image change
  void _resetChanges() {
    setState(() {
      _firstName.text = initialFirstName;
      _lastName.text = initialLastName;
      _email.text = initialEmail;
      image = initialImage;
      _pickedImage = null;
      isChanged = false;
    });
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
                    // onTap: _pickImage,
                    onTap: _showImagePickerSheet,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _pickedImage != null
                              ? FileImage(_pickedImage!)
                              : (image.isNotEmpty
                              ? NetworkImage(
                            AppConstants.imgProfileBaseUrl + image,
                          )
                              : const AssetImage(
                            "assets/images/person_png.png",
                          ) as ImageProvider),
                        ),

                        // EDIT ICON (Bottom Right)
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color(0xff227FA8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
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
                      onChanged: (_) {
                        setState(() {
                          isChanged = true;
                        });
                      }
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
                      onChanged: (_) {
                        setState(() {
                          isChanged = true;
                        });
                      }
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
                      onChanged: (_) {
                        setState(() {
                          isChanged = true;
                        });
                      }
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
                      onChanged: (_) {
                        setState(() {
                          isChanged = true;
                        });
                      }
                  ),
                  const SizedBox(height: 20),
                  // CustomButtonWidget(
                  //   onPressed: () {
                  //     if (_formKey.currentState!.validate()) {
                  //       Get.find<DashBoardController>().updateProfile(
                  //           _firstName.text.trim(),
                  //           _lastName.text.trim(),
                  //           _email.text.trim(),
                  //           _pickedImage);
                  //     }
                  //   },
                  //   buttonText: 'Update',
                  // ),
                  //new option
                  /// Buttons
                Row(
                  children: [
                    /// CANCEL BUTTON
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            } else {
                              Get.back();
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          child: const Text("Cancel"),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// SAVE BUTTON
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: CustomButtonWidget(
                          onPressed: isChanged
                              ? () async {
                            if (_formKey.currentState!.validate()) {
                              await Get.find<DashBoardController>().updateProfile(
                                _firstName.text.trim(),
                                _lastName.text.trim(),
                                _email.text.trim(),
                                _pickedImage,
                              );

                              // 🔹 IMPORTANT LINE
                              setState(() {
                                isChanged = false;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Changes saved successfully!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );

                              // 🔹 Optional back
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                            }
                          }
                              : null,
                          buttonText: "Save Changes",
                          color: isChanged
                              ? Theme.of(context).primaryColor
                              : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
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
