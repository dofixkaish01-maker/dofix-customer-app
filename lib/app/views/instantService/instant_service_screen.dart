import 'package:do_fix/widgets/custom_dot_loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../controllers/dashboard_controller.dart';
import '../services/component/service_category_components.dart';
import 'componenent/instant_service_category_components.dart';

class InstantServiceScreen extends StatefulWidget {
  const InstantServiceScreen({super.key});

  @override
  State<InstantServiceScreen> createState() => _InstantServiceScreenState();
}

class _InstantServiceScreenState extends State<InstantServiceScreen> {

  final DashBoardController dashboard = Get.find<DashBoardController>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await dashboard.fetchAllCategories(limit: "50", offset: "1");
      await dashboard.getData(10, 1);
    });
  }

  Future<void> onRefresh() async {
    await dashboard.getData(10, 1);
    await dashboard.fetchAllCategories(limit: "50", offset: "1");
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),

      body: Obx(() {

        if (dashboard.isAllCategoryLoading.value) {
          return const Center(child: DotWaveLoader());
        }

        return RefreshIndicator(
          onRefresh: onRefresh,

          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HERO INSTANT BANNER - STATIC TEXT FOR ALL SERVICES
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.06),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Row(
                    children: [

                      /// ICON WITH LOTTIE BACKGROUND
                      Container(
                        width: 60,
                        height: 60,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            /// Lottie Animation
                            Lottie.asset(
                              "assets/lottie_animation/instant_icon.json",
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              repeat: true,
                            ),

                            /// Circular Icon Overlay
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.flash_on,
                                color: Colors.orange,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 14),

                      /// TEXT AREA
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            /// Static headline
                            Text(
                              "Instant Services for Your Home",
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),

                            /// Supporting subtext
                            const Text(
                              "Reliable service for all your home needs",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      /// FAST BADGE
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          "FAST",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                /// QUICK ACTIONS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [

                      _quickCard(
                          icon: Icons.bolt,
                          title: "Available Now",
                          color: Colors.green),

                      const SizedBox(width: 10),

                      _quickCard(
                          icon: Icons.timer,
                          title: "30 Min Arrival",
                          color: Colors.orange),

                      const SizedBox(width: 10),

                      _quickCard(
                          icon: Icons.verified,
                          title: "Verified Pros",
                          color: Colors.blue),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // /// CATEGORY TITLE
                // const Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 16),
                //   child: Text(
                //     "Instant Services Near You",
                //     style: TextStyle(
                //         fontSize: 18,
                //         fontWeight: FontWeight.bold),
                //   ),
                // ),

                // const SizedBox(height: 14),

                /// SERVICE CATEGORY GRID
                InstantServiceCategoryComponents(
                  allCategoryModel: dashboard.allCategoryModel,
                  width: MediaQuery.of(context).size.width / 3 - 18,
                  isShowSeeAll: true,
                ),

                const SizedBox(height: 40)
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _quickCard(
      {required IconData icon,
        required String title,
        required Color color}) {

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),

        child: Column(
          children: [

            Icon(icon, color: color),

            const SizedBox(height: 6),

            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      ),
    );
  }
}