import 'package:do_fix/app/widgets/service_container.dart';
import 'package:do_fix/main.dart';
import 'package:do_fix/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../model/booking_model.dart';

class BookingHostoryScreen extends StatefulWidget {
  final VoidCallback? onRefreshNeeded;

  const BookingHostoryScreen({super.key, this.onRefreshNeeded});

  @override
  State<BookingHostoryScreen> createState() => _BookingHostoryScreenState();
}

class _BookingHostoryScreenState extends State<BookingHostoryScreen>
    with TickerProviderStateMixin, RouteAware {
  late List<GlobalKey<AnimatedListState>> _listKeys;
  List<Booking?> _items = [];
  late TabController _tabController;
  bool _isLoading = false;
  int _selectedIndex = 0;

  final List<String> statusList = [
    "all",
    "pending",
    "accepted",
    "ongoing",
    "completed",
    "cancelled"
  ];

  @override
  void didPopNext() {
    fetchDataForTab(statusList[_selectedIndex]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: statusList.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      fetchDataForTab(statusList[_tabController.index]);
    });
    _listKeys =
        List.generate(statusList.length, (_) => GlobalKey<AnimatedListState>());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchDataForTab("all");
    });
  }

  Future<void> fetchDataForTab(String status) async {
    if (status.toLowerCase() == "cancelled") {
      status = "canceled";
    }
    setState(() => _isLoading = true);
    final controller = Get.find<DashBoardController>();

    int toggle = 0;
    for (int i = _items.length - 1; i >= 0; i--) {
      final removedItem = _items.removeAt(i);
      final removeToRight = toggle % 2 == 0;
      toggle++;

      _listKeys[_tabController.index].currentState?.removeItem(
            i,
            (context, animation) => SlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: Offset(removeToRight ? 1.0 : -1.0, 0.0),
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeIn,
              )),
              child: BookingContainer(booking: removedItem),
            ),
            duration: const Duration(milliseconds: 300),
          );
      await Future.delayed(const Duration(milliseconds: 50));
    }
    controller.lastStatus.value = status;
    await controller.getBooking(
      {
        "limit": "100",
        "offset": "1",
        "booking_status": status,
        "service_type": "all"
      },
    );

    final data = controller.bookingModel.data ?? [];
    for (int i = 0; i < data.length; i++) {
      _items.insert(i, data[i]);
      _listKeys[_tabController.index].currentState?.insertItem(i);
      await Future.delayed(const Duration(milliseconds: 100));
    }

    setState(() => _isLoading = false);
  }

  Widget buildListView(int tabIndex) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty) {
      return const Center(child: Text("Oops! No Booking is there"));
    }

    return AnimatedList(
      key: _listKeys[tabIndex],
      initialItemCount: _items.length,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0), // from right
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          )),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black.withOpacity(0.18),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BookingContainer(
                  booking: _items[index],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashBoardController>(
      builder: (controller) {
        return Scaffold(
          body: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 16),
                  Text(
                    "Apply Filters",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Albert Sans',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Spacer(),
                  Theme(
                    data: Theme.of(context).copyWith(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent
                    ),
                      child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedIndex,
                        elevation: 0,dropdownColor: Colors.grey.shade100,
                        icon: SizedBox.shrink(),
                        style: const TextStyle(
                          color: primaryBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        items: List.generate(
                          statusList.length,
                          (index) {
                            return DropdownMenuItem<int>(
                              alignment: Alignment.centerLeft,
                              value: index,
                              child: Text(
                                statusList[index][0].toUpperCase() +
                                    statusList[index].substring(1),
                                style: const TextStyle(
                                  color: primaryBlue,
                                ),
                              ),
                            );
                          },
                        ),
                        selectedItemBuilder: (context) {
                          return List.generate(
                            statusList.length,
                            (index) => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  statusList[index][0].toUpperCase() +
                                      statusList[index].substring(1),
                                  style: const TextStyle(
                                    color: primaryBlue,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: primaryBlue,
                                ),
                              ],
                            ),
                          );
                        },
                        onChanged: (int? newIndex) {
                          if (newIndex != null) {
                            setState(() {
                              _selectedIndex = newIndex;
                            });
                            fetchDataForTab(statusList[newIndex]);
                          }
                        },
                      ),
                    ),
                  ),
                  // DropdownButton<int>(
                  //   value: _selectedIndex,
                  //   elevation: 0,
                  //   icon: Icon(
                  //     Icons.keyboard_arrow_down_rounded,
                  //     color: primaryBlue,
                  //   ),
                  //   style: const TextStyle(
                  //     color: primaryBlue,
                  //     fontSize: 14,
                  //     fontWeight: FontWeight.w500,
                  //   ),
                  //   underline: SizedBox(),
                  //   items: List.generate(
                  //     statusList.length,
                  //     (index) {
                  //       return DropdownMenuItem<int>(
                  //         alignment: Alignment.centerRight,
                  //         value: index,
                  //         child: Text(
                  //           statusList[index][0].toUpperCase() +
                  //               statusList[index].substring(1),
                  //           style: const TextStyle(
                  //             color: primaryBlue,
                  //           ),
                  //         ),
                  //       );
                  //     },
                  //   ),
                  //   onChanged: (int? newIndex) {
                  //     if (newIndex != null) {
                  //       setState(() {
                  //         _selectedIndex = newIndex;
                  //       });
                  //       fetchDataForTab(statusList[newIndex]);
                  //     }
                  //   },
                  // ),
                  const SizedBox(width: 16),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: buildListView(_selectedIndex),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
