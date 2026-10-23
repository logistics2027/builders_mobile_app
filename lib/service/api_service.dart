import 'dart:io';
import 'package:dio/dio.dart';
import 'package:avg_mart/core/constants/app_config.dart';
import 'package:avg_mart/core/constants/app_logger.dart';
import 'package:avg_mart/main.dart';
import 'package:avg_mart/models/app_version_response.dart';
import 'package:avg_mart/models/banner_response.dart';
import 'package:avg_mart/models/cart_response.dart';
import 'package:avg_mart/models/category_response.dart';
import 'package:avg_mart/models/order_response.dart';
import 'package:avg_mart/models/product_detail_response.dart';
import 'package:avg_mart/models/product_response.dart';
import 'package:avg_mart/models/review_response.dart';
import 'package:avg_mart/screens/login_screen.dart';
import 'package:avg_mart/service/api_exception_service.dart';
import 'package:avg_mart/service/storege_service.dart';
import 'package:avg_mart/state/app_state.dart';
import 'package:avg_mart/theme/app_theme.dart';
import 'package:flutter/material.dart';

import '../core/utils/app_utils.dart' as AppUtils;

class ApiService {
  final Dio _dio = Dio();
  static Dio? _lastDio;
  static bool _isHandlingSessionExpired = false;

  ApiService() {
    // Configure Dio
    _dio.options.baseUrl = AppConfig.baseUrl;
    _dio.options.headers = {"Content-Type": "application/json"};
    _dio.options.connectTimeout = const Duration(seconds: 30); // 5 seconds
    _dio.options.receiveTimeout = const Duration(seconds: 30); // 3 seconds
    _lastDio = _dio;
  }
  // Helper: standardized error handling for all non-2xx responses.
  // Shows a toast and throws a typed ApiExceptionService.
  Never _handleErrorResponse(
    dynamic responseData,
    int? statusCode, {
    String? endpoint,
  }) {
    final errorMessage = (responseData is Map<String, dynamic>)
        ? responseData['error'] is Map
              ? responseData['error']['message'] as String?
              : responseData['message'] as String?
        : null;

    switch (statusCode) {
      case 400:
        AppUtils.showToast(errorMessage ?? 'Invalid request');
        throw ApiExceptionService(400, errorMessage ?? 'Invalid request');
      case 401:
        final isAuthEndpoint = endpoint != null &&
            (endpoint.startsWith('auth/login') ||
             endpoint.startsWith('auth/signup') ||
             endpoint.startsWith('auth/verify') ||
             endpoint.startsWith('auth/forgot') ||
             endpoint.startsWith('auth/reset'));
        if (!isAuthEndpoint) {
          handleSessionExpired(
            message: errorMessage ?? 'Session expired, please login again',
          );
        } else {
          AppUtils.showToast(errorMessage ?? 'Invalid credentials');
        }
        throw ApiExceptionService(401, errorMessage ?? 'Session expired');
      case 403:
        AppUtils.showToast(
          errorMessage ?? 'You are not authorized to perform this action',
        );
        throw ApiExceptionService(403, errorMessage ?? 'Forbidden');
      case 404:
        AppUtils.showToast(errorMessage ?? 'Resource not found');
        throw ApiExceptionService(404, errorMessage ?? 'Not found');
      case 409:
        AppUtils.showToast(errorMessage ?? 'Resource already exists');
        throw ApiExceptionService(409, errorMessage ?? 'Conflict');
      case 429:
        AppUtils.showToast(
          errorMessage ?? 'Too many requests, please try again later',
        );
        throw ApiExceptionService(429, errorMessage ?? 'Rate limit exceeded');
      case 500:
        AppUtils.showToast(
          errorMessage ?? 'Something went wrong, please try again',
        );
        throw ApiExceptionService(500, errorMessage ?? 'Internal error');
      default:
        AppUtils.showToast(errorMessage ?? 'An error occurred');
        throw ApiExceptionService(
          statusCode ?? 0,
          errorMessage ?? 'Unexpected status code: $statusCode',
        );
    }
  }

