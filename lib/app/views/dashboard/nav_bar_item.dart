import 'package:do_fix/utils/dimensions.dart';
import 'package:do_fix/utils/styles.dart';
import 'package:flutter/material.dart';


class BottomNavItem extends StatelessWidget {
  final String img;
  final Function? tap;
  final bool isSelected;
  final String title;


  const BottomNavItem({super.key, required this.img, this.tap, this.isSelected = false, required this.title,});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child:  GestureDetector(
            onTap:tap as void Function()?,
            child: SingleChildScrollView(
              child: Container(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
                  child: Column(
                    children: [
                      Image.asset(img,height: 28,width: 28,color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.30)),
                      Text(title,style: albertSansRegular.copyWith(fontSize: Dimensions.fontSize12,color:isSelected ? Theme.of(context).primaryColor : Theme.of(context).disabledColor.withOpacity(0.30) ),)
                    ],
                  )),
            ))
    );
  }
}
