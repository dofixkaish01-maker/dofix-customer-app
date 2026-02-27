import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'faq_support_screen.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const Color primaryColor = Color(0xff337ba1);

  @override
  Widget build(BuildContext context) {
    const supportNumber = "8383849293";
    const supportEmail = 'support@dofix.in';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Help & Support"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _supportHeaderCard(),
            const SizedBox(height: 14),
            _sectionCard(
              children: [
                _tile(
                  "FAQ",
                  subtitle: "Common questions & answers",
                  icon: const Icon(CupertinoIcons.question_circle,
                      color: primaryColor),
                  onTap: () {
                    Get.to(() => const PartnerFaqScreen());
                  },
                ),
                _divider(),
                _tile(
                  "Live Chat",
                  subtitle: "Chat with support team",
                  icon: const Icon(CupertinoIcons.chat_bubble_text,
                      color: primaryColor),
                  onTap: () async {
                    final Uri url = Uri.parse(
                        "https://text.at/09133dbb-5961-4ba6-b473-e3a28e8fc994");

                    await launchUrl(
                      url,
                      mode: LaunchMode.inAppWebView,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),
            _sectionCard(
              children: [
                // WhatsApp Support
                _tile("WhatsApp Support",
                    subtitle: "Chat with our support team", onTap: () async {
                  final message = """
                        Hello DoFix Support Team,
                        
                        I hope you are doing well.
                        
                        I am contacting you for assistance regarding my account, booking, or service.
                        
                        My Details:
                        • Full Name: 
                        • Registered Mobile Number: 
                        • Email (if applicable): 
                        • Service / Category: 
                        • Booking ID (if any): 
                        • Preferred Date / Time (if relevant): 
                        • Device / App Version (optional): 
                        
                        Issue / Request Description:
                        (Please describe your problem, request, or feedback in detail here)
                        
                        Additional Information:
                        (Any screenshots, order references, or relevant notes can be added here)
                        
                        I would greatly appreciate your prompt support in resolving this issue.
                        
                        Thank you,
                        Customer
                        """;
                  // Properly encode message
                  final encodedMessage = Uri.encodeComponent(message);

                  // Construct URL
                  final url =
                      "https://wa.me/91$supportNumber?text=$encodedMessage";

                  final uri = Uri.parse(url);

                  if (await canLaunchUrl(uri)) {
                    await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    Get.snackbar(
                      "Error",
                      "WhatsApp app nahi khul pa rahi hai. Please check your app.",
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.red.withOpacity(0.8),
                      colorText: Colors.white,
                    );
                  }
                }, icon: Icon(Icons.chat, color: Colors.teal)),
                _divider(),
                _tile(
                  "Call Support",
                  subtitle: "Talk to our support",
                  icon: const Icon(Icons.call, color: primaryColor),
                  onTap: () async {
                    final uri = Uri.parse("tel:+91$supportNumber");
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                ),
                _divider(),
                _tile(
                  "Email Support",
                  subtitle: "Write to us for help",
                  icon: const Icon(Icons.email_outlined, color: primaryColor),
                  onTap: () async {
                    final subject = Uri.encodeComponent(
                      'Customer Support Request - DoFix App',
                    );

                    final body = Uri.encodeComponent(
                      'Hello DoFix Support Team,\n\n'
                      'I hope you are doing well.\n\n'
                      'I need assistance with the following issue:\n'
                      '(Please describe your problem here)\n\n'
                      '--- Details ---\n'
                      '• Name: \n'
                      '• Registered Mobile Number: \n'
                      '• Service/Category: \n'
                      '• Booking ID (if any): \n\n'
                      'I would appreciate your quick support in resolving this issue.\n\n'
                      'Thank you,\n'
                      'Customer',
                    );

                    final uri = Uri.parse(
                      'mailto:$supportEmail?subject=$subject&body=$body',
                    );

                    final ok = await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );

                    if (!ok) {
                      Get.snackbar("Error", "Email app open nahi ho pa rahi");
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Widgets ----------

  Widget _supportHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryColor.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.support_agent, color: primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Need help?",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "We’re here to help you. Usually we respond quickly during working hours.",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _tile(
    String title, {
    required VoidCallback onTap,
    required Icon icon,
    String? subtitle,
  }) {
    return ListTile(
      onTap: onTap,
      leading: icon,
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle,
              style: const TextStyle(fontSize: 12.5, color: Colors.black54),
            ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
    );
  }

  Widget _divider() => Divider(
        height: 1,
        thickness: 1,
        color: Colors.black.withOpacity(0.06),
      );
}
