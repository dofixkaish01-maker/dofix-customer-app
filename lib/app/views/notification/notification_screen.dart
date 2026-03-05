import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../utils/images.dart';
import '../../widgets/coustom_notification_card.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/shimmer_notification.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late DashBoardController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<DashBoardController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: CustomAppBar(
        title: "Notifications",
        isBackButtonExist: true,
        isSearchButtonExist: false,
        isCartButtonExist: false,
        isAddressExist: false,
        showNotificationIcon: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Obx(() {
            /// Loading
            if (controller.isNotificationLoading.value) {
              return NotificationShimmer();
            }
            final notifications =
                controller.notificationModel.value.content ?? [];

            /// Empty State
            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.notifications_none_rounded,
                      size: 60,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No notifications yet',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              );
            }

            /// Notification List
            return RefreshIndicator(
              onRefresh: controller.fetchNotifications,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final item = notifications[index];
                  return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: NotificationCard(
                        item: item,
                      ));
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}
