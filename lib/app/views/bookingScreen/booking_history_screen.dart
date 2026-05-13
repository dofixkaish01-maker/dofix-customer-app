import 'package:do_fix/app/widgets/service_container.dart';
import 'package:do_fix/main.dart';
import 'package:do_fix/utils/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/dashboard_controller.dart';
import '../../../model/booking_model.dart';

class BookingHistoryScreen extends StatefulWidget {
  final VoidCallback? onRefreshNeeded;

  const BookingHistoryScreen({super.key, this.onRefreshNeeded});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen>
    with TickerProviderStateMixin, RouteAware, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  //  extra flag so first time hi hard loader ho
  bool _hasLoadedOnce = false;
  final PageController _pageController = PageController();
  final Map<int, ScrollController> _scrollControllers = {};
  late List<GlobalKey<AnimatedListState>> _listKeys;
  Map<String, List<Booking?>> tabData = {};
  late TabController _tabController;
  int _selectedIndex = 0;
  Set<String> loadingTabs = {};
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

      final controller = _scrollControllers[_selectedIndex];
      if (controller != null && controller.hasClients) {
        controller.jumpTo(0);
      }
    });
    _listKeys =
        List.generate(statusList.length, (_) => GlobalKey<AnimatedListState>());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoadedOnce) {
        _hasLoadedOnce = true;
        fetchDataForTab("all");
      }
    });
  }
  Future<void> fetchDataForTab(String status, {bool isRefresh = false}) async {
    if (status.toLowerCase() == "cancelled") {
      status = "canceled";
    }

    if (!isRefresh && tabData.containsKey(status)) {
      return;
    }
    if (loadingTabs.contains(status)) return;

    final controller = Get.find<DashBoardController>();

    setState(() {
      loadingTabs.add(status);
    });

    await controller.getBooking({
      "limit": "100",
      "offset": "1",
      "booking_status": status,
      "service_type": "all"
    });

    final data = List<Booking?>.from(
      controller.bookingModel.data ?? [],
    );

    tabData[status] = data;

    setState(() {
      loadingTabs.remove(status);
    });
  }
  Widget buildListView(int tabIndex) {

    String status = statusList[tabIndex];

    if (status.toLowerCase() == "cancelled") {
      status = "canceled";
    }

    final items = tabData[status] ?? [];

    if (items.isEmpty) {

      if (loadingTabs.contains(status)) {
        return const SizedBox();
      }

      return const Center(
        child: Text("No Booking Found"),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        String status = statusList[tabIndex];

        if (status.toLowerCase() == "cancelled") {
          status = "canceled";
        }

        tabData.remove(status);

        await fetchDataForTab(
          status,
          isRefresh: true,
        );
      },
      child: ListView.builder(
        controller: _scrollControllers.putIfAbsent(
          tabIndex,
              () => ScrollController(),
        ),
        itemCount: items.length,
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
                  booking: items[index],
                ),
              ),
            ),
          );
        },
      ),
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
                indicatorPadding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: PageView.builder(
                controller: _pageController,
                itemCount: statusList.length,
                // onPageChanged: (index) {
                //   setState(() {
                //     _selectedIndex = index;
                //   });
                //
                //   _tabController.animateTo(index);
                // },
                onPageChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });

                  _tabController.animateTo(index);

                  fetchDataForTab(
                    statusList[index],
                    isRefresh: false,
                  );
                },
                itemBuilder: (context, index) {
                  return buildListView(index);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
