import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationDetailScreen extends StatefulWidget {
  final dynamic item;

  const NotificationDetailScreen({
    super.key,
    required this.item,
  });

  @override
  State<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState
    extends State<NotificationDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          /// 🔵 HEADER (GRADIENT)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff3683ab), Color(0xff5fa8d3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child:
                      const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Spacer(),
                    const Text(
                      "Notification",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 25),

                /// ICON
                Hero(
                  tag: 'notification_icon_${widget.item.id}',
                  child: Container(
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 🟡 CONTENT
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      /// FLOATING CARD
                      Transform.translate(
                        offset: const Offset(0, -30),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              /// DATE CHIP
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color:
                                  const Color(0xff3683ab).withOpacity(0.1),
                                  borderRadius:
                                  BorderRadius.circular(20),
                                ),
                                child: Text(
                                  formatDate(
                                      widget.item.created_at),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xff3683ab),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              /// TITLE
                              Text(
                                widget.item.title ?? '',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Divider(
                                  color: Colors.grey.shade300),

                              const SizedBox(height: 12),

                              /// BODY
                              Text(
                                widget.item.body ?? '',
                                style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.6,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      /// BUTTON
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 6,
                              backgroundColor:
                              const Color(0xff3683ab),
                              padding:
                              const EdgeInsets.symmetric(
                                  vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () => Get.back(),
                            child: const Text(
                              "Got it",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}