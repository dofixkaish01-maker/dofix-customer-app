import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class ReferEarnScreen extends StatelessWidget {
  const ReferEarnScreen({super.key});

  final String referralCode = "AMRIT123";
  final String referralLink = "https://dofix.in/app?ref=AMRIT123";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         backgroundColor: Color(0xff227FA8),
        title: const Text("Refer & Earn"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Banner Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xff227FA8), Color(0xff5c9cbc)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Invite friends.\nEarn ₹150.",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Share DoFix with your friends. "
                        "They get a discount on their first service "
                        "and you earn rewards after completion.",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            ///  Referral Link Box
            Text(
              "Your Referral Link",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      referralLink,
                      style: const TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: referralLink),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Referral link copied")),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// Share Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(Color(0xff227FA8))),
                onPressed: () {
                  final box = context.findRenderObject() as RenderBox?;

                  Share.share(
                    "Hey! Try DoFix for home services. "
                        "Use my referral link and get a discount \n$referralLink",
                    sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text("Share with Friends"),
              ),
            ),

            const SizedBox(height: 32),

            ///  How it works
            Text(
              "How Refer & Earn Works",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            _howItWorksTile(
              "1",
              "Share your referral link",
              "Send your unique referral link to friends via WhatsApp or any app.",
            ),
            _howItWorksTile(
              "2",
              "Friend books a service",
              "Your friend signs up and completes their first service.",
            ),
            _howItWorksTile(
              "3",
              "You earn ₹150",
              "Reward is added to your wallet after service completion.",
            ),

            const SizedBox(height: 24),

            ///  Terms
            Text(
              "Reward Conditions",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            const Text("• Valid only on first successful service"),
            const Text("• Reward credited after service completion"),
            const Text("• Cancelled bookings are not eligible"),
            const Text("• Rewards are non-transferable"),

            const SizedBox(height: 16),

            const Text(
              "Rewards are subject to verification and company policy. "
                  "DoFix reserves the right to modify or discontinue the referral program.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _howItWorksTile(String step, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Color(0xff227FA8),
            child: Text(
              step,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
