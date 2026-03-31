import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import '../../utils/sizeboxes.dart';
import '../../utils/styles.dart';
import '../../widgets/awtar_magic/magicial_awatar.dart';
import '../views/notification/notification_details_screen.dart';

class NotificationCard extends StatelessWidget {
  final dynamic item;

  const NotificationCard({
    super.key,
    required this.item,
  });
  /// Time formatter (human readable)
  String formatNotificationTime(String? date) {
    if (date == null || date.isEmpty) return '';

    try {
      final DateTime createdTime = DateTime.parse(date).toLocal();
      final Duration diff = DateTime.now().difference(createdTime);

      if (diff.inSeconds < 60) {
        return 'Just now';
      } else if (diff.inMinutes < 60) {
        return '${diff.inMinutes} min ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours} hrs ago';
      } else if (diff.inDays == 1) {
        return 'Yesterday';
      } else if (diff.inDays < 7) {
        return '${diff.inDays} days ago';
      } else {
        return '${createdTime.day}/${createdTime.month}/${createdTime.year}';
      }
    } catch (e) {
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String text = item.title ?? item.body ?? "";
    final bool isUnread = item.isRead == false;
    return InkWell(
      borderRadius: BorderRadius.circular(16),

      /// YAHI PE onTap AATA HAI
      onTap: () {
        Get.to(
              () => NotificationDetailScreen(item: item),
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 300),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Icon
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color:
                getAvatarColor(item.title ?? item.body).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                getInitial(item.title ?? item.body),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: getAvatarColor(item.title ?? ""),
                ),
              ),
            ),
            const SizedBox(width: 12),

            /// Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  Text(
                    item.title ?? '',
                    style: albertSansRegular.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  sizedBox5(),

                  /// Body
                  Text(
                    item.body ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: albertSansRegular.copyWith(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),

                  sizedBox8(),

                  /// Time
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        formatNotificationTime(item.created_at),
                        style: albertSansRegular.copyWith(
                          fontSize: 11,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
