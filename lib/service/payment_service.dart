import 'package:avg_mart/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayPaymentService {
  final ApiService _apiService;
  late final Razorpay _razorpay;

  /// Called with the decoded JSON body returned by your /payment/verify endpoint.
  void Function(Map<String, dynamic> verifyResponse)? onPaymentVerified;

  /// Called whenever anything in the flow fails: order creation, checkout,
  /// or server-side verification.
  void Function(String message)? onPaymentFailed;

  /// Called if the user picks an external wallet Razorpay can't handle directly.
  void Function()? onExternalWallet;

  /// Optional hook fired right before Razorpay checkout opens
  /// (e.g. to show a loading spinner).
  void Function()? onOrderCreated;

  String? _addressId;
  num? _amount;

  RazorpayPaymentService(this._apiService) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  /// Creates a Razorpay order via your backend, then opens the checkout sheet.
  Future<void> startPayment({
    required num amount,
    required String addressId,
    String name = "AVG Mart",
    String description = "Order Payment",
    String? contact,
    String? email,
    Color themeColor = Colors.black,
  }) async {
    _addressId = addressId;
    _amount = amount;

    try {
      final orderData = await _apiService.createRazorpayOrder(amount: amount);

      // NOTE: adjust these keys to whatever your backend actually returns.
      // Typically the backend returns something like:
      // { "id": "order_xxx", "amount": 119700, "currency": "INR", "key": "rzp_test_xxx" }
      final String? backendKey = orderData['key'] as String?;
      final String razorpayKey = (backendKey != null && backendKey.isNotEmpty)
          ? backendKey
          : "rzp_test_T5NEmNwILnfzHd";
      final String? orderId = (orderData['id'] ?? orderData['order_id']) as String?;

      if (orderId == null) {
        onPaymentFailed?.call(
          "Order created but missing 'id' in response: $orderData",
        );
        return;
      }

      onOrderCreated?.call();

      final options = {
        'key': razorpayKey,
        'amount': (amount * 100).toInt(), // Razorpay expects paise
        'name': name,
        'description': description,
        'order_id': orderId,
        'prefill': {
          'contact': contact ?? '',
          'email': email ?? '',
        },
        'theme': {
          'color': '#${themeColor.value.toRadixString(16).substring(2).padLeft(6, '0')}',
        },
      };

      _razorpay.open(options);
    } catch (e) {
      onPaymentFailed?.call("Could not create order: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_addressId == null || _amount == null) {
      onPaymentFailed?.call("Missing address/amount context for verification.");
      return;
    }

    try {
      final verifyResponse = await _apiService.verifyRazorpayPayment(
        razorpayOrderId: response.orderId ?? '',
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
        addressId: _addressId!,
        amount: _amount!,
      );
      onPaymentVerified?.call(verifyResponse);
    } catch (e) {
      onPaymentFailed?.call(
        "Payment succeeded but server verification failed: $e",
      );
    } finally {
      _addressId = null;
      _amount = null;
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    onPaymentFailed?.call(response.message ?? "Payment failed or was cancelled");
    _addressId = null;
    _amount = null;
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    onExternalWallet?.call();
  }

  /// Call this from your widget's dispose() to release Razorpay listeners.
  void dispose() {
    _razorpay.clear();
  }
}