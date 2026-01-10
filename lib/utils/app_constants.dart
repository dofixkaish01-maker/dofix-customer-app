class AppConstants {
  static const String baseUrl = "https://panel.dofix.in/";
  static const String imgBaseUrl =
      "https://lab5.invoidea.in/offle/assets/admin/images/coupan/";
  static const String imgLogoBaseUrl =
      "https://lab5.invoidea.in/offle/assets/admin/images/logoImage/";
  static const String imgProfileBaseUrl =
      "https://panel.dofix.in/storage/provider/profile_img/";
  static const String appName = 'DoFix';
  static const double appVersion = 1.0;
  static const String fontFamily = 'AlbertSans';

  static const String couponListUrl = 'coupon/index';
  static const String sendOtp = 'api/v1/customer/auth/send-otp';
  static const String verifyOtp = 'api/v1/customer/auth/verify-otp';
  static const String changeStatus = 'api/v1/customer/auth/change-status';
  static const String checkUser = 'api/v1/customer/auth/check-user';
  static const String register = 'api/v1/customer/auth/registration';
  static const String category = 'api/v1/customer/category';
  static const String featuredCategory = 'api/v1/customer/featured-categories';
  static const String topRated = 'api/v1/customer/top-rated-categories';
  static const String quickRepair = 'api/v1/customer/quick-repair-categories';
  static const String cartListing = 'api/v1/customer/cart/list';
  static const String service = 'api/v1/customer/service';
  static const String serviceDetails = 'api/v1/customer/service/detail';
  static const String addressLists = 'api/v1/customer/address';
  static const String addAddress = 'api/v1/customer/address';

  static const String cancelBookingApi =
      'api/v1/customer/booking/status-update';

  static const String bookings = 'api/v1/customer/booking';
  static const String bookingDetails = 'api/v1/customer/booking/';
  static const String booking = 'api/v1/customer/booking/create-enquiry';
  static const String bookingRequest = 'api/v1/customer/booking/request/send';
  static const String zones = 'api/v1/customer/config/get-zone-id';
  static const String pages = 'api/v1/customer/config/pages';
  static const String categoriesToServices =
      'api/v1/customer/service/sub-category';
  static const String categoriesToSubCategories =
      'api/v1/customer/category/childes';
  static const String geoCodeLocation = 'api/v1/customer/config/geocode-api';
  static const String banners = 'api/v1/customer/banner';
  static const String search = 'api/v1/customer/service/search';
  static const String user = 'api/v1/customer/auth/user-detail';
  static const String updateProfile = 'api/v1/customer/auth/update-profile';
  static const String couponShowUrl = 'coupon/show';
  static const String categoryListUrl = 'category/index';
  static const String categoryShowUrl = 'category/category-show';
  static const String forgotPassSendOtp = 'password/email';
  static const String forgotPassVerifyOtp = 'password/verify-code';
  static const String forgotPassNewPass = 'password/reset';
  static const String redeemedCoupon = 'coupon/redeem';
  static const String redeemedCouponList = 'coupon/redeem-list';
  static const String profileDetails = 'profile-details';
  static const String profileUpdate = 'profile-update';
  static const String regularBookingInvoiceUrl =
      'admin/booking/customer-invoice/';

  static const String theme = 'theme';
  static const String intro = 'intro';
  static const String token = 'token';
  static const String guestToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiI5NWZhYWFjNi1jMWQyLTRkNGMtYmViMS0wNDE5NmRkMmZhOGUiLCJqdGkiOiI5YWJkMjI0OWE4NWIyZWMwMDQ3YmIzODkyOWJlOGY1NjIwMzFiOTFhNTkzMDg1MWI0M2JhYzNlMzdhNmQ1ZGRhYmM3NGNjNWUwY2Y0MTAxOCIsImlhdCI6MTc1MjY0OTU0Ny44OTQxNTA5NzIzNjYzMzMwMDc4MTI1LCJuYmYiOjE3NTI2NDk1NDcuODk0MTUzMTE4MTMzNTQ0OTIxODc1LCJleHAiOjE3ODQxODU1NDcuODkyOTYxMDI1MjM4MDM3MTA5Mzc1LCJzdWIiOiJkNWM0YzljOS00YWM1LTRhYzktOGEwZC01MmFjYWVhOWQxNjEiLCJzY29wZXMiOltdfQ.rn3m2NQsKXsQKACdRK_y3cMV-pBI3RArH_ZtmBk55Bp300XESqznx4T6MWcjZCEBB5CncttdJCT-15W0aAi-Rhr7gTddXx1OliehQHR8trYM1Y1QbMuCZfMkTDQMBishFC67lZN3z3oLRB2wLhH8rieqOmfrBJH9uhIFxlx7HVsAtcReNjhN5e7ZovDWJGcPfpZ8vF8EBFQtt-v4e1O-4qihgMWzHKkJkexbZ6yfZEGP3rCwvp2J8O6X8HwiW-mS2Yo7QVLd6lS2PO-ybvRkwCWkgCC7RA2S6iLhBnXOHM3VaLVGaKTZ-w2Gycq1gXNxqU-gSRDsPvU45c6JOKNdKApWHkDHIv1BGa_ETiBpKuiQ4L4i2wcJtz5PJDy0q_ARj8egFAGbjDUxylD7iJ-GFM4s8Xi5zTQ6jNWvPcu-HHjK4kb2vgVglGI7Vte7DDsonfNe4CRplYhD0my0wR_Soa7QejbC0Nc23_ZnFcecPC8Qh9zC_t5dEdaxNZLF17x9VGu4ZHp-O_ngfXPnfqocm4YY61DtQ5H5Zxo-H34c7L8XNWwOXKJ36c3CVRJacwHH_5hrGXDfgzEg0okO_6MqACee3tc5CdGoCMGonmvKryuxdD1B1xh5PVU4Na8jd2xI2vX0-dYLfHOeIKtgDbqT0zpEoy1twBCBhptVxTlH0mo';

  static const String getCustomerBookingReview = 'api/v1/customer/review';
  static const String getBookingSetupApi =
      'api/v1/admin/business-settings/get-booking-setup';
  static const String saveCustomerReview = 'api/v1/customer/review/submit';
  static const String showServiceReviews =
      'api/v1/customer/review/services-review';
}