  Future<T> _makePostRequest<T>(
    String endpoint,
    Map<String, dynamic>? data,
    T Function(dynamic json) fromJson,
  ) async {
    try {
      AppLogger.print('API headers:', '${_dio.options.headers}');
      AppLogger.print('API Request:', '${_dio.options.baseUrl}$endpoint');
      AppLogger.print('API Params:', '${data ?? {}}');

      final response = await _dio.post(
        endpoint,
        data: data ?? {},
        options: Options(
          validateStatus: (status) {
            return status != null && status < 600;
          },
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.print('API Response:', '${response.data}');
        return fromJson(response.data);
      } else {
        _handleErrorResponse(response.data, response.statusCode, endpoint: endpoint);
      }
    } catch (e, stacktrace) {
      AppLogger.print('API Exception:', '$e');
      AppLogger.print('Stacktrace:', '$stacktrace');
      rethrow;
    }
  }

  Future<T> _makePutRequest<T>(
    String endpoint,
    Map<String, dynamic>? data,
    T Function(dynamic json) fromJson,
  ) async {
    try {
      AppLogger.print('API headers:', '${_dio.options.headers}');
      AppLogger.print('API Request:', '${_dio.options.baseUrl}$endpoint');
      AppLogger.print('API Params:', '${data ?? {}}');

      final response = await _dio.put(
        endpoint,
        data: data ?? {},
        options: Options(
          validateStatus: (status) {
            return status != null && status < 600;
          },
        ),
      );

      if (response.statusCode == 200) {
        AppLogger.print('API Response:', '${response.data}');
        return fromJson(response.data);
      } else {
        _handleErrorResponse(response.data, response.statusCode, endpoint: endpoint);
      }
    } catch (e, stacktrace) {
      AppLogger.print('API Exception:', '$e');
      AppLogger.print('Stacktrace:', '$stacktrace');
      throw Exception('An error occurred: $e');
    }
  }

  Future<T> _makeGetRequest<T>(
    String endpoint,
    String? dynamicPath,
    Map<String, dynamic>? queryParams,
    T Function(dynamic json) fromJson,
  ) async {
    try {
      final fullEndpoint = dynamicPath != null && dynamicPath.isNotEmpty
          ? '$endpoint/$dynamicPath'
          : endpoint;

      AppLogger.print('API headers:', '${_dio.options.headers}');
      AppLogger.print('API Request:', '${_dio.options.baseUrl}$fullEndpoint');
      AppLogger.print('API Params:', '${queryParams ?? {}}');

      final response = await _dio.get(
        fullEndpoint,
        queryParameters: queryParams,
        options: Options(
          validateStatus: (status) {
            return status != null && status < 600;
          },
        ),
      );

      AppLogger.print('response  statuscode:', '${response.statusCode}');
      if (response.statusCode == 200) {
        AppLogger.print('API Response:', '${response.data}');
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return fromJson(data);
        } else if (data is List) {
          return fromJson(data);
        } else {
          throw Exception("Unexpected response format");
        }
      } else {
        _handleErrorResponse(response.data, response.statusCode, endpoint: fullEndpoint);
      }
    } catch (e, stacktrace) {
      AppLogger.print('API Exception:', '$e');
      AppLogger.print('Stacktrace:', '$stacktrace');
      throw Exception('An error occurred: $e');
    }
  }

  Future<T> _makePatchRequest<T>(
    String endpoint,
    Map<String, dynamic>? data,
    T Function(dynamic json) fromJson,
  ) async {
    try {
      AppLogger.print('API PATCH:', '${_dio.options.baseUrl}$endpoint');
      AppLogger.print('API Params:', '${data ?? {}}');

      final response = await _dio.patch(
        endpoint,
        data: data ?? {},
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.print('API Response:', '${response.data}');
        return fromJson(response.data);
      } else {
        _handleErrorResponse(response.data, response.statusCode, endpoint: endpoint);
      }
    } catch (e, stacktrace) {
      AppLogger.print('API Exception:', '$e');
      AppLogger.print('Stacktrace:', '$stacktrace');
      rethrow;
    }
  }

