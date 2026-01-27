import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';

import 'camera_widget.dart';


Future<List<File>> pickFiles(BuildContext context) async {
  List<File> selectedFiles = [];
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text("Camera"),
            onTap: () async {
              Navigator.pop(context);
              final imagePath = await Get.to(() => CameraScreen());
              if (imagePath != null) {
                  selectedFiles.add(File(imagePath));
              }

            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text("Gallery"),
            onTap: () async {
              Navigator.pop(context);
              final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (pickedFile != null) {

                  selectedFiles.add(File(pickedFile.path));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: const Text("Pick PDF"),
            onTap: () async {
              Navigator.pop(context);
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf'],
              );
              if (result != null) {
                selectedFiles.add(File(result.files.single.path!));
                Get.back();
              }
            },
          ),
        ],
      );
    },
  );
  return selectedFiles;

}