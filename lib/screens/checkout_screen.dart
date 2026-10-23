import 'package:avg_mart/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../state/app_state.dart';
import '../models/address.dart';
import '../theme/app_theme.dart';
import 'main_navigation_screen.dart';
import 'address_screen.dart';
import '../bloc/profile/profile_cubit.dart';
import '../bloc/profile/profile_state.dart';
import '../bloc/cart/cart_cubit.dart';
import '../bloc/orders/orders_cubit.dart';
import '../service/payment_service.dart';
import '../service/api_service.dart';

// =====================================================================
// Design tokens for this screen (same family as the product screen).
// Brand colours come from AppTheme.
// =====================================================================
class _UI {
  _UI._();

  static const Color ink = Color(0xFF111827);
  static const Color inkSoft = Color(0xFF6B7280);
  static const Color body = Color(0xFF374151);
  static const Color border = Color(0xFFE5E7EB);
  static const Color canvas = Color(0xFFF5F6F8);
  static const Color success = Color(0xFF15803D);
  static const Color danger = Color(0xFFB91C1C);

  static const double radius = 6;
  static const double pad = 16;
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _currentStep = 1; // 1: Address, 2: Review, 3: Success
  ShippingAddress? _tempSelectedAddress;
  String _lastPlacedOrderId = '';
  late final RazorpayPaymentService _razorpayPaymentService;

