import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../utils/dimensions.dart';
import '../../utils/sizeboxes.dart';
import '../../utils/styles.dart';
import '../../utils/theme.dart';
import '../search_screen/search_screen.dart';

class AnimatedSearchBarReadonly extends StatefulWidget {
  const AnimatedSearchBarReadonly({super.key});

  @override
  State<AnimatedSearchBarReadonly> createState() =>
      _AnimatedSearchBarReadonlyState();
}

class _AnimatedSearchBarReadonlyState extends State<AnimatedSearchBarReadonly>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  final List<String> hints = const [
    "Search Service",
    "Search \"AC Repair\"",
    "Search \"Plumber\"",
    "Search \"Electrician\"",
  ];

  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    _ctrl.forward();

    _timer = Timer.periodic(const Duration(seconds: 2), (_) async {
      await _ctrl.reverse();
      if (!mounted) return;
      setState(() => _index = (_index + 1) % hints.length);
      await _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(() => SearchScreen());
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 40,
        padding:
        const EdgeInsets.symmetric(horizontal: Dimensions.paddingSize10),
        decoration: BoxDecoration(
          color: primaryColorDuskyWhite,
          borderRadius: BorderRadius.circular(Dimensions.radius5),
        ),
        child: Row(
          children: [
            Icon(
              CupertinoIcons.search,
              color: Theme.of(context).hintColor,
            ),
            sizedBoxW10(),

            Expanded(
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Text(
                    hints[_index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: albertSansRegular.copyWith(
                      fontSize: Dimensions.fontSize12,
                      fontWeight: FontWeight.w300,
                      color: Theme.of(context).hintColor,
                    ),
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