  /// Generic multipart request supporting both single/multiple files under a
  /// given field name plus arbitrary text fields. Used for product
  /// create/update where images (productImages) + text fields are combined.
  Future<T> _makeMultipartRequest<T>({
    required String endpoint,
    required String method, // 'POST' or 'PUT'
    Map<String, dynamic>? fields,
    String? fileFieldName,
    List<File>? files,
    T Function(dynamic json)? fromJson,
  }) async {
    try {
      final map = <String, dynamic>{...?fields};

      if (fileFieldName != null && files != null && files.isNotEmpty) {
        map[fileFieldName] = [
          for (final file in files)
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
        ];
      }

      final formData = FormData.fromMap(map);

      AppLogger.print('API headers:', '${_dio.options.headers}');
      AppLogger.print(
        'API Request ($method):',
        '${_dio.options.baseUrl}$endpoint',
      );

      final response = method == 'PUT'
          ? await _dio.put(
              endpoint,
              data: formData,
              options: Options(
                validateStatus: (status) => status != null && status < 600,
              ),
            )
          : await _dio.post(
              endpoint,
              data: formData,
              options: Options(
                validateStatus: (status) => status != null && status < 600,
              ),
            );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.print('API Response:', '${response.data}');
        return fromJson != null ? fromJson(response.data) : response.data as T;
      } else {
        _handleErrorResponse(response.data, response.statusCode, endpoint: endpoint);
      }
    } catch (e, stacktrace) {
      AppLogger.print('API Exception:', '$e');
      AppLogger.print('Stacktrace:', '$stacktrace');
      rethrow;
    }
  }

  Future<T> _uploadFile<T>({
    required File file,
    required String apiUrl,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      AppLogger.print('API Request:', '${_dio.options.baseUrl}$apiUrl');
      AppLogger.print('Uploading File:', file.path);

      final response = await _dio.post(
        '${_dio.options.baseUrl}$apiUrl',
        data: formData,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        AppLogger.print('API Response:', '${response.data}');
        return fromJson(response.data);
      } else if (response.statusCode == 400) {
        throw Exception('Unexpected status code: ${response.statusCode}');
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e, stacktrace) {
      AppLogger.print('API Exception:', '$e');
      AppLogger.print('Stacktrace:', '$stacktrace');
      throw Exception('An error occurred: $e');
    }
  }

  Future<T> _makeDeleteRequest<T>(
    String endpoint,
    String? dynamicPath,
    Map<String, dynamic>? queryParams,
    T Function(dynamic json) fromJson,
  ) async {
    try {
      final fullEndpoint = dynamicPath != null && dynamicPath.isNotEmpty
          ? '$endpoint/$dynamicPath'
          : endpoint;
      AppLogger.print('API headers:', '${_dio.options.headers}');
      AppLogger.print('API Request:', '${_dio.options.baseUrl}$fullEndpoint');
      AppLogger.print('API Params:', '${queryParams ?? {}}');

      final response = await _dio.delete(
        fullEndpoint,
        data: queryParams,
        options: Options(
          validateStatus: (status) {
            return status != null && status < 600;
          },
        ),
      );

      if (response.statusCode == 200) {
        AppLogger.print('API Response:', '${response.data}');
        return fromJson(response.data);
      } else {
        _handleErrorResponse(response.data, response.statusCode, endpoint: fullEndpoint);
      }
    } catch (e, stacktrace) {
      AppLogger.print('API Exception:', '$e');
      AppLogger.print('Stacktrace:', '$stacktrace');
      throw Exception('An error occurred: $e');
    }
  }

  /// Handles session expiration:
  /// 1. Clears stored auth tokens and user session
  /// 2. Navigates to LoginScreen
  /// 3. Shows session expired dialog
  static Future<void> handleSessionExpired({String? message}) async {
    if (_isHandlingSessionExpired) return;
    _isHandlingSessionExpired = true;

    try {
      // 1. Mark AppState as logged out if context available
      final currentCtx = navigatorKey.currentContext;
      if (currentCtx != null && currentCtx.mounted) {
        try {
          final appState = AppStateProvider.of(currentCtx);
          appState.logout();
        } catch (_) {}
      }

      // 2. Clear secure storage and auth tokens
      await StorageService().clearAll();

      // 3. Clear authorization header in Dio
      _lastDio?.options.headers.remove('Authorization');

      // 4. Navigate to LoginScreen, clearing all previous routes
      final nav = navigatorKey.currentState;
      if (nav != null) {
        nav.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );

        // 5. Show session expired dialog on the LoginScreen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final dialogContext = navigatorKey.currentContext;
          if (dialogContext != null && dialogContext.mounted) {
            showDialog(
              context: dialogContext,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber,
                      size: 28,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Session Expired',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: Text(
                  message ??
                      'Your session has expired. Please log in again to continue.',
                  style: const TextStyle(fontSize: 14),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ).then((_) {
              _isHandlingSessionExpired = false;
            });
          } else {
            _isHandlingSessionExpired = false;
          }
        });
      } else {
        _isHandlingSessionExpired = false;
      }
    } catch (_) {
      _isHandlingSessionExpired = false;
    }
  }

  Future<void> _handleLogout(BuildContext context, String? message) async {
    await handleSessionExpired(message: message);
  }

  Future<void> addToken() async {
    final token = await StorageService().getToken('auth_token');
    if (token == null || token.isEmpty || token == 'null') {
      _dio.options.headers.remove('Authorization');
      await handleSessionExpired();
      throw ApiExceptionService(401, 'Session expired, please login again');
    }
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // =======================================================================
  // AUTH  (root-mounted, e.g. app.use('/', authRoutes))
  // =======================================================================

  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    String role = "user",
  }) {
    return _makePostRequest("auth/signup", {
      "name": name,
      "email": email,
      "password": password,
      "role": role,
    }, (json) => json as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) {
    return _makePostRequest("auth/login", {
      "email": email,
      "password": password,
    }, (json) => json as Map<String, dynamic>);
  }

  // =======================================================================
  // PROFILE  (GET/PUT/POST/DELETE /profile...)
  // =======================================================================

  /// GET /auth/profile -> { user, addresses }
  Future<Map<String, dynamic>> getProfile() {
    return _makeGetRequest(
      "auth/profile",
      null,
      null,
      (json) => json as Map<String, dynamic>,
    );
  }

  /// PUT /auth/profile/password
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _makePutRequest("auth/profile/password", {
      "currentPassword": currentPassword,
      "newPassword": newPassword,
    }, (json) => json as Map<String, dynamic>);
  }

  /// POST /auth/profile/address
  Future<Map<String, dynamic>> addAddress({
    required String tag,
    required String phone,
    required String streetName,
    required String landmark,
    required String city,
    required String state,
    required String district,
    required String pincode,
  }) {
    return _makePostRequest("auth/profile/address", {
      "tag": tag,
      "phone": phone,
      "streetName": streetName,
      "street_name": streetName, // support both payload naming conventions
      "landmark": landmark,
      "city": city,
      "state": state,
      "district": district,
      "pincode": pincode,
    }, (json) => json as Map<String, dynamic>);
  }

  /// PUT /auth/profile/address/:id
  Future<Map<String, dynamic>> editAddress({
    required String id,
    required Map<String, dynamic> data,
  }) {
    // support both payload naming conventions
    if (data.containsKey("streetName")) {
      data["street_name"] = data["streetName"];
    }
    return _makePutRequest(
      "auth/profile/address/$id",
      data,
      (json) => json as Map<String, dynamic>,
    );
  }

  /// DELETE /auth/profile/address/:id
  Future<Map<String, dynamic>> removeAddress({required String id}) {
    return _makeDeleteRequest(
      "auth/profile/address",
      id,
      null,
      (json) => json as Map<String, dynamic>,
    );
  }

  /// DELETE /auth/profile: permanently delete account and user data
  Future<Map<String, dynamic>> deleteAccount() async {
    await addToken();
    return await _makeDeleteRequest(
      "auth/profile/delete",
      null,
      null,
      (json) => json is Map<String, dynamic> ? json : {'success': true},
    );
  }

  // =======================================================================
  // CART  (GET/POST/PUT/DELETE /cart...)
  // =======================================================================

  /// GET /cart -> List of cart items

  Future<List<CartResponse>> getCart() async {
    await addToken(); // Ensure the token is added before making the request
    return _makeGetRequest(
      "auth/cart",
      null,
      null,
      (json) => List<CartResponse>.from(
        (json as List).map((x) => CartResponse.fromJson(x)),
      ),
    );
  }

  Future<List<CategoryiesResponse>> getCategories() async {
    await addToken(); // Ensure the token is added before making the request
    return _makeGetRequest(
      "categories",
      null,
      null,
      (json) => List<CategoryiesResponse>.from(
        (json as List).map((x) => CategoryiesResponse.fromJson(x)),
      ),
    );
  }

  // POST /cart
  Future<Map<String, dynamic>> addToCart({
    required String productId,
    required String name,
    required String category,
    required num price,
    required String image,
    String? selectedSize,
    String? fromCartItemId,
    bool isSizeUpdateOnly = false,
    int? existingQty,
  }) {
    return _makePostRequest("auth/cart", {
      "product_id": productId,
      "name": name,
      "category": category,
      "price": price,
      "image": image,
      "selected_size": selectedSize,
      "fromCartItemId": fromCartItemId,
      "isSizeUpdateOnly": isSizeUpdateOnly,
      "existingQty": existingQty,
    }, (json) => json as Map<String, dynamic>);
  }

  /// PUT /cart/:id
  Future<Map<String, dynamic>> updateCartQuantity({
    required String id,
    required int quantity,
  }) {
    return _makePutRequest("auth/cart/$id", {
      "quantity": quantity,
    }, (json) => json as Map<String, dynamic>);
  }

  /// DELETE /cart/:id
  Future<Map<String, dynamic>> removeFromCart({required String id}) {
    return _makeDeleteRequest(
      "auth/cart",
      id,
      null,
      (json) => json as Map<String, dynamic>,
    );
  }

  // =======================================================================
  // PAYMENT / ORDERS  (/payment/..., /orders, /admin/orders...)
  // =======================================================================

  /// POST /payment/order
  Future<Map<String, dynamic>> createRazorpayOrder({
    required num amount,
  }) async {
    await addToken(); // Ensure the token is added before making the request
    return _makePostRequest("auth/payment/order", {
      "amount": amount,
    }, (json) => json as Map<String, dynamic>);
  }

  /// POST /payment/verify
  Future<Map<String, dynamic>> verifyRazorpayPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String addressId,
    required num amount,
  }) async {
    await addToken(); // Ensure the token is added before making the request
    return _makePostRequest("auth/payment/verify", {
      "razorpay_order_id": razorpayOrderId,
      "razorpay_payment_id": razorpayPaymentId,
      "razorpay_signature": razorpaySignature,
      "address_id": addressId,
      "amount": amount,
    }, (json) => json as Map<String, dynamic>);
  }

  Future<List<OrderResponse>> getUserOrders() async {
    await addToken(); // Ensure the token is added before making the request
    return _makeGetRequest(
      "auth/orders",
      null,
      null,
      (json) => List<OrderResponse>.from(
        (json as List).map((x) => OrderResponse.fromJson(x)),
      ),
    );
  }

  /// GET /admin/orders -> all orders (admin) or branch-filtered (branch_admin)
  Future<List<dynamic>> getAllCustomerOrders() {
    return _makeGetRequest(
      "admin/orders",
      null,
      null,
      (json) => json as List<dynamic>,
    );
  }

  Future<ReviewResponse> getProductReviews(String productId) {
    return _makeGetRequest(
      "products/$productId/reviews",
      null,
      null,
      (json) => ReviewResponse.fromJson(json),
    );
  }

  /// POST /products/reviews  (multipart: productId, rating, comment + reviewImages[])
  Future<Map<String, dynamic>> addProductReview({
    required String productId,
    required int rating,
    required String comment,
    List<File>? images,
  }) async {
    await addToken();
    return _makeMultipartRequest(
      endpoint: "products/reviews",
      method: "POST",
      fields: {"productId": productId, "rating": rating, "comment": comment},
      fileFieldName: "reviewImages",
      files: images,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }
  // Add these two methods inside your ApiService class in api_service.dart,
  // near the existing signup()/login() methods under the AUTH section.

  /// POST /auth/signup/verify-otp
  /// Body: { "email": "...", "otp": "..." }
  /// Response: { "message": "...", "token": "...", "user": { ... } }
  Future<Map<String, dynamic>> verifySignupOtp({
    required String email,
    required String otp,
  }) {
    return _makePostRequest("auth/signup/verify-otp", {
      "email": email,
      "otp": otp,
    }, (json) => json as Map<String, dynamic>);
  }
  // =======================================================================
  // FORGOT PASSWORD
  // =======================================================================

  /// POST /auth/forgot-password/request-otp
  /// Body: { "email": "..." }
  Future<Map<String, dynamic>> forgotPasswordRequestOtp({
    required String email,
  }) {
    return _makePostRequest("auth/forgot-password/request-otp", {
      "email": email,
    }, (json) => json as Map<String, dynamic>);
  }

  /// GET /products/filter?page=&limit=&category=&search=&maxPrice=&sortBy=
  /// Response shape assumed: { products: [...], page, totalPages, total }
  Future<Map<String, dynamic>> getFilteredProducts({
    int page = 1,
    int limit = 25,
    String category = 'All',
    String search = '',
    String? maxPrice,
    String sortBy = 'featured',
  }) {
    return _makeGetRequest("products/filter", null, {
      "page": page,
      "limit": limit,
      "category": category,
      "search": search,
      if (maxPrice != null && maxPrice.isNotEmpty) "maxPrice": maxPrice,
      "sortBy": sortBy,
    }, (json) => json as Map<String, dynamic>);
  }

  /// POST /auth/forgot-password/reset-password
  /// Body: { "email": "...", "otp": "...", "newPassword": "..." }
  Future<Map<String, dynamic>> forgotPasswordResetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) {
    return _makePostRequest("auth/forgot-password/reset-password", {
      "email": email,
      "otp": otp,
      "newPassword": newPassword,
    }, (json) => json as Map<String, dynamic>);
  }

  /// POST /auth/signup/resend-otp
  /// Adjust this path if your backend's resend endpoint is named/mounted
  /// differently — check your Express route file for the exact path.
  Future<Map<String, dynamic>> resendSignupOtp({required String email}) {
    return _makePostRequest("auth/signup/resend-otp", {
      "email": email,
    }, (json) => json as Map<String, dynamic>);
  }

  /// PUT /admin/orders/:orderId
  Future<Map<String, dynamic>> updateOrderStatusByAdmin({
    required String orderId,
    required String status,
    String? expectedDelivery,
    String? dispatchedDate,
    String? deliveredDate,
  }) {
    return _makePutRequest("admin/orders/$orderId", {
      "status": status,
      if (expectedDelivery != null) "expectedDelivery": expectedDelivery,
      if (dispatchedDate != null) "dispatchedDate": dispatchedDate,
      if (deliveredDate != null) "deliveredDate": deliveredDate,
    }, (json) => json as Map<String, dynamic>);
  }

  /// GET /banners -> { success, banners: [...] }
  Future<BannerResponse> getBanners() async {
    await addToken(); // keep consistent with your other authed GETs
    return _makeGetRequest(
      "banners",
      null,
      null,
      (json) => BannerResponse.fromJson(json as Map<String, dynamic>),
    );
  }
  // =======================================================================
  // ADMIN DASHBOARD
  // =======================================================================

  /// GET /admin-dashboard
  Future<Map<String, dynamic>> getAdminDashboard() {
    return _makeGetRequest(
      "admin-dashboard",
      null,
      null,
      (json) => json as Map<String, dynamic>,
    );
  }

  // =======================================================================
  // BRANCH ADMIN  (ASSUMED PREFIX: mounted so full path is "branch")
  // Adjust the leading segment below (e.g. "admin/branch") to match
  // wherever you did app.use(<prefix>, branchAdminRoutes) in server.js
  // =======================================================================

  /// POST /branch  (master admin only)
  Future<Map<String, dynamic>> createBranchAdmin({
    required String name,
    required String email,
    required String branch,
    required String pincodes,
    required String password,
  }) {
    return _makePostRequest("branch", {
      "name": name,
      "email": email,
      "branch": branch,
      "pincodes": pincodes,
      "password": password,
    }, (json) => json as Map<String, dynamic>);
  }

  /// GET /branch -> list (admin) or single admin object (branch_admin)
  Future<dynamic> getAllBranchAdmins() {
    return _makeGetRequest("branch", null, null, (json) => json);
  }

  /// PUT /branch/:id
  Future<Map<String, dynamic>> updateBranchAdmin({
    required String id,
    String? name,
    String? email,
    String? branch,
    String? pincodes,
    String? currentPassword,
    String? newPassword,
  }) {
    return _makePutRequest("branch/$id", {
      if (name != null) "name": name,
      if (email != null) "email": email,
      if (branch != null) "branch": branch,
      if (pincodes != null) "pincodes": pincodes,
      if (currentPassword != null) "currentPassword": currentPassword,
      if (newPassword != null) "newPassword": newPassword,
    }, (json) => json as Map<String, dynamic>);
  }

  // =======================================================================
  // PRODUCTS  (ASSUMED PREFIX: "products")
  // e.g. app.use('/products', productRoutes)
  // =======================================================================

  /// GET /products
  Future<List<dynamic>> getAllProducts() {
    return _makeGetRequest(
      "products",
      null,
      null,
      (json) => json as List<dynamic>,
    );
  }

  Future<ProductDetailResponse> getProductsById({required String id}) {
    return _makeGetRequest(
      "products/$id",
      null,
      null,
      (json) => ProductDetailResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  /// POST /products  (multipart: fields + up to 5 images under "productImages")
  Future<Map<String, dynamic>> createProduct({
    required String name,
    required String category,
    required List<Map<String, dynamic>> sizes,
    required String description,
    required num originalPrice,
    required num offerPrice,
    num? branchAdminPrice,
    int count = 0,
    bool isFeatured = false,
    List<File>? images,
  }) {
    return _makeMultipartRequest(
      endpoint: "products",
      method: "POST",
      fields: {
        "name": name,
        "category": category,
        "sizes": sizes.isNotEmpty ? sizes : [],
        "description": description,
        "originalPrice": originalPrice,
        "offerPrice": offerPrice,
        if (branchAdminPrice != null) "branchAdminPrice": branchAdminPrice,
        "count": count,
        "isFeatured": isFeatured,
      },
      fileFieldName: "productImages",
      files: images,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// POST /auth/google  (Google OAuth login/signup)
  Future<Map<String, dynamic>> googleAuth({required String accessToken}) {
    return _makePostRequest("auth/google", {
      "access_token": accessToken,
    }, (json) => json as Map<String, dynamic>);
  }

  /// PUT /products/:id  (multipart: fields + optional new images)
  Future<Map<String, dynamic>> updateProduct({
    required String id,
    String? name,
    String? category,
    List<Map<String, dynamic>>? sizes,
    String? description,
    num? originalPrice,
    num? offerPrice,
    num? branchAdminPrice,
    int? count,
    bool? isFeatured,
    List<File>? images,
  }) {
    return _makeMultipartRequest(
      endpoint: "products/$id",
      method: "PUT",
      fields: {
        if (name != null) "name": name,
        if (category != null) "category": category,
        if (sizes != null) "sizes": sizes,
        if (description != null) "description": description,
        if (originalPrice != null) "originalPrice": originalPrice,
        if (offerPrice != null) "offerPrice": offerPrice,
        if (branchAdminPrice != null) "branchAdminPrice": branchAdminPrice,
        if (count != null) "count": count,
        if (isFeatured != null) "isFeatured": isFeatured,
      },
      fileFieldName: "productImages",
      files: images,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// DELETE /products/:id
  Future<Map<String, dynamic>> deleteProduct({required String id}) {
    return _makeDeleteRequest(
      "products",
      id,
      null,
      (json) => json as Map<String, dynamic>,
    );
  }

  // =======================================================================
  // STOCK  (ASSUMED PREFIX: "stock")
  // e.g. app.use('/stock', stockRoutes)
  // =======================================================================

  /// GET /stock
  Future<List<dynamic>> getStock() {
    return _makeGetRequest(
      "stock",
      null,
      null,
      (json) => json as List<dynamic>,
    );
  }

  /// POST /stock  (upsert: pass id to update, omit to insert)
  Future<Map<String, dynamic>> addOrUpdateStock({
    String? id,
    required String productName,
    required String category,
    required int count,
  }) {
    return _makePostRequest("stock", {
      if (id != null) "id": id,
      "product_name": productName,
      "category": category,
      "count": count,
    }, (json) => json as Map<String, dynamic>);
  }

  /// DELETE /stock/:id
  Future<Map<String, dynamic>> deleteStock({required String id}) {
    return _makeDeleteRequest(
      "stock",
      id,
      null,
      (json) => json as Map<String, dynamic>,
    );
  }

  // =======================================================================
  // STOCK REQUESTS  (ASSUMED PREFIX: "stock-requests")
  // e.g. app.use('/stock-requests', stockRequestRoutes)
  // NOTE: your router file defines paths as '/stock-requests' AGAIN inside
  // itself (router.post('/stock-requests', ...)), so if you mount it at
  // app.use('/', stockRequestRoutes) the final path is just "stock-requests"
  // (used below). If you mount it at app.use('/api', stockRequestRoutes)
  // the final path becomes "api/stock-requests" — adjust accordingly.
  // =======================================================================

  /// POST /stock-requests
  Future<Map<String, dynamic>> createStockRequest({
    required String productId,
    required String category,
    required int requestedCount,
    required num totalAmount,
  }) {
    return _makePostRequest("stock-requests", {
      "productId": productId,
      "category": category,
      "requestedCount": requestedCount,
      "totalAmount": totalAmount,
    }, (json) => json as Map<String, dynamic>);
  }

  /// GET /stock-requests
  Future<List<dynamic>> getAllStockRequests() {
    return _makeGetRequest(
      "stock-requests",
      null,
      null,
      (json) => json as List<dynamic>,
    );
  }

  /// PUT /stock-requests/:id/status  (admin only, status: Approved | Rejected)
  Future<Map<String, dynamic>> updateStockRequestStatus({
    required String id,
    required String status,
  }) {
    return _makePutRequest("stock-requests/$id/status", {
      "status": status,
    }, (json) => json as Map<String, dynamic>);
  }

  //
  Future<AppVersionResponse> getAppVersion() {
    return _makeGetRequest(
      "settings",
      null,
      null,
      (json) => AppVersionResponse.fromJson(json),
    );
  }
}
