import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import '../../../controllers/booking_controller.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../widgets/custom_appbar.dart';
import '../home/component/get_rate_card_screen.dart';

class DetailsScreen extends StatefulWidget {
  final dynamic serviceModel;
  final String variationName;
  final String rating;
  final String coverImage;
  final String reviewCount;
  final String mrpPrice;
  final String discountedPrice;
  final String duration;
  final String description;
  final String variantKey;

  DetailsScreen({
    super.key,
    required this.serviceModel,
    required this.variationName,
    required this.rating,
    required this.coverImage,
    required this.reviewCount,
    required this.mrpPrice,
    required this.discountedPrice,
    required this.duration,
    required this.description,
    required this.variantKey,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final bookController = Get.find<BookingController>();
  String coverVariantImagePath = "https://panel.dofix.in/storage/service/variant/";

  // ------------------- UI helpers (no logic change) -------------------
  bool _isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 600;

  bool _isWide(BuildContext context) => MediaQuery.of(context).size.width >= 900;

  double _pad(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w >= 900) return 24;
    if (w >= 600) return 18;
    return 16;
  }

  double _headerHeight(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    // Responsive header height
    if (w >= 900) return h * 0.38;
    if (w >= 600) return h * 0.34;
    return h * 0.30;
  }

  @override
  Widget build(BuildContext context) {
    /// Percentage Calculation (KEEP)
    double mrp = double.tryParse(widget.mrpPrice) ?? 0;
    double discountPrice = double.tryParse(widget.discountedPrice) ?? 0;

    int percentOff = 0;
    if (mrp > 0) {
      percentOff = (((mrp - discountPrice) / mrp) * 100).round();
    }

    final bool isTablet = _isTablet(context);
    final bool isWide = _isWide(context);
    final double pagePad = _pad(context);
    final double headerH = _headerHeight(context);

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: CustomAppBar(
        title: "Service Details",
        isBackButtonExist: true,
        isSearchButtonExist: false,
        isCartButtonExist: true,
        showNotificationIcon: false,
      ),
      body: Stack(
        children: [
          /// ✅ REPLACE ONLY THIS PART INSIDE Stack children:
          /// 1) "SingleChildScrollView(...)"  (MAIN SCROLL AREA)
          /// (Bottom bar wala code as-it-is rehne do — logic untouched)

          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 130),
            child: LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                final bool isTablet = w >= 600;
                final bool isWide = w >= 900;

                final double pagePad = isWide ? 24 : (isTablet ? 18 : 16);
                final double maxW = isWide ? 860 : double.infinity;

                final double headerH = isWide
                    ? MediaQuery.of(context).size.height * 0.40
                    : (isTablet
                    ? MediaQuery.of(context).size.height * 0.34
                    : MediaQuery.of(context).size.height * 0.30);

                Widget sectionTitle(String t) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    t,
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.black.withOpacity(0.92),
                    ),
                  ),
                );

