import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';

import 'custom_snack_bar.dart';

class ProfileImageUploader extends StatefulWidget {
  final Function(String) onImageSelected;
  final String? initialImageUrl; // Can be a file path or a network URL

  ProfileImageUploader({super.key, required this.onImageSelected, this.initialImageUrl});

  @override
  _ProfileImageUploaderState createState() => _ProfileImageUploaderState();
}

class _ProfileImageUploaderState extends State<ProfileImageUploader> {
  XFile? _selectedImage;

  bool isLocalFile(String path) {
    return File(path).existsSync(); // Check if it's a local file
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File imageFile = File(image.path);
      int fileSize = await imageFile.length(); // Get file size in bytes
      double fileSizeInMB = fileSize / (1024 * 1024); // Convert to MB

      if (fileSizeInMB > 2) {
        showCustomSnackBar("Image size should be less than 2 MB", isError: true);
        return;
      }

      setState(() {
        _selectedImage = image;
      });
      widget.onImageSelected(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Profile Picture",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImage,
          child: DottedBorder(
            borderType: BorderType.RRect,
            dashPattern: [6, 3],
            strokeWidth: 1.5,
            color: Colors.grey,
            radius: const Radius.circular(8),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(File(_selectedImage!.path),
                    fit: BoxFit.cover, width: double.infinity),
              )
                  : (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty)
                  ? isLocalFile(widget.initialImageUrl!)
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(File(widget.initialImageUrl!),
                    fit: BoxFit.cover, width: double.infinity),
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(widget.initialImageUrl!,
                    fit: BoxFit.cover, width: double.infinity),
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  const Icon(Icons.add_photo_alternate, size: 32, color: Colors.grey),
                  const SizedBox(height: 8),
                  const Text("Upload Image", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}