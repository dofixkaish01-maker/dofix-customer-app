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

  final PageController _pageController = PageController();
  final Map<int, ScrollController> _scrollControllers = {};

  Map<String, List<Booking?>> _bookingsByStatus = {};
  Set<String> _loadingTabs = {};

  late TabController _tabController;

  int _selectedIndex = 0;
  bool _hasLoadedOnce = false;

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
    fetchDataForTab(statusList[_selectedIndex], isRefresh: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _pageController.dispose();
    _tabController.dispose();
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

      _pageController.jumpToPage(_tabController.index);

      fetchDataForTab(statusList[_selectedIndex]);
    });

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

    final controller = Get.find<DashBoardController>();

    // prevent unnecessary API calls
    if (!isRefresh && _bookingsByStatus.containsKey(status)) return;

    // show loader only if no cached data
    if (!_bookingsByStatus.containsKey(status)) {
      setState(() {
        _loadingTabs.add(status);
      });
    }

    try {
      await controller.getBooking({
        "limit": "100",
        "offset": "1",
        "booking_status": status,
        "service_type": "all"
      });

      if (!mounted) return;

      final data = controller.bookingModel.data ?? [];
      _bookingsByStatus[status] = data;

    } catch (e) {
      debugPrint("Booking fetch error: $e");
    } finally {
      if (!mounted) return;

      setState(() {
        _loadingTabs.remove(status);
      });
    }
  }

  Widget buildListView(int tabIndex) {
    final status = statusList[tabIndex];
    final items = _bookingsByStatus[status] ?? [];

    // 1. Skeleton loader (first load)
    if (_loadingTabs.contains(status) && !_bookingsByStatus.containsKey(status)) {
      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: 5,
        itemBuilder: (_, __) => const BookingContainer(isLoading: true),
      );
    }

    // 2. No data + not loading
    if (!_bookingsByStatus.containsKey(status)) {
      return _buildEmptyState();
    }

    // 3. Empty list
    if (items.isEmpty) {
      return _buildEmptyState();
    }

    // 4. Data list
    return ListView.builder(
      controller: _scrollControllers.putIfAbsent(
        tabIndex,
            () => ScrollController(),
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (_, index) {
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
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 50, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No Bookings Found",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
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
            child: RefreshIndicator(
              onRefresh: () async {
                await fetchDataForTab(
                  statusList[_selectedIndex],
                  isRefresh: true,
                );
              },
              child: PageView.builder(
                controller: _pageController,
                itemCount: statusList.length,
                onPageChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                  _tabController.animateTo(index);
                },
                itemBuilder: (_, index) {
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