  @override
  void initState() {
    super.initState();
    _razorpayPaymentService = RazorpayPaymentService(ApiService());
    _razorpayPaymentService.onPaymentVerified = (verifyResponse) {
      context.read<CartCubit>().clearLocalCart();
      BlocProvider.of<OrdersCubit>(context).fetchOrders();
      setState(() {
        _lastPlacedOrderId =
            verifyResponse['order_id'] ??
            verifyResponse['id']?.toString() ??
            'Successful';
        _currentStep = 3;
      });
    };
    _razorpayPaymentService.onPaymentFailed = (message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $message'),
          backgroundColor: _UI.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_UI.radius),
          ),
        ),
      );
    };
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        BlocProvider.of<ProfileCubit>(context).fetchProfile();
        BlocProvider.of<OrdersCubit>(context).fetchOrders();
      }
    });
  }

  @override
  void dispose() {
    _razorpayPaymentService.dispose();
    super.dispose();
  }

  double _calculateTax(double subtotal) => 0.0;
  double _calculateShipping(double subtotal) => subtotal >= 499.0 ? 0.0 : 49.0;

  /// Indian digit grouping with two decimals, e.g. 123456.5 -> ₹1,23,456.50
  String _money(num value) {
    final fixed = value.toStringAsFixed(2);
    final parts = fixed.split('.');
    final whole = parts[0];
    final decimals = parts[1];
    if (whole.length <= 3) return '₹$whole.$decimals';
    final last3 = whole.substring(whole.length - 3);
    var rest = whole.substring(0, whole.length - 3);
    final groups = <String>[];
    while (rest.length > 2) {
      groups.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) groups.insert(0, rest);
    return '₹${groups.join(',')},$last3.$decimals';
  }

  void _onPlaceOrder(CartState cartState, ProfileState profileState) {
    if (_tempSelectedAddress == null) return;

    final subtotal = cartState.totalPrice;
    final shipping = _calculateShipping(subtotal);
    final tax = _calculateTax(subtotal);
    final total = subtotal + shipping + tax;

    String userEmail = '';
    String userName = '';
    String phone = _tempSelectedAddress!.phone;
    if (profileState is ProfileLoaded) {
      userEmail = profileState.user['email'] ?? '';
      userName = profileState.user['name'] ?? '';
    }

    _razorpayPaymentService.startPayment(
      amount: total,
      addressId: _tempSelectedAddress!.id ?? '',
      name: userName.isNotEmpty ? userName : 'AVG Mart User',
      description: 'Checkout Payment',
      contact: phone,
      email: userEmail,
    );
  }

  /// Navigates to AddressScreen to add a new address, then refreshes the
  /// profile on return WITHOUT losing checkout state (_currentStep) and
  /// auto-selects the newly added address.
  void _goAddAddress(List<ShippingAddress> currentAddresses) {
    final previousIds = currentAddresses.map((a) => a.id).toSet();

    ProfileCubit? profileCubit;
    try {
      profileCubit = BlocProvider.of<ProfileCubit>(context);
    } catch (_) {
      profileCubit = null;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (routeContext) => profileCubit != null
            ? BlocProvider.value(
                value: profileCubit,
                child: const AddressScreen(),
              )
            : BlocProvider(
                create: (_) => ProfileCubit()..fetchProfile(),
                child: const AddressScreen(),
              ),
      ),
    ).then((_) async {
      if (profileCubit != null) {
        await profileCubit.fetchProfile();
      }
      if (!mounted) return;

      final refreshedState = profileCubit?.state;
      if (refreshedState is ProfileLoaded) {
        final newlyAdded = refreshedState.addresses
            .where((a) => !previousIds.contains(a.id))
            .toList();

        setState(() {
          if (newlyAdded.isNotEmpty) {
            _tempSelectedAddress = newlyAdded.first;
          } else if (_tempSelectedAddress != null &&
              !refreshedState.addresses.any(
                (a) => a.id == _tempSelectedAddress!.id,
              )) {
            _tempSelectedAddress = refreshedState.addresses.isNotEmpty
                ? refreshedState.addresses.first
                : null;
          }
          // _currentStep is intentionally left untouched here.
        });
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Shared building blocks
  // ---------------------------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppTheme.headerGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      elevation: 0,
      title: const Text(
        'Checkout',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  /// Flat white section with a title row, used throughout the flow.
  Widget _section({
    required String title,
    Widget? trailing,
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(_UI.pad),
  }) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _UI.ink,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _textAction(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.primary,
          ),
        ),
      ),
    );
  }

  ButtonStyle get _primaryButtonStyle => FilledButton.styleFrom(
    backgroundColor: AppTheme.primary,
    foregroundColor: Colors.white,
    disabledBackgroundColor: _UI.border,
    disabledForegroundColor: _UI.inkSoft,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_UI.radius),
    ),
  );

  ButtonStyle get _outlinedButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: AppTheme.primary,
    side: const BorderSide(color: AppTheme.primary, width: 1.2),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_UI.radius),
    ),
  );

  Widget _bottomBar({required Widget child}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(_UI.pad, 12, _UI.pad, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _UI.border)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(top: false, child: child),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final cartState = context.watch<CartCubit>().state;

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, profileState) {
        if (!appState.isLoggedIn) {
          return _buildSignInRequired(context);
        }

        if (_currentStep == 3) {
          return _buildSuccessView(context);
        }

        return Scaffold(
          appBar: _buildAppBar(),
          backgroundColor: _UI.canvas,
          body: Column(
            children: [
              _buildStepsHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildActiveStepContent(profileState, cartState),
                ),
              ),
              _buildBottomAction(profileState, cartState),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Signed-out state
  // ---------------------------------------------------------------------------
  Widget _buildSignInRequired(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: _UI.canvas,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(_UI.radius),
              border: Border.all(color: _UI.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 36, color: _UI.inkSoft),
                const SizedBox(height: 16),
                const Text(
                  'Sign in to continue',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: _UI.ink,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You need to be signed in to choose a delivery address, review your order and complete payment.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: _UI.inkSoft,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    style: _primaryButtonStyle,
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Steps header
  // ---------------------------------------------------------------------------
  Widget _buildStepsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _UI.border)),
      ),
      child: Row(
        children: [
          _stepNode(
            index: 1,
            label: 'Address',
            onTap: _currentStep == 2
                ? () => setState(() => _currentStep = 1)
                : null,
          ),
          Expanded(
            child: Container(
              height: 1.5,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              color: _currentStep >= 2 ? AppTheme.primary : _UI.border,
            ),
          ),
          _stepNode(index: 2, label: 'Review & pay'),
        ],
      ),
    );
  }

  Widget _stepNode({
    required int index,
    required String label,
    VoidCallback? onTap,
  }) {
    final isDone = _currentStep > index;
    final isActive = _currentStep == index;
    final reached = isDone || isActive;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: reached ? AppTheme.primary : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: reached ? AppTheme.primary : _UI.border,
                width: 1.5,
              ),
            ),
            child: isDone
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text(
                    '$index',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: reached ? Colors.white : _UI.inkSoft,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: reached ? FontWeight.w600 : FontWeight.w500,
              color: reached ? _UI.ink : _UI.inkSoft,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveStepContent(
    ProfileState profileState,
    CartState cartState,
  ) {
    switch (_currentStep) {
      case 1:
        return _buildAddressStep(profileState);
      case 2:
        return _buildReviewStep(profileState, cartState);
      default:
        return const SizedBox();
    }
  }

  // ---------------------------------------------------------------------------
  // Bottom action bar (changes per step)
  // ---------------------------------------------------------------------------
  Widget _buildBottomAction(ProfileState profileState, CartState cartState) {
    if (_currentStep == 1) {
      return _bottomBar(
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: FilledButton(
            onPressed: _tempSelectedAddress != null
                ? () => setState(() => _currentStep = 2)
                : null,
            style: _primaryButtonStyle,
            child: const Text(
              'Deliver to this address',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
            ),
          ),
        ),
      );
    }

    final subtotal = cartState.totalPrice;
    final total =
        subtotal + _calculateShipping(subtotal) + _calculateTax(subtotal);
    final canPay = _tempSelectedAddress != null && cartState.items.isNotEmpty;

    return _bottomBar(
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Total payable',
                style: TextStyle(fontSize: 11.5, color: _UI.inkSoft),
              ),
              const SizedBox(height: 2),
              Text(
                _money(total),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _UI.ink,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: canPay
                    ? () => _onPlaceOrder(cartState, profileState)
                    : null,
                style: _primaryButtonStyle,
                child: const Text(
                  'Pay securely',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 1: ADDRESS
  // ---------------------------------------------------------------------------
  Widget _buildAddressStep(ProfileState profileState) {
    if (profileState is ProfileLoading) {
      return const Padding(
        padding: EdgeInsets.all(48),
        child: Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    final List<ShippingAddress> addresses = profileState is ProfileLoaded
        ? profileState.addresses
        : [];

    // Sync selection with state addresses to handle deletion/addition
    if (_tempSelectedAddress == null && addresses.isNotEmpty) {
      _tempSelectedAddress = addresses.first;
    } else if (_tempSelectedAddress != null &&
        !addresses.any((a) => a.id == _tempSelectedAddress!.id)) {
      _tempSelectedAddress = addresses.isNotEmpty ? addresses.first : null;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: _section(
        title: 'Select delivery address',
        child: addresses.isEmpty
            ? _buildEmptyAddresses(addresses)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: addresses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _buildAddressTile(addresses[index]),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: () => _goAddAddress(addresses),
                      style: _outlinedButtonStyle,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text(
                        'Add a new address',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEmptyAddresses(List<ShippingAddress> addresses) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: _UI.canvas,
        borderRadius: BorderRadius.circular(_UI.radius),
      ),
      child: Column(
        children: [
          const Icon(Icons.location_on_outlined, size: 32, color: _UI.inkSoft),
          const SizedBox(height: 10),
          const Text(
            'No saved addresses',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: _UI.ink,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Add a delivery address to continue.',
            style: TextStyle(fontSize: 13, color: _UI.inkSoft),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: FilledButton.icon(
              onPressed: () => _goAddAddress(addresses),
              style: _primaryButtonStyle,
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                'Add address',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressTile(ShippingAddress addr) {
    final isSelected = _tempSelectedAddress?.id == addr.id;
    return InkWell(
      borderRadius: BorderRadius.circular(_UI.radius),
      onTap: () => setState(() => _tempSelectedAddress = addr),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(_UI.radius),
          border: Border.all(
            color: isSelected ? AppTheme.primary : _UI.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 20,
                color: isSelected ? AppTheme.primary : Colors.grey.shade400,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    addr.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: _UI.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    addr.formattedAddress,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: _UI.body,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Phone: ${addr.phoneNumber}',
                    style: const TextStyle(fontSize: 12.5, color: _UI.inkSoft),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 2: REVIEW
  // ---------------------------------------------------------------------------
  Widget _buildReviewStep(ProfileState profileState, CartState cartState) {
    final subtotal = cartState.totalPrice;
    final shipping = _calculateShipping(subtotal);
    final tax = _calculateTax(subtotal);
    final total = subtotal + shipping + tax;

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Delivery address
          _section(
            title: 'Delivery address',
            trailing: _textAction(
              'Change',
              () => setState(() => _currentStep = 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: _UI.inkSoft,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _tempSelectedAddress?.fullName ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _UI.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _tempSelectedAddress?.formattedAddress ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: _UI.body,
                        ),
                      ),
                      if ((_tempSelectedAddress?.phoneNumber ?? '')
                          .isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Phone: ${_tempSelectedAddress!.phoneNumber}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: _UI.inkSoft,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Items
          _section(
            title: 'Order items (${cartState.items.length})',
            padding: const EdgeInsets.fromLTRB(_UI.pad, _UI.pad, _UI.pad, 4),
            child: Column(
              children: [
                for (int i = 0; i < cartState.items.length; i++) ...[
                  _buildReviewItemRow(cartState.items[i]),
                  if (i != cartState.items.length - 1)
                    const Divider(height: 1, thickness: 1, color: _UI.border),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Payment method
          _section(
            title: 'Payment method',
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_UI.radius),
                border: Border.all(color: _UI.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock_outline, size: 18, color: _UI.success),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Razorpay secure payment',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: _UI.ink,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'UPI, cards, net banking and wallets',
                          style: TextStyle(fontSize: 12, color: _UI.inkSoft),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Price details
          _section(
            title: 'Price details',
            child: Column(
              children: [
                _buildBreakdownRow('Subtotal', subtotal),
                _buildBreakdownRow('Delivery Fee', shipping, freeIfZero: true),
                if (tax > 0) _buildBreakdownRow('Taxes', tax),
                const SizedBox(height: 6),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'All taxes (GST) are included',
                    style: TextStyle(fontSize: 11.5, color: _UI.inkSoft),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1, thickness: 1, color: _UI.border),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total amount',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _UI.ink,
                      ),
                    ),
                    Text(
                      _money(total),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _UI.ink,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(_UI.pad, 14, _UI.pad, 0),
            child: const Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 15,
                  color: _UI.inkSoft,
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Payments are processed securely by Razorpay.',
                    style: TextStyle(fontSize: 12, color: _UI.inkSoft),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItemRow(CartItem item) {
    const placeholder = Icon(
      Icons.image_not_supported_outlined,
      size: 18,
      color: _UI.inkSoft,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _UI.border),
            ),
            child: item.image.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      item.image,
                      fit: BoxFit.cover,
                      cacheWidth: 156,
                      errorBuilder: (_, __, ___) => placeholder,
                    ),
                  )
                : placeholder,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                    color: _UI.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Qty: ${item.quantity}',
                  style: const TextStyle(fontSize: 12, color: _UI.inkSoft),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _money(item.lineTotal),
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: _UI.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(
    String label,
    double amount, {
    bool freeIfZero = false,
  }) {
    final isFree = freeIfZero && amount == 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13.5, color: _UI.inkSoft),
          ),
          Text(
            isFree ? 'Free' : _money(amount),
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: isFree ? _UI.success : _UI.ink,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SUCCESS VIEW
  // ---------------------------------------------------------------------------
  Widget _buildSuccessView(BuildContext context) {
    return Scaffold(
      backgroundColor: _UI.canvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 440),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_UI.radius),
                border: Border.all(color: _UI.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _UI.success.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 30,
                        color: _UI.success,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Order confirmed',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _UI.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your payment was successful. A confirmation email has been sent, and we will notify you when your order ships.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _UI.inkSoft,
                      fontSize: 13.5,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: _UI.canvas,
                      borderRadius: BorderRadius.circular(_UI.radius),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Status: ',
                          style: TextStyle(fontSize: 13, color: _UI.inkSoft),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            _lastPlacedOrderId,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: _UI.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: () {
                        // Navigate to You Tab (index 2)
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const MainNavigationScreen(initialTab: 2),
                          ),
                          (route) => false,
                        );
                      },
                      style: _primaryButtonStyle,
                      child: const Text(
                        'View order status',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const MainNavigationScreen(initialTab: 0),
                          ),
                          (route) => false,
                        );
                      },
                      style: _outlinedButtonStyle,
                      child: const Text(
                        'Continue shopping',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