                Widget card({required Widget child}) => Container(
                  padding: EdgeInsets.all(isTablet ? 18 : 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: child,
                );

                Widget chip({
                  required Widget child,
                  Color? bg,
                  Border? border,
                }) =>
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: bg ?? Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(999),
                        border: border,
                      ),
                      child: child,
                    );

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxW),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// ===================== PREMIUM HERO HEADER =====================
                        Padding(
                          padding: EdgeInsets.fromLTRB(pagePad, 12, pagePad, 0),
                          child: Container(
                            height: headerH,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.14),
                                  blurRadius: 26,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: Image.network(
                                      coverVariantImagePath + widget.coverImage,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        color: Colors.grey.shade200,
                                        child: const Center(
                                          child: Icon(Icons.image, size: 44),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // soft gradient for text legibility
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.05),
                                            Colors.black.withOpacity(0.65),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Top chips: rating + discount
                                  // Top chips: rating + discount
                                  Positioned(
                                    left: 14,
                                    top: 14,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (widget.rating != "0")
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.55), // transparent bg
                                              borderRadius: BorderRadius.circular(50),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.star,
                                                    size: 14, color: Colors.amber),
                                                const SizedBox(width: 4),
                                                Text(
                                                  widget.rating,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  "(${widget.reviewCount})",
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.9),
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        const SizedBox(width: 8),
                                      ],
                                    ),
                                  ),

                                  // Title + quick meta
                                  Positioned(
                                    left: 16,
                                    right: 16,
                                    bottom: 16,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.variationName,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: isTablet ? 24 : 20,
                                            fontWeight: FontWeight.w900,
                                            height: 1.15,
                                          ),
                                        ),
                                        // const SizedBox(height: 10),
                                        // Row(
                                        //   children: [
                                        //     chip(
                                        //       bg: Colors.white.withOpacity(0.92),
                                        //       child: Row(
                                        //         mainAxisSize: MainAxisSize.min,
                                        //         children: [
                                        //           const Icon(Icons.currency_rupee,
                                        //               size: 16, color: Colors.black87),
                                        //           Text(
                                        //             discountedPrice,
                                        //             style: const TextStyle(
                                        //               fontWeight: FontWeight.w900,
                                        //               fontSize: 13,
                                        //             ),
                                        //           ),
                                        //           const SizedBox(width: 6),
                                        //           Text(
                                        //             "₹$mrpPrice",
                                        //             style: TextStyle(
                                        //               fontSize: 12,
                                        //               color: Colors.black.withOpacity(0.55),
                                        //               decoration:
                                        //               TextDecoration.lineThrough,
                                        //               fontWeight: FontWeight.w700,
                                        //             ),
                                        //           ),
                                        //         ],
                                        //       ),
                                        //     ),
                                        //     const SizedBox(width: 8),
                                        //     if (duration.isNotEmpty)
                                        //       chip(
                                        //         bg: Colors.white.withOpacity(0.92),
                                        //         child: Row(
                                        //           mainAxisSize: MainAxisSize.min,
                                        //           children: [
                                        //             const Icon(Icons.access_time,
                                        //                 size: 16, color: Colors.black87),
                                        //             const SizedBox(width: 6),
                                        //             Text(
                                        //               duration,
                                        //               style: const TextStyle(
                                        //                 fontWeight: FontWeight.w800,
                                        //                 fontSize: 12,
                                        //               ),
                                        //             ),
                                        //           ],
                                        //         ),
                                        //       ),
                                        //   ],
                                        // ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// ===================== CONTENT =====================
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: pagePad),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// ===== Rating detail card (KEEP condition)
                              // if (rating != "0") ...[
                              //   card(
                              //     child: Row(
                              //       children: [
                              //         // stars (KEEP same logic)
                              //         Row(
                              //           children: List.generate(5, (index) {
                              //             double ratingValue =
                              //                 double.tryParse(rating) ?? 0.0;
                              //
                              //             if (index < ratingValue.floor()) {
                              //               return const Icon(Icons.star,
                              //                   color: Colors.amber, size: 20);
                              //             } else if (index < ratingValue &&
                              //                 index + 1 > ratingValue) {
                              //               return const Icon(Icons.star_half,
                              //                   color: Colors.amber, size: 20);
                              //             } else {
                              //               return const Icon(Icons.star_border,
                              //                   color: Colors.amber, size: 20);
                              //             }
                              //           }),
                              //         ),
                              //         const SizedBox(width: 10),
                              //         Text(
                              //           rating,
                              //           style: TextStyle(
                              //             fontSize: isTablet ? 16 : 15,
                              //             fontWeight: FontWeight.w900,
                              //           ),
                              //         ),
                              //         const SizedBox(width: 8),
                              //         Container(
                              //           padding: const EdgeInsets.symmetric(
                              //               horizontal: 10, vertical: 6),
                              //           decoration: BoxDecoration(
                              //             color: Colors.grey.shade100,
                              //             borderRadius: BorderRadius.circular(12),
                              //           ),
                              //           child: Text(
                              //             "$reviewCount Reviews",
                              //             style: TextStyle(
                              //               fontSize: 12,
                              //               color: Colors.grey.shade700,
                              //               fontWeight: FontWeight.w700,
                              //             ),
                              //           ),
                              //         ),
                              //         const Spacer(),
                              //         const Icon(Icons.verified,
                              //             color: Colors.green, size: 18),
                              //       ],
                              //     ),
                              //   ),
                              //   const SizedBox(height: 14),
                              // ],

                              /// ===== Price card (PREMIUM + You save included ✅)
                              sectionTitle("Price & Duration"),
                              card(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "₹${widget.discountedPrice}",
                                          style: TextStyle(
                                            fontSize: isTablet ? 30 : 28,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "₹${widget.mrpPrice}",
                                          style: const TextStyle(
                                            decoration: TextDecoration.lineThrough,
                                            color: Colors.grey,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        if (percentOff > 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xff3683ab),
                                              borderRadius: BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              "$percentOff% OFF",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ),
                                        const Spacer(),
                                        if (widget.duration.isNotEmpty)
                                          Row(
                                            children: [
                                              const Icon(Icons.access_time,
                                                  size: 18, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Text(
                                                widget.duration,
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // ✅ YOU SAVE (KEEP condition percentOff > 0)
                                    if (percentOff > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: Colors.green.withOpacity(0.25),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.savings_rounded,
                                                size: 20, color: Colors.green),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                "You save ₹${(mrp - discountPrice).toStringAsFixed(0)} on this service",
                                                style: const TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 18),

                              /// ===== About
                              sectionTitle("About this service"),
                               Text(
                                  widget.description,
                                  style: TextStyle(
                                    height: 1.65,
                                    fontSize: isTablet ? 14 : 13,
                                    color: Colors.black.withOpacity(0.78),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),

                              const SizedBox(height: 18),

                              /// ===== Helpful info / trust row (UI only)
                              card(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 36,
                                            width: 36,
                                            decoration: BoxDecoration(
                                              color:
                                              const Color(0xff3683ab).withOpacity(0.10),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(Icons.security_rounded,
                                                color: Color(0xff3683ab), size: 20),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              "Verified professionals & quality service",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black.withOpacity(0.85),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            height: 36,
                                            width: 36,
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(0.10),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Icon(Icons.timer_rounded,
                                                color: Colors.green, size: 20),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              "On-time service updates",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black.withOpacity(0.85),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),

                              sectionTitle("Reviews"),
                              const SizedBox(height: 12),

                              Obx(() {
                                final reviewList =
                                    bookController.reviewRatingModel.value?.content?[0].reviews ?? [];

                                if (reviewList.isEmpty) {
                                  return Text(
                                    "No reviews available",
                                    style: TextStyle(color: Colors.grey.shade600),
                                  );
                                }

                                final limitedReviews =
                                reviewList.length > 10 ? reviewList.sublist(0, 10) : reviewList;

                                String safeUserLabel(dynamic r) {
                                  final readable = (r.readableId ?? "").toString().trim();
                                  if (readable.isNotEmpty) return readable;

                                  final cid = (r.customerId ?? "").toString().trim();
                                  if (cid.isNotEmpty) {
                                    return cid.length > 8 ? "User • ${cid.substring(0, 8)}" : "User • $cid";
                                  }
                                  return "User";
                                }

                                String safeInitial(String label) {
                                  final t = label.trim();
                                  if (t.isEmpty) return "U";
                                  return t[0].toUpperCase();
                                }

                                String formatDate(dynamic d) {
                                  if (d == null) return "";
                                  try {
                                    final dt = d as DateTime;
                                    return "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}";
                                  } catch (_) {
                                    return "";
                                  }
                                }

                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.black.withOpacity(0.06)),
                                  ),
                                  child: Column(
                                    children: List.generate(limitedReviews.length, (index) {
                                      final review = limitedReviews[index];

                                      final label = safeUserLabel(review);
                                      final initial = safeInitial(label);

                                      final int ratingValue = (review.reviewRating is int)
                                          ? (review.reviewRating as int)
                                          : int.tryParse(review.reviewRating?.toString() ?? "0") ?? 0;

                                      final comment = (review.reviewComment ?? "").toString();
                                      final dateText = formatDate(review.createdAt);

                                      return Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                /// Top row: avatar + name/date + rating
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 18,
                                                      backgroundColor:
                                                      const Color(0xff3683ab).withOpacity(0.12),
                                                      child: Text(
                                                        initial,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w800,
                                                          color: Color(0xff3683ab),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),

                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            label,
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: const TextStyle(
                                                              fontWeight: FontWeight.w700,
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                          if (dateText.isNotEmpty)
                                                            Padding(
                                                              padding: const EdgeInsets.only(top: 2),
                                                              child: Text(
                                                                dateText,
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors.black.withOpacity(0.55),
                                                                  fontWeight: FontWeight.w500,
                                                                ),
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),

                                                    /// Rating pill (Urban type)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                          horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green.withOpacity(0.10),
                                                        borderRadius: BorderRadius.circular(10),
                                                        border: Border.all(
                                                          color: Colors.green.withOpacity(0.25),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          const Icon(Icons.star,
                                                              size: 14, color: Colors.green),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            ratingValue.toString(),
                                                            style: const TextStyle(
                                                              fontWeight: FontWeight.w800,
                                                              color: Colors.green,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                /// Comment
                                                const SizedBox(height: 10),
                                                Text(
                                                  comment.isNotEmpty ? comment : "No comment",
                                                  style: TextStyle(
                                                    height: 1.5,
                                                    fontSize: 13,
                                                    color: Colors.black.withOpacity(
                                                        comment.isNotEmpty ? 0.78 : 0.45),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          /// Divider between items (Urban style)
                                          if (index != limitedReviews.length - 1)
                                            Divider(
                                              height: 1,
                                              thickness: 1,
                                              color: Colors.black.withOpacity(0.06),
                                            ),
                                        ],
                                      );
                                    }),
                                  ),
                                );
                              }),

                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          /// BOTTOM ADD / REMOVE BUTTON (KEEP logic/conditions)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.only(top: 8, left: 15, right: 15, bottom: 10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10),
                  ],
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isWide ? 820 : double.infinity,
                    ),
                    child: GetBuilder<DashBoardController>(
                      id: 'cart_${widget.serviceModel.id}_${widget.variantKey}',
                      builder: (controller) {
                        bool isInCart = false;

                        if (controller.cartModel.content?.cart?.data != null) {
                          for (var item in controller.cartModel.content!.cart!.data!) {
                            if (item.serviceId == widget.serviceModel.id && item.variantKey == widget.variantKey) {
                              isInCart = true;
                              break;
                            }
                          }
                        }

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            /// ADD / REMOVE BUTTON
                            SizedBox(
                              width: double.infinity,
                              height: isTablet ? 50 : 46,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isInCart ? Colors.red : const Color(0xff3683ab),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 0,
                                ),
                                onPressed: () async {
                                  if (isInCart) {
                                    /// REMOVE (KEEP)
                                    await controller.removeFromCart(
                                      widget.serviceModel.id,
                                      widget.variantKey,
                                    );

                                    Get.snackbar(
                                      "Cart Update",
                                      "Item removed from cart",
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.redAccent,
                                      colorText: Colors.white,
                                    );
                                  } else {
                                    /// ADD (KEEP)
                                    await controller.addToCart(
                                      {
                                        "service_id": widget.serviceModel.id,
                                        "category_id": widget.serviceModel.categoryId,
                                        "sub_category_id": widget.serviceModel.subCategoryId,
                                        "quantity": "1",
                                        "extras": [],
                                      },
                                      [widget.variantKey],
                                    );
                                    Get.snackbar(
                                      "Cart Update",
                                      "Item added to cart",
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white,
                                    );
                                  }
                                  controller.update(['cart_${widget.serviceModel.id}_${widget.variantKey}']);
                                },
                                child: Text(
                                  isInCart ? "Remove from Cart" : "Add to Cart",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                Get.to(() => GetRateCardScreen(
                                  categoryId: widget.serviceModel.categoryId ?? "",
                                ));
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                                decoration: BoxDecoration(
                                  color: const Color(0xff3683ab).withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color(0xff3683ab).withOpacity(0.30),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.receipt_long_rounded,
                                      size: 18,
                                      color: Color(0xff3683ab),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "View Rate Card",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xff3683ab),
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 14,
                                      color: Color(0xff3683ab),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
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




// import 'package:flutter/material.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:get/get_navigation/src/extension_navigation.dart';
// import 'package:get/get_navigation/src/snackbar/snackbar.dart';
// import 'package:get/get_state_manager/src/simple/get_state.dart';
// import '../../../controllers/dashboard_controller.dart';
// import '../../widgets/custom_appbar.dart';
// import '../home/component/get_rate_card_screen.dart';
//
// class DetailsScreen extends StatelessWidget {
//   final dynamic serviceModel;
//   final String variationName;
//   final String rating;
//   final String coverImage;
//   final String reviewCount;
//   final String mrpPrice;
//   final String discountedPrice;
//   final String duration;
//   final String description;
//   final String variantKey;
//
//   DetailsScreen({
//     super.key,
//     required this.serviceModel,
//     required this.variationName,
//     required this.rating,
//     required this.coverImage,
//     required this.reviewCount,
//     required this.mrpPrice,
//     required this.discountedPrice,
//     required this.duration,
//     required this.description,
//     required this.variantKey,
//   });
//
//   String coverVariantImagePath =
//       "https://panel.dofix.in/storage/service/variant/";
//
//   @override
//   Widget build(BuildContext context) {
//     /// Percentage Calculation
//     double mrp = double.tryParse(mrpPrice) ?? 0;
//     double discountPrice = double.tryParse(discountedPrice) ?? 0;
//
//     int percentOff = 0;
//     if (mrp > 0) {
//       percentOff = (((mrp - discountPrice) / mrp) * 100).round();
//     }
//
//     return Scaffold(
//       backgroundColor: const Color(0xffF5F7FA),
//       appBar: CustomAppBar(
//         title: "Service Details",
//         isBackButtonExist: true,
//         isSearchButtonExist: false,
//         isCartButtonExist: true,
//         showNotificationIcon: false,
//       ),
//       body: Stack(
//         children: [
//           /// MAIN SCROLL AREA
//           SingleChildScrollView(
//             physics: BouncingScrollPhysics(),
//             padding: const EdgeInsets.only(bottom: 110),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 /// PREMIUM IMAGE HEADER
//                 Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                   child: Container(
//                     height: MediaQuery.of(context).size.height * 0.32,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(28),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.15),
//                           blurRadius: 25,
//                           offset: const Offset(0, 15),
//                         ),
//                       ],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(28),
//                       child: Stack(
//                         children: [
//                           Positioned.fill(
//                             child: Image.network(
//                               coverVariantImagePath + coverImage,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                           Positioned.fill(
//                             child: Container(
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   begin: Alignment.topCenter,
//                                   end: Alignment.bottomCenter,
//                                   colors: [
//                                     Colors.transparent,
//                                     Colors.black.withOpacity(0.6),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                           Positioned(
//                             left: 20,
//                             bottom: 20,
//                             right: 20,
//                             child: Text(
//                               variationName,
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 22,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 const SizedBox(height: 10),
//
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       /// PREMIUM RATING CARD
//                       if (rating != "0")
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 14, vertical: 12),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(18),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.05),
//                                 blurRadius: 15,
//                                 offset: const Offset(0, 8),
//                               ),
//                             ],
//                           ),
//                           child: Row(
//                             children: [
//                               Row(
//                                 children: List.generate(5, (index) {
//                                   double ratingValue =
//                                       double.tryParse(rating) ?? 0.0;
//
//                                   if (index < ratingValue.floor()) {
//                                     return const Icon(Icons.star,
//                                         color: Colors.amber, size: 20);
//                                   } else if (index < ratingValue &&
//                                       index + 1 > ratingValue) {
//                                     return const Icon(Icons.star_half,
//                                         color: Colors.amber, size: 20);
//                                   } else {
//                                     return const Icon(Icons.star_border,
//                                         color: Colors.amber, size: 20);
//                                   }
//                                 }),
//                               ),
//                               const SizedBox(width: 10),
//                               Text(
//                                 rating,
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 8, vertical: 4),
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey.shade100,
//                                   borderRadius: BorderRadius.circular(10),
//                                 ),
//                                 child: Text(
//                                   "$reviewCount Reviews",
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey.shade700,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                               const Spacer(),
//                               const Icon(Icons.verified,
//                                   color: Colors.green, size: 18),
//                             ],
//                           ),
//                         ),
//
//                       const SizedBox(height: 10),
//
//                       /// PREMIUM PRICE CARD
//                       Container(
//                         padding: const EdgeInsets.all(18),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(22),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.06),
//                               blurRadius: 20,
//                               offset: const Offset(0, 10),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Text(
//                                   "₹$discountedPrice",
//                                   style: const TextStyle(
//                                     fontSize: 26,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 10),
//                                 Text(
//                                   "₹$mrpPrice",
//                                   style: const TextStyle(
//                                     decoration: TextDecoration.lineThrough,
//                                     color: Colors.grey,
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 if (percentOff > 0)
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 12, vertical: 6),
//                                     decoration: BoxDecoration(
//                                       gradient: const LinearGradient(
//                                         colors: [
//                                           Color(0xff5e838f),
//                                           Color(0xff468aa5),
//                                         ],
//                                       ),
//                                       borderRadius: BorderRadius.circular(20),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.black.withOpacity(0.3),
//                                           blurRadius: 8,
//                                           offset: const Offset(0, 2),
//                                         ),
//                                       ],
//                                     ),
//                                     child: Text(
//                                       "$percentOff% OFF",
//                                       style: const TextStyle(
//                                         color: Colors.white,
//                                         fontSize: 12,
//                                         fontWeight: FontWeight.w700,
//                                         letterSpacing: 0.5,
//                                       ),
//                                     ),
//                                   ),
//                                 const Spacer(),
//                                 if (duration.isNotEmpty)
//                                   Row(
//                                     children: [
//                                       const Icon(Icons.access_time,
//                                           size: 18, color: Colors.grey),
//                                       const SizedBox(width: 4),
//                                       Text(
//                                         duration,
//                                         style: const TextStyle(
//                                           color: Colors.grey,
//                                         ),
//                                       ),
//                                     ],
//                                   )
//                               ],
//                             ),
//                             const SizedBox(height: 8),
//                             if (percentOff > 0)
//                               Text(
//                                 "You save ₹${(mrp - discountPrice).toStringAsFixed(0)} on this service",
//                                 style: const TextStyle(
//                                   color: Colors.green,
//                                   fontWeight: FontWeight.w500,
//                                   fontSize: 13,
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//
//                       const SizedBox(height: 20),
//
//                       const Text(
//                         "About Service",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//
//                       const SizedBox(height: 8),
//
//                       Text(
//                         description,
//                         style: const TextStyle(
//                           height: 1.6,
//                           color: Colors.black87,
//                         ),
//                       ),
//
//                       const SizedBox(height: 40),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           /// BOTTOM ADD / REMOVE BUTTON
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               padding: const EdgeInsets.only(top: 5, left: 15, right: 15),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 10,
//                   )
//                 ],
//               ),
//               child: GetBuilder<DashBoardController>(
//                 id: 'cart_${serviceModel.id}_$variantKey',
//                 builder: (controller) {
//                   bool isInCart = false;
//
//                   if (controller.cartModel.content?.cart?.data != null) {
//                     for (var item
//                         in controller.cartModel.content!.cart!.data!) {
//                       if (item.serviceId == serviceModel.id &&
//                           item.variantKey == variantKey) {
//                         isInCart = true;
//                         break;
//                       }
//                     }
//                   }
//
//                   return Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       /// ADD / REMOVE BUTTON
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor:
//                                 isInCart ? Colors.red : const Color(0xff3683ab),
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(14),
//                             ),
//                           ),
//                           onPressed: () async {
//                             if (isInCart) {
//                               /// REMOVE
//                               await controller.removeFromCart(
//                                 serviceModel.id,
//                                 variantKey,
//                               );
//
//                               Get.snackbar(
//                                 "Cart Update",
//                                 "Item removed from cart",
//                                 snackPosition: SnackPosition.BOTTOM,
//                                 backgroundColor: Colors.redAccent,
//                                 colorText: Colors.white,
//                               );
//                             } else {
//                               /// ADD
//                               await controller.addToCart(
//                                 {
//                                   "service_id": serviceModel.id,
//                                   "category_id": serviceModel.categoryId,
//                                   "sub_category_id": serviceModel.subCategoryId,
//                                   "quantity": "1",
//                                   "extras": [],
//                                 },
//                                 [variantKey],
//                               );
//                               Get.snackbar(
//                                 "Cart Update",
//                                 "Item added to cart",
//                                 snackPosition: SnackPosition.BOTTOM,
//                                 backgroundColor: Colors.green,
//                                 colorText: Colors.white,
//                               );
//                             }
//                             controller.update(
//                                 ['cart_${serviceModel.id}_$variantKey']);
//                           },
//                           child: Text(
//                             isInCart ? "Remove from Cart" : "Add to Cart",
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       InkWell(
//                         borderRadius: BorderRadius.circular(14),
//                         onTap: () {
//                           Get.to(() => GetRateCardScreen(
//                                 categoryId: serviceModel.categoryId ?? "",
//                               ));
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 10, horizontal: 14),
//                           decoration: BoxDecoration(
//                             color: const Color(0xff3683ab).withOpacity(0.08),
//                             borderRadius: BorderRadius.circular(14),
//                             border: Border.all(
//                               color: const Color(0xff3683ab).withOpacity(0.3),
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: const [
//                               Icon(
//                                 Icons.receipt_long_rounded,
//                                 size: 18,
//                                 color: Color(0xff3683ab),
//                               ),
//                               SizedBox(width: 8),
//                               Text(
//                                 "View Rate Card",
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: Color(0xff3683ab),
//                                 ),
//                               ),
//                               SizedBox(width: 6),
//                               Icon(
//                                 Icons.arrow_forward_ios,
//                                 size: 14,
//                                 color: Color(0xff3683ab),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 18),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
