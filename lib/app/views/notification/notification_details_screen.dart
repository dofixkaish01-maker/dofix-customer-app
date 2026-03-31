import 'package:flutter/material.dart';
import '../../../widgets/awtar_magic/magicial_awatar.dart';
import '../../widgets/custom_appbar.dart';

class NotificationDetailScreen extends StatelessWidget {
  final dynamic item;

  const NotificationDetailScreen({
    super.key,
    required this.item,
  });

  String formatDate(String? date) {
    if (date == null) return '';
    try {
      final d = DateTime.parse(date).toLocal();
      return '${d.day}/${d.month}/${d.year} • ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return date;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
      title: "Notifications Details",
      isBackButtonExist: true,
      isSearchButtonExist: false,
      isCartButtonExist: false,
      isAddressExist: false,
      showNotificationIcon: false,
    ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Avatar + Title Row
            Row(
              children: [
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
                Expanded(
                  child: Text(
                    item.title ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ///Date
            Text(
              formatDate(item.created_at),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 16),

            Divider(color: Colors.grey.shade300),

            const SizedBox(height: 16),

            ///Message Body
            Text(
              item.body ?? '',
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}