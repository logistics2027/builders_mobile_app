import 'package:avg_mart/models/order_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/orders/orders_cubit.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/avg_header.dart';
import '../widgets/review_dialog.dart';
import 'login_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  // Order whose details panel is open.
  String? _expandedOrderId;

  // Palette for the orders UI.
  static const Color _teal = Color(0xFF1E3A8A);
  static const Color _ink = Color(0xFF1F2937);
  static const Color _subtle = Color(0xFF6B7280);
  static const Color _line = Color(0xFFE5E7EB);

  static const _stepNames = ['Preparing', 'Dispatched', 'Delivered'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final appState = AppStateProvider.of(context);
      if (appState.isLoggedIn) {
        BlocProvider.of<OrdersCubit>(context).fetchOrders();
      }
    });
  }

  // ───────────────────────── HELPERS ─────────────────────────

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// 0 = preparing, 1 = dispatched, 2 = delivered
  int _statusStep(String status) {
    final s = status.toLowerCase().replaceAll(RegExp(r'[\s_\-]'), '');
    switch (s) {
      case 'shipped':
      case 'dispatched':
      case 'intransit':
      case 'outfordelivery':
        return 1;
      case 'delivered':
        return 2;
      default:
        return 0;
    }
  }

  Color _stepColor(int step) {
    switch (step) {
      case 1:
        return const Color(0xFF2563EB);
      case 2:
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFFEA580C);
    }
  }

  void _openReviewDialog(BuildContext context, OrderResponse order) {
    final firstItem = order.items?.isNotEmpty == true
        ? order.items!.first
        : null;
    if (firstItem == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: BlocProvider.of<OrdersCubit>(context),
        child: ReviewDialog(
          productId: firstItem.productId.toString(),
          productName: firstItem.name ?? 'Product',
        ),
      ),
    );
  }

  // ───────────────────────── BUILD ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);

    return Scaffold(
      appBar: const AvgHeader(isReadOnly: true),
      backgroundColor: Colors.grey.shade100,
      body: !appState.isLoggedIn
          ? SingleChildScrollView(child: _buildSignInPrompt(context))
          : RefreshIndicator(
              onRefresh: () async {
                await BlocProvider.of<OrdersCubit>(context).fetchOrders();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: BlocBuilder<OrdersCubit, OrdersState>(
                  builder: (context, ordersState) {
                    if (ordersState is OrdersLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final List<OrderResponse> orders = switch (ordersState) {
                      OrdersLoaded s => s.orders,
                      ReviewSubmitting s => s.orders,
                      ReviewSubmitSuccess s => s.orders,
                      ReviewSubmitFailure s => s.orders,
                      _ => <OrderResponse>[],
                    };

                    final String? errorMessage = ordersState is OrdersError
                        ? ordersState.message
                        : null;

                    return Column(
                      children: [
                        _buildOrdersSection(orders, errorMessage),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildSignInPrompt(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          const Icon(Icons.lock_outline, size: 40, color: AppTheme.accent),
          const SizedBox(height: 10),
          const Text(
            'Sign in to see your orders',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── ORDERS UI ─────────────────────────

  Widget _buildOrdersSection(List<OrderResponse> orders, String? errorMessage) {
    if (errorMessage != null && orders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(child: Text('Error: $errorMessage')),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_outlined, color: _teal, size: 20),
              const SizedBox(width: 8),
              const Text(
                'My Orders',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              const SizedBox(width: 8),
              if (orders.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${orders.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _teal,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (orders.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _line),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 36,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No orders yet',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              separatorBuilder: (c, i) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _buildOrderCard(context, orders[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderResponse order) {
    final status = order.status ?? 'Ordered';
    final step = _statusStep(status);
    final color = _stepColor(step);
    final items = order.items ?? const <Item>[];
    final first = items.isNotEmpty ? items.first : null;
    final extra = items.length > 1 ? items.length - 1 : 0;
    final total = double.tryParse(order.totalPrice ?? '') ?? 0.0;
    final isExpanded = _expandedOrderId == order.id;
    final estimated = order.createdAt?.add(const Duration(days: 6));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: Column(
        children: [
          // ── Header: thumbnail + title + status ──
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            onTap: () =>
                setState(() => _expandedOrderId = isExpanded ? null : order.id),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildThumb(first?.image, extra),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          first?.name ?? 'Order',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: _ink,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.createdAt != null
                              ? 'Ordered ${_formatDate(order.createdAt)}'
                              : '#${order.id ?? ''}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: _subtle,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _stepNames[step],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '₹${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: _ink,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Horizontal progress tracker ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: _buildStepper(step, color),
          ),

          // ── Expand toggle ──
          InkWell(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
            onTap: () =>
                setState(() => _expandedOrderId = isExpanded ? null : order.id),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: _line)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isExpanded ? 'Hide details' : 'View details',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: _teal,
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 18,
                    color: _teal,
                  ),
                ],
              ),
            ),
          ),

          // ── Details panel ──
          if (isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
                border: const Border(top: BorderSide(color: _line)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.id ?? ''}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: _subtle,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (int i = 0; i < items.length; i++) ...[
                    _buildItemRow(items[i]),
                    if (i != items.length - 1)
                      const Divider(height: 18, color: _line),
                  ],
                  if (step < 2 && estimated != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 15,
                            color: Color(0xFF166534),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Arrives by ${_formatDate(estimated)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF166534),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (step == 2) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _openReviewDialog(context, order),
                      icon: const Icon(Icons.star_outline_rounded, size: 16),
                      label: const Text(
                        'Rate & review',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _teal,
                        side: const BorderSide(color: _teal),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildThumb(String? imageUrl, int extra) {
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
            image: hasImage
                ? DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: hasImage
              ? null
              : const Icon(Icons.shopping_bag_outlined, color: Colors.grey),
        ),
        if (extra > 0)
          Positioned(
            right: -6,
            bottom: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _ink,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(
                '+$extra',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Compact horizontal stepper: 3 nodes joined by bars, labels underneath.
  Widget _buildStepper(int step, Color activeColor) {
    Widget node(int i) {
      final done = i < step || (i == step && step == 2);
      final active = i == step && step < 2;
      return Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: done ? activeColor : Colors.white,
          border: Border.all(
            color: (done || active) ? activeColor : _line,
            width: 2,
          ),
        ),
        child: done
            ? const Icon(Icons.check, size: 13, color: Colors.white)
            : active
            ? Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: activeColor,
                  ),
                ),
              )
            : null,
      );
    }

    Widget bar(int i) => Expanded(
      child: Container(
        height: 3,
        decoration: BoxDecoration(
          color: i < step ? activeColor : _line,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );

    TextStyle labelStyle(int i) => TextStyle(
      fontSize: 10.5,
      fontWeight: i == step ? FontWeight.w700 : FontWeight.w500,
      color: i <= step ? _ink : Colors.grey.shade400,
    );

    return Column(
      children: [
        Row(children: [node(0), bar(0), node(1), bar(1), node(2)]),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_stepNames[0], style: labelStyle(0)),
            Text(_stepNames[1], style: labelStyle(1)),
            Text(_stepNames[2], style: labelStyle(2)),
          ],
        ),
      ],
    );
  }

  Widget _buildItemRow(Item item) {
    final imageUrl = item.image ?? '';
    final price = item.price ?? 0;
    final quantity = item.quantity ?? 1;
    final hasSize =
        item.selectedSize != null && item.selectedSize!.trim().isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _line),
            image: imageUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: imageUrl.isEmpty
              ? const Icon(
                  Icons.shopping_bag_outlined,
                  size: 18,
                  color: Colors.grey,
                )
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name ?? 'Product',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                hasSize
                    ? 'Qty $quantity  •  Size ${item.selectedSize}'
                    : 'Qty $quantity',
                style: const TextStyle(fontSize: 11, color: _subtle),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '₹$price',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
      ],
    );
  }
}
