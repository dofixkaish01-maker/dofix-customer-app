import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import '../../../../controllers/dashboard_controller.dart';
import '../../../../helper/route_helper.dart';
import '../../../../model/service_model.dart';

class AddExtraServiceSheet extends StatefulWidget {
  final ServiceModel service;
  final String? variantKey;

  const AddExtraServiceSheet({
    required this.service,
    this.variantKey,
  });

  @override
  State<AddExtraServiceSheet> createState() => _AddExtraServiceSheetState();
}

class _AddExtraServiceSheetState extends State<AddExtraServiceSheet> {
  final Map<int, bool> selectedVariations = {};
  bool isAdding = false;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.85,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Extra Services',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            const SizedBox(height: 12),

            /// ================= VARIATIONS LIST =================
            Expanded(
              child: widget.service.variations != null &&
                      widget.service.variations!.isNotEmpty
                  ? ListView.separated(
                      itemCount: widget.service.variations!.length,
                      separatorBuilder: (_, __) =>
                          Divider(color: Colors.grey[300]),
                      itemBuilder: (context, index) {
                        final v = widget.service.variations![index];
                        final isSelected = selectedVariations[v.id] ?? false;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedVariations[v.id] = !isSelected;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  activeColor: Color(0xff227FA8),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedVariations[v.id] = value!;
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${v.variant}  •  ₹${v.price}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (v.varDescription != null &&
                                          v.varDescription!.isNotEmpty &&
                                          v.varDescription != '0')
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: Text(
                                            v.varDescription!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        "No extra services available",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
            ),

            /// ================= ADD BUTTON =================
            Row(
              children: [
                /// ⏭ SKIP & CONTINUE
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xff227FA8)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isAdding
                    ? null
                        : () async {
                    setState(() => isAdding = true);

                    final dashboardController = Get.find<DashBoardController>();

                    await dashboardController.addToCart(
                    {
                    "service_id": widget.service.id,
                    "category_id": widget.service.categoryId,
                    "sub_category_id": widget.service.subCategoryId,
                    "quantity": "1",
                    },
                    widget.variantKey != null ? [widget.variantKey!] : [],
                    );

                    if (mounted) Navigator.pop(context);

                    Get.offNamed(
                    RouteHelper.getDashboardRoute(),
                    arguments: {"pageIndex": 2},
                    );
                    },
                    child: const Text(
                      "Skip & Continue",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xff227FA8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                /// ➕ ADD / ADD ALL
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff227FA8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    /// 🔒 disable condition
                    onPressed: isAdding ||
                        selectedVariations.values.where((v) => v).isEmpty
                        ? null
                        : () async {
                      setState(() => isAdding = true);

                      final selected = widget.service.variations!
                          .where((v) => selectedVariations[v.id] == true)
                          .toList();

                      final dashboardController =
                      Get.find<DashBoardController>();

                      await dashboardController.addToCart(
                        {
                          "service_id": widget.service.id,
                          "category_id": widget.service.categoryId,
                          "sub_category_id": widget.service.subCategoryId,
                          "quantity": "1",
                          "extras": selected.map((v) => v.toJson()).toList(),
                        },
                        widget.variantKey != null ? [widget.variantKey!] : [],
                      );

                      Get.toNamed(
                        RouteHelper.getDashboardRoute(),
                        arguments: {"pageIndex": 2},
                      );
                      setState(() => isAdding = false);
                    },

                    /// 🔄 loading UI
                    child: isAdding
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      selectedVariations.values.where((v) => v).length ==
                          widget.service.variations!.length
                          ? "Add All (${selectedVariations.values.where((v) => v).length})"
                          : "Add (${selectedVariations.values.where((v) => v).length})",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
