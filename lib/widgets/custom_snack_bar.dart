import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';

void showCustomSnackBar(String? message, {bool isError = true, bool isPending = false, bool isSuccess = false}) {
 Get.snackbar(
   margin: EdgeInsets.all(17),
   isPending?"Pending": isError ? "Error" : "Success",
   dismissDirection: DismissDirection.horizontal,
   message ?? "",
   snackPosition: SnackPosition.TOP,
     boxShadows: [
       BoxShadow(
         color: Colors.black.withOpacity(0.2),
         spreadRadius: 3,
         blurRadius: 6,
         offset: Offset(0, 4), // changes position of shadow
       ),
     ],
   backgroundColor: isSuccess?Colors.green.withOpacity(0.7):isPending?Color(0xFFBA7270).withOpacity(0.7):isError ? Colors.red.withOpacity(0.7) : Colors.white.withOpacity(0.7),
   colorText: isError ?Colors.white.withOpacity(0.8):Colors.black,
 );
}

void closeSnackBarIfActive() {
  if (Get.isSnackbarOpen) {
    Get.closeAllSnackbars();
  }
}