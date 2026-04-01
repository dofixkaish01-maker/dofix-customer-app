import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../../../controllers/dashboard_controller.dart';
import '../../../utils/theme.dart' as colors;
import '../../widgets/coustom_notification_card.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/shimmer_notification.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final DashBoardController controller = Get.find();

  @override
  void initState() {
    super.initState();
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
      body: Obx(() {
        if (controller.isNotificationLoading.value) {
          return NotificationShimmer();
        }

        final notifications =
            controller.notificationModel.value.content ?? [];

        if (notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.notifications_none_rounded,
                    size: 60, color: Colors.grey),
                const SizedBox(height: 12),
                Text(
                  'No notifications yet',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchNotifications,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (_, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: NotificationCard(
                  item: notifications[index],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
