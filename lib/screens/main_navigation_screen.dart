import 'package:avg_mart/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../service/api_service.dart';
import '../bloc/product/product_cubit.dart';
import '../bloc/category/category_cubit.dart';
import '../bloc/cart/cart_cubit.dart';
import '../bloc/orders/orders_cubit.dart';
import '../bloc/profile/profile_cubit.dart';
import '../bloc/login/login_cubit.dart';
import '../bloc/home/home_cubit.dart';
import '../theme/app_theme.dart';
import 'subcategory_explore_screen.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';
import 'order_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  final int initialTab;
  const MainNavigationScreen({super.key, this.initialTab = 0});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductCubit>(create: (_) => ProductCubit(apiService)),
        BlocProvider<CategoryCubit>(
          create: (_) => CategoryCubit(apiService: apiService),
        ),
        BlocProvider<CartCubit>(create: (_) => CartCubit(apiService)),
        BlocProvider<OrdersCubit>(create: (_) => OrdersCubit(apiService)),
        BlocProvider<ProfileCubit>(
          create: (_) => ProfileCubit(apiService: apiService),
        ),
        BlocProvider<LoginCubit>(
          create: (_) => LoginCubit(apiService: apiService),
        ),
        // NOTE: adjust this call if HomeCubit's constructor signature differs
        // (e.g. HomeCubit(apiService) instead of HomeCubit(apiService: apiService)).
        BlocProvider<HomeCubit>(
          create: (_) => HomeCubit(apiService: apiService),
        ),
      ],
      child: _MainNavigationScreenView(initialTab: initialTab),
    );
  }
}

class _MainNavigationScreenView extends StatefulWidget {
  final int initialTab;
  const _MainNavigationScreenView({this.initialTab = 0});

  @override
  State<_MainNavigationScreenView> createState() =>
      _MainNavigationScreenViewState();
}

class _MainNavigationScreenViewState extends State<_MainNavigationScreenView> {
  late int _currentIndex;

  static const int _homeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CartCubit>().fetchCart();
      }
    });
  }

  final List<Widget> _screens = const [
    HomePage(),
    SubCategoryExploreScreen(),

    CartScreen(),
    OrderScreen(),
    ProfileScreen(),
  ];

  /// Re-fetches everything Home depends on.
  ///
  /// HomeScreen lives inside an IndexedStack, so it's built once and kept
  /// alive forever — its initState() (where the original fetch calls live)
  /// only fires the very first time the Home tab is shown. Switching away
  /// and back does NOT rebuild HomeScreen, so without this, product /
  /// category / banner / profile data goes stale after the first load.
  ///
  /// Calling the cubits directly from here (the parent that owns them)
  /// works regardless of whether HomeScreen itself rebuilds.
  void _refetchHomeData() {
    context.read<ProductCubit>().fetchProducts();
    context.read<CategoryCubit>().fetchCategories();
    context.read<ProfileCubit>().fetchProfile();
    context.read<HomeCubit>().fetchBanners();
  }

  void _onTabTapped(int index) {
    final isReturningToHome =
        index == _homeTabIndex && _currentIndex != _homeTabIndex;

    setState(() {
      _currentIndex = index;
    });

    // Only refetch when *coming back* to Home from another tab — avoids a
    // redundant duplicate fetch on the very first load (HomeScreen's own
    // initState already handles that one).
    if (isReturningToHome) {
      _refetchHomeData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = context.watch<CartCubit>().state;
    final cartCount = cartState.totalItems;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: Colors.black87,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          iconSize: 26,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home, color: AppTheme.primary),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.category_outlined),
              activeIcon: Icon(Icons.category, color: AppTheme.primary),
              label: 'Categories',
            ),

            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart_outlined),
                  if (cartCount > 0)
                    Positioned(
                      right: -8,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          cartCount > 99 ? '99+' : '$cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              activeIcon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart, color: AppTheme.primary),
                  if (cartCount > 0)
                    Positioned(
                      right: -8,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          cartCount > 99 ? '99+' : '$cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Cart',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              activeIcon: Icon(Icons.receipt_long, color: AppTheme.primary),
              label: 'Orders',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person, color: AppTheme.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
