import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddMoreServiceBottomSheet extends StatelessWidget {
  const AddMoreServiceBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const Text(
              "Add more services",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            _serviceTile(
              title: "AC Repair",
              subtitle: "Cooling / noise issue",
              onTap: () {
                Get.back(); // close bottom sheet
                // TODO: navigate to AC service list
              },
            ),

            _serviceTile(
              title: "AC Gas Refill",
              subtitle: "Low cooling",
              onTap: () {
                Get.back();
              },
            ),

            _serviceTile(
              title: "Deep Cleaning",
              subtitle: "Full indoor & outdoor",
              onTap: () {
                Get.back();
              },
            ),

            const SizedBox(height: 8),

            Divider(color: Colors.grey.shade300),

            const SizedBox(height: 8),

            // View all services
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Get.back();
                  // TODO: navigate to main service category screen
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF207FA7)),
                ),
                child: const Text(
                  "View all services",
                  style: TextStyle(
                    color: Color(0xFF207FA7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _serviceTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: onTap,
    );
  }
}
