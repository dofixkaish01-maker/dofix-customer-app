import 'dart:async';
import 'package:do_fix/controllers/dashboard_controller.dart';
import 'package:do_fix/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_nav_bar.dart';

class DashboardScreen extends StatefulWidget {
  final int pageIndex;
  static final GlobalKey<DashboardScreenState> globalKey = GlobalKey();

  DashboardScreen({
    Key? key,
    required this.pageIndex,
  }) : super(
          key: key ?? globalKey,
        );

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  PageController? _pageController;
  int _pageIndex = 0;
  DateTime? _lastBackPressed;

  @override
  void initState() {
    super.initState();

    _pageIndex = widget.pageIndex;

    _pageController = PageController(initialPage: widget.pageIndex);

    currentPage = widget.pageIndex;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<DashBoardController>().handleLocationPermission(context);
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashBoardController>(builder: (controller) {
      return WillPopScope(
        onWillPop: () async {
          if (_pageIndex != 0) {
            print("Page Index: ---------------------------$_pageIndex");
            setPage(0);
            return false;
          } else {
            print("Page Index: in else ---------------------------$_pageIndex");
            DateTime now = DateTime.now();
            if (_lastBackPressed == null ||
                now.difference(_lastBackPressed!) > Duration(seconds: 2)) {
              _lastBackPressed = now;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Press back again to exit')),
              );
              return false;
            }
            return true;
          }
        },
        child: SafeArea(
          top: false,
          child: Scaffold(
            extendBody: true,
            resizeToAvoidBottomInset: false,
            appBar: CustomAppBar(
              title: currentPage == 3 ? 'Account' : 'Booking History',
              drawerButton: Image.asset(
                Images.iclogo,
                height: 70,
                width: 70,
              ),
              isSearchButtonExist:
                  (currentPage == 0 || currentPage == 1) ? true : false,
              showTitle: (currentPage == 3 || currentPage == 2),
            ),
            bottomNavigationBar: !GetPlatform.isMobile
                ? const SizedBox()
                : CustomBottomNavBar(
                    currentIndex: currentPage,
                    onTap: (index) {
                      print("Index: ---------------------------$index");
                      setPage(index);
                    },
                  ),
            body: PageView.builder(
              controller: _pageController,
              itemCount: controller.screens.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return controller.screens[index];
              },
            ),
          ),
        ),
      );
    });
  }

  int currentPage = 0;

  void setPage(int pageIndex) {
    setState(() {
      _pageController!.jumpToPage(pageIndex);
      _pageIndex = pageIndex;
      currentPage = pageIndex;
    });
    print("PageIndex setPage out: ---------------------------$pageIndex");
    // Removed getFeaturedCategories call as it's already called in the background
    // if (pageIndex == 0) {
    //   Get.find<DashBoardController>().getFeaturedCategories("6", "1");
    //   print("PageIndex setPage: ---------------------------$pageIndex");
    // }
    if (pageIndex == 1) {
      Get.find<DashBoardController>().getData("12", "1", true);
      Get.find<DashBoardController>().getTopRated("20", "1", true);
      Get.find<DashBoardController>().getQuickRepair("20", "1", true);
    }
  }
}
