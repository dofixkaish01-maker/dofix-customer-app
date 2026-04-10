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
    with TickerProviderStateMixin, RouteAware, AutomaticKeepAliveClientMixin  {
  @override
  bool get wantKeepAlive => true;

  //  extra flag so first time hi hard loader ho
  bool _hasLoadedOnce = false;
  final ScrollController _scrollController = ScrollController();
  late List<GlobalKey<AnimatedListState>> _listKeys;
  final List<Booking?> _items = [];
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

      setState(() {
        _selectedIndex = _tabController.index;
      });
      _scrollController.jumpTo(0);
      fetchDataForTab(statusList[_tabController.index]);
    });
    _listKeys =
        List.generate(statusList.length, (_) => GlobalKey<AnimatedListState>());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      //  OLD (comment)
      // fetchDataForTab("all");

      //  NEW: first time only
      if (!_hasLoadedOnce) {
        _hasLoadedOnce = true;
        fetchDataForTab("all");
      }
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _tabController = TabController(length: statusList.length, vsync: this);
  //   _tabController.addListener(() {
  //     if (_tabController.indexIsChanging) return;
  //     fetchDataForTab(statusList[_tabController.index]);
  //   });
  //   _listKeys =
  //       List.generate(statusList.length, (_) => GlobalKey<AnimatedListState>());
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     fetchDataForTab("all");
  //   });
  // }

  // Future<void> fetchDataForTab(String status, {bool isRefresh = false}) async {
  //   if (status.toLowerCase() == "cancelled") {
  //     status = "canceled";
  //   }
  //
  //   final controller = Get.find<DashBoardController>();
  //
  //   if (isRefresh) {
  //     //  FAST refresh – no animation drama
  //     _items.clear();
  //     _listKeys[_tabController.index].currentState?.setState(() {});
  //   } else {
  //     //  normal tab change animation (as it is)
  //     int toggle = 0;
  //     for (int i = _items.length - 1; i >= 0; i--) {
  //       final removedItem = _items.removeAt(i);
  //       final removeToRight = toggle % 2 == 0;
  //       toggle++;
  //
  //       _listKeys[_tabController.index].currentState?.removeItem(
  //         i,
  //             (context, animation) => SlideTransition(
  //           position: Tween<Offset>(
  //             begin: Offset.zero,
  //             end: Offset(removeToRight ? 1.0 : -1.0, 0.0),
  //           ).animate(animation),
  //           child: BookingContainer(booking: removedItem),
  //         ),
  //         duration: const Duration(milliseconds: 200), // ⬅ shorter
  //       );
  //     }
  //   }
  //
  //   await controller.getBooking({
  //     "limit": "100",
  //     "offset": "1",
  //     "booking_status": status,
  //     "service_type": "all"
  //   });
  //
  //   final data = controller.bookingModel.data ?? [];
  //
  //   for (int i = 0; i < data.length; i++) {
  //     _items.insert(i, data[i]);
  //     _listKeys[_tabController.index].currentState?.insertItem(
  //       i,
  //       duration: const Duration(milliseconds: 150), // ⬅ faster
  //     );
  //   }
  // }
  Future<void> fetchDataForTab(String status, {bool isRefresh = false}) async {

    if (status.toLowerCase() == "cancelled") {
      status = "canceled";
    }

    final controller = Get.find<DashBoardController>();

    //  START LOADING
    setState(() {
      _isLoading = true;
    });

    if (isRefresh) {
      //  FAST refresh – no animation drama
      _items.clear();
      _listKeys[_tabController.index].currentState?.setState(() {});
    } else {
      //  normal tab change animation (as it is)
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
            ).animate(animation),
            child: BookingContainer(booking: removedItem),
          ),
          duration: const Duration(milliseconds: 200),
        );
      }
    }

    //  API CALL
    await controller.getBooking({
      "limit": "100",
      "offset": "1",
      "booking_status": status,
      "service_type": "all"
    });

    final data = controller.bookingModel.data ?? [];

    //  ADD NEW ITEMS WITH ANIMATION
    int toggle = 0;
    for (int i = 0; i < data.length; i++) {
      final addFromRight = toggle % 2 == 0;
      toggle++;

      _items.insert(i, data[i]);

      _listKeys[_tabController.index].currentState?.insertItem(
        i,
        duration: const Duration(milliseconds: 300),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget buildListView(int selectedIndex) {
    if (_items.isEmpty && _isLoading) {
      return const SizedBox(); // loader overlay handle karega
    }

    if (_items.isEmpty) {
      return const Center(
        child: Text("Oops! No Booking is there"),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _items.length,
      controller: _scrollController,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Card(
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BookingContainer(
                booking: _items[index],
              ),
            ),
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicator: BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.circular(25),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black54,
                splashBorderRadius: BorderRadius.circular(25),
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                indicatorPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                tabs: statusList.map((status) {
                  return Tab(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        status[0].toUpperCase() + status.substring(1),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await fetchDataForTab(
                  statusList[_selectedIndex],
                  isRefresh: true,
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: buildListView(_selectedIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
