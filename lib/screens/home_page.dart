// import 'package:avg_mart/bloc/home/home_cubit.dart';
// import 'package:avg_mart/helper/helper.dart';
// import 'package:avg_mart/models/banner_response.dart';
// import 'package:avg_mart/route_observe.dart';
// import 'package:avg_mart/screens/home/item1.dart';
// import 'package:avg_mart/screens/home/item2.dart';
// import 'package:avg_mart/screens/home/item3.dart';
// import 'package:avg_mart/screens/home/item4.dart';
// import 'package:avg_mart/screens/home/item5.dart';
// import 'package:avg_mart/screens/home/item51.dart';
// import 'package:avg_mart/screens/home/item52.dart';
// import 'package:avg_mart/screens/home/item53.dart';
// import 'package:avg_mart/screens/home/item54.dart';
// import 'package:avg_mart/screens/home/item55.dart';
// import 'package:avg_mart/screens/home/item56.dart';
// import 'package:avg_mart/screens/home/item6.dart';
// import 'package:avg_mart/screens/home/item7.dart';
// import 'package:avg_mart/screens/home/item8.dart';
// import 'package:avg_mart/screens/home/item9.dart';
// import 'package:avg_mart/screens/home/item10.dart';
// import 'package:avg_mart/screens/home/item11.dart';
// import 'package:avg_mart/screens/home/item12.dart';
// import 'package:avg_mart/screens/home/item13.dart';
// import 'package:avg_mart/screens/home/item14.dart';
// import 'package:avg_mart/screens/home/item15.dart';
// import 'package:avg_mart/screens/home/item16.dart';
// import 'package:avg_mart/screens/home/item17.dart';
// import 'package:avg_mart/screens/home/item18.dart';
// import 'package:avg_mart/screens/home/item19.dart';
// import 'package:avg_mart/screens/home/item20.dart';
// import 'package:avg_mart/screens/home/item21.dart';
// import 'package:avg_mart/screens/home/item22.dart';
// import 'package:avg_mart/screens/home/item23.dart';
// import 'package:avg_mart/screens/home/item24.dart';
// import 'package:avg_mart/screens/home/item25.dart';
// import 'package:avg_mart/screens/home/item26.dart';
// import 'package:avg_mart/screens/home/item27.dart';
// import 'package:avg_mart/screens/home/item28.dart';
// import 'package:avg_mart/screens/home/item29.dart';
// import 'package:avg_mart/screens/home/item30.dart';
// import 'package:avg_mart/screens/home/item31.dart';
// import 'package:avg_mart/screens/home/item32.dart';
// import 'package:avg_mart/screens/home/item33.dart';
// import 'package:avg_mart/screens/home/item34.dart';
// import 'package:avg_mart/screens/home/item35.dart';
// import 'package:avg_mart/screens/home/item36.dart';
// import 'package:avg_mart/screens/home/item37.dart';
// import 'package:avg_mart/screens/home/item38.dart';
// import 'package:avg_mart/screens/home/item39.dart';
// import 'package:avg_mart/screens/home/item40.dart';
// import 'package:avg_mart/screens/home/item41.dart';
// import 'package:avg_mart/screens/home/item42.dart';
// import 'package:avg_mart/screens/home/item43.dart';
// import 'package:avg_mart/screens/home/item44.dart';
// import 'package:avg_mart/screens/home/item45.dart';
// import 'package:avg_mart/screens/home/item46.dart';
// import 'package:avg_mart/screens/home/item47.dart';
// import 'package:avg_mart/screens/home/item48.dart';
// import 'package:avg_mart/screens/home/item49.dart';
// import 'package:avg_mart/screens/home/item50.dart';
// import 'package:avg_mart/widgets/location_gate_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../bloc/product/product_cubit.dart';
// import '../bloc/category/category_cubit.dart';
// import '../bloc/cart/cart_cubit.dart';
// import '../bloc/profile/profile_cubit.dart';
// import '../bloc/profile/profile_state.dart';
// import '../models/category_response.dart';
// import '../models/product_response.dart';
// import '../state/app_state.dart';
// import '../theme/app_theme.dart';
// import '../widgets/avg_header.dart';

// import '../widgets/shimmer.dart';
// import 'product_detail_screen.dart';
// import 'search_results_screen.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> with RouteAware {
//   bool _profileFetchTriggered = false;

//   // Sample video used by Item6 (replace with your own video link).
//   static const String _sampleVideoUrl =
//       'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted || _profileFetchTriggered) return;
//       _profileFetchTriggered = true;
//       _fetchAllHomeData();
//     });
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // Subscribe to the RouteObserver so we get didPopNext() callbacks when
//     // a route pushed on top of Home is popped back to Home.
//     final route = ModalRoute.of(context);
//     if (route is PageRoute) {
//       routeObserver.subscribe(this, route);
//     }
//   }

//   @override
//   void dispose() {
//     routeObserver.unsubscribe(this);
//     super.dispose();
//   }

//   /// Called by RouteAware when the user navigates back to Home from a
//   /// screen that was pushed on top of it (ProductDetail, Search results,
//   /// etc. - at any stack depth).
//   @override
//   void didPopNext() {
//     _fetchAllHomeData();
//   }

//   void _fetchAllHomeData() {
//     if (!mounted) return;
//     BlocProvider.of<ProductCubit>(context).fetchProducts();
//     BlocProvider.of<CategoryCubit>(context).fetchCategories();
//     BlocProvider.of<ProfileCubit>(context).fetchProfile();
//     BlocProvider.of<HomeCubit>(context).fetchBanners();
//   }

//   /// Builds the banner image list from real product data instead of mock
//   /// data: prefers featured products' primary image, falling back to the
//   /// first few products if none are marked featured.
//   List<String> _buildBannerImages(List<ProductResponse> allProducts) {
//     final featured = allProducts
//         .where((p) => p.isFeatured ?? false)
//         .map(firstProductImage)
//         .whereType<String>()
//         .take(5)
//         .toList();

//     if (featured.isNotEmpty) return featured;

//     return allProducts
//         .map(firstProductImage)
//         .whereType<String>()
//         .take(5)
//         .toList();
//   }

//   /// Adds a product to the cart via CartCubit (which hits the real
//   /// add-to-cart API and then silently refreshes state), and shows a
//   /// confirmation snackbar. Every "Add to Cart" action across Home routes
//   /// through this one method so the server stays in sync.
//   Future<void> _addProductToCart(
//     BuildContext context,
//     ProductResponse prod,
//   ) async {
//     final sizes = prod.sizes ?? [];
//     final selectedSize = sizes.isNotEmpty ? sizes.first : null;
//     final image = firstProductImage(prod) ?? '';

//     try {
//       await context.read<CartCubit>().addToCart(
//         productId: prod.id.toString(),
//         name: prod.name ?? '',
//         category: prod.category ?? '',
//         price: displayPrice(prod),
//         image: image,
//         selectedSize: selectedSize,
//       );

//       if (!context.mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('${prod.name ?? 'Item'} added to cart!'),
//           duration: const Duration(seconds: 1),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     } catch (e) {
//       if (!context.mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Could not add "${prod.name ?? 'item'}" to cart. Please try again.',
//           ),
//           duration: const Duration(seconds: 2),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//   }

//   void _openProduct(BuildContext context, ProductResponse prod) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (routeContext) => BlocProvider.value(
//           value: BlocProvider.of<CartCubit>(context),
//           child: ProductDetailScreen(
//             productId: prod.id.toString(),
//             title: prod.name ?? '',
//           ),
//         ),
//       ),
//     );
//   }

//   void _openCategory(BuildContext context, CategoryiesResponse cat) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (routeContext) => MultiBlocProvider(
//           providers: [
//             BlocProvider.value(value: BlocProvider.of<ProductCubit>(context)),
//             BlocProvider.value(value: BlocProvider.of<CartCubit>(context)),
//             BlocProvider.value(value: BlocProvider.of<ProfileCubit>(context)),
//           ],
//           child: SearchResultsScreen(
//             searchQuery: '',
//             initialCategory: cat.name ?? '',
//           ),
//         ),
//       ),
//     );
//   }

//   void _openBrand(BuildContext context, String brandName) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (routeContext) => MultiBlocProvider(
//           providers: [
//             BlocProvider.value(value: BlocProvider.of<ProductCubit>(context)),
//             BlocProvider.value(value: BlocProvider.of<CartCubit>(context)),
//             BlocProvider.value(value: BlocProvider.of<ProfileCubit>(context)),
//           ],
//           child: SearchResultsScreen(searchQuery: brandName),
//         ),
//       ),
//     );
//   }

//   void _openDeals(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (routeContext) => MultiBlocProvider(
//           providers: [
//             BlocProvider.value(value: BlocProvider.of<ProductCubit>(context)),
//             BlocProvider.value(value: BlocProvider.of<CartCubit>(context)),
//             BlocProvider.value(value: BlocProvider.of<ProfileCubit>(context)),
//           ],
//           child: const SearchResultsScreen(
//             searchQuery: '',
//             initialCategory: 'Deals',
//           ),
//         ),
//       ),
//     );
//   }

//   void _openBanner(BuildContext context, Banners banner) {
//     final productId = banner.productId;
//     if (productId == null || productId <= 0) {
//       if (banner.title != null && banner.title!.trim().isNotEmpty) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (routeContext) => MultiBlocProvider(
//               providers: [
//                 BlocProvider.value(
//                   value: BlocProvider.of<ProductCubit>(context),
//                 ),
//                 BlocProvider.value(value: BlocProvider.of<CartCubit>(context)),
//                 BlocProvider.value(
//                   value: BlocProvider.of<ProfileCubit>(context),
//                 ),
//               ],
//               child: SearchResultsScreen(searchQuery: banner.title!.trim()),
//             ),
//           ),
//         );
//       }
//       return;
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (routeContext) => BlocProvider.value(
//           value: BlocProvider.of<CartCubit>(context),
//           child: ProductDetailScreen(
//             productId: productId.toString(),
//             title: banner.productName ?? banner.title ?? '',
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final appState = AppStateProvider.of(context);

//     // Shortcuts so every section below uses the same two actions.
//     void onTap(ProductResponse p) => _openProduct(context, p);
//     void onAdd(ProductResponse p) => _addProductToCart(context, p);

//     // LocationGate sits on top of the whole Home screen. Until location is
//     // on and permitted, the user only sees the "Enable location" page.
//     return LocationGate(
//       child: BlocBuilder<HomeCubit, HomeState>(
//         builder: (context, homeState) {
//           final banners = homeState is HomeBannerLoaded
//               ? homeState.banners
//               : <Banners>[];

//           return BlocBuilder<ProfileCubit, ProfileState>(
//             builder: (context, profileState) {
//               if (profileState is ProfileLoaded) {
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   if (!mounted) return;
//                   appState.setAddresses(
//                     profileState.addresses,
//                     primaryAddress: profileState.primaryAddress,
//                   );
//                 });
//               }

//               return BlocBuilder<CategoryCubit, CategoryState>(
//                 builder: (context, categoryState) {
//                   return BlocBuilder<ProductCubit, ProductState>(
//                     builder: (context, productState) {
//                       if (productState is ProductLoading ||
//                           categoryState is CategoryLoading) {
//                         return const Scaffold(
//                           appBar: AvgHeader(isReadOnly: true),
//                           backgroundColor: Colors.white,
//                           body: HomeShimmerSkeleton(),
//                         );
//                       }

//                       if (productState is ProductError ||
//                           categoryState is CategoryError) {
//                         final errorMsg = productState is ProductError
//                             ? productState.message
//                             : (categoryState as CategoryError).message;
//                         return Scaffold(
//                           body: Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text('Error: $errorMsg'),
//                                 const SizedBox(height: 16),
//                                 ElevatedButton(
//                                   onPressed: _fetchAllHomeData,
//                                   child: const Text('Retry'),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       }

//                       final List<ProductResponse> allProducts =
//                           productState is ProductLoaded
//                           ? productState.products
//                           : [];
//                       final List<CategoryiesResponse> categoriesList =
//                           categoryState is CategoryLoaded
//                           ? categoryState.categories
//                           : [];

//                       final dealProducts = allProducts
//                           .where((p) => p.isFeatured ?? false)
//                           .toList();
//                       // Featured products if there are any, otherwise all.
//                       final featuredOrAll = dealProducts.isNotEmpty
//                           ? dealProducts
//                           : allProducts;
//                       final featuredProducts = allProducts.length > 4
//                           ? allProducts.take(4).toList()
//                           : allProducts;

//                       return Scaffold(
//                         appBar: const AvgHeader(isReadOnly: true),
//                         backgroundColor: AppTheme.background,
//                         body: SingleChildScrollView(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.stretch,
//                             children: [
//                               const SizedBox(height: 8),
//                               Item2(
//                                 banners: banners,
//                                 onBannerTap: (b) => _openBanner(context, b),
//                               ),
//                               const SizedBox(height: 16),
//                               Item1(
//                                 categories: categoriesList,
//                                 onCategoryTap: (cat) =>
//                                     _openCategory(context, cat),
//                               ),
//                               const SizedBox(height: 16),
//                               Item3(
//                                 categories: categoriesList,
//                                 onCategoryTap: (cat) =>
//                                     _openCategory(context, cat),
//                               ),
//                               const SizedBox(height: 16),
//                               if (featuredProducts.isNotEmpty) ...[
//                                 Item4(
//                                   products: featuredProducts,
//                                   onProductTap: onTap,
//                                   onAddToCart: onAdd,
//                                 ),
//                                 const SizedBox(height: 16),
//                               ],
//                               Item5(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item6(
//                                 videoUrl: _sampleVideoUrl,
//                                 products: featuredOrAll,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item7(
//                                 products: featuredOrAll,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item8(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item9(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item10(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item11(
//                                 products: featuredOrAll,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item12(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item13(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item14(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item15(
//                                 products: allProducts,
//                                 onSeeAll: (category) =>
//                                     _openBrand(context, category),
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item16(
//                                 products: featuredOrAll,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item17(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item18(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item19(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item20(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item21(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item22(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item23(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item24(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item25(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item26(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item27(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item28(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item29(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item30(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item31(
//                                 products: featuredOrAll,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item32(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item33(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item34(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item35(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item36(
//                                 products: featuredOrAll,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item37(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item38(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item39(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item40(
//                                 products: allProducts,
//                                 cartTotal: 0, // TODO: pass your real cart total
//                                 freeDeliveryAt: 999,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item41(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item42(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item43(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item44(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item45(
//                                 products: featuredOrAll,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item46(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item47(
//                                 products: allProducts,
//                                 onCategoryTap: (category) =>
//                                     _openBrand(context, category),
//                               ),
//                               const SizedBox(height: 16),
//                               Item48(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item49(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item50(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               const SizedBox(height: 16),
//                               Item51(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 // onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item52(
//                                 products: featuredOrAll,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item53(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item54(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item55(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),
//                               Item56(
//                                 products: allProducts,
//                                 onProductTap: onTap,
//                                 onAddToCart: onAdd,
//                               ),
//                               const SizedBox(height: 16),

//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:avg_mart/bloc/home/home_cubit.dart';
import 'package:avg_mart/helper/helper.dart';
import 'package:avg_mart/models/banner_response.dart';
import 'package:avg_mart/route_observe.dart';
import 'package:avg_mart/screens/home/item1.dart';
import 'package:avg_mart/screens/home/item2.dart';
import 'package:avg_mart/screens/home/item3.dart';
import 'package:avg_mart/screens/home/item4.dart';
import 'package:avg_mart/screens/home/item5.dart';
import 'package:avg_mart/screens/home/item6.dart';
import 'package:avg_mart/screens/home/item7.dart';
import 'package:avg_mart/screens/home/item8.dart';
import 'package:avg_mart/screens/home/item9.dart';
import 'package:avg_mart/screens/home/item10.dart';
import 'package:avg_mart/screens/home/item11.dart';
import 'package:avg_mart/screens/home/item12.dart';
import 'package:avg_mart/screens/home/item13.dart';
import 'package:avg_mart/screens/home/item14.dart';
import 'package:avg_mart/screens/home/item15.dart';
import 'package:avg_mart/screens/home/item16.dart';
import 'package:avg_mart/screens/home/item17.dart';
import 'package:avg_mart/screens/home/item18.dart';
import 'package:avg_mart/screens/home/item19.dart';
import 'package:avg_mart/screens/home/item20.dart';
import 'package:avg_mart/screens/home/item21.dart';
import 'package:avg_mart/screens/home/item22.dart';
import 'package:avg_mart/screens/home/item23.dart';
import 'package:avg_mart/screens/home/item24.dart';
import 'package:avg_mart/screens/home/item25.dart';
import 'package:avg_mart/screens/home/item26.dart';
import 'package:avg_mart/screens/home/item27.dart';
import 'package:avg_mart/screens/home/item28.dart';
import 'package:avg_mart/screens/home/item29.dart';
import 'package:avg_mart/screens/home/item30.dart';
import 'package:avg_mart/screens/home/item31.dart';
import 'package:avg_mart/screens/home/item32.dart';
import 'package:avg_mart/screens/home/item33.dart';
import 'package:avg_mart/screens/home/item34.dart';
import 'package:avg_mart/screens/home/item35.dart';
import 'package:avg_mart/screens/home/item36.dart';
import 'package:avg_mart/screens/home/item37.dart';
import 'package:avg_mart/screens/home/item38.dart';
import 'package:avg_mart/screens/home/item39.dart';
import 'package:avg_mart/screens/home/item40.dart';
import 'package:avg_mart/screens/home/item41.dart';
import 'package:avg_mart/screens/home/item42.dart';
import 'package:avg_mart/screens/home/item43.dart';
import 'package:avg_mart/screens/home/item44.dart';
import 'package:avg_mart/screens/home/item45.dart';
import 'package:avg_mart/screens/home/item46.dart';
import 'package:avg_mart/screens/home/item47.dart';
import 'package:avg_mart/screens/home/item48.dart';
import 'package:avg_mart/screens/home/item49.dart';
import 'package:avg_mart/screens/home/item50.dart';
import 'package:avg_mart/screens/home/item51.dart';
import 'package:avg_mart/screens/home/item52.dart';
import 'package:avg_mart/screens/home/item53.dart';
import 'package:avg_mart/screens/home/item54.dart';
import 'package:avg_mart/screens/home/item55.dart';
import 'package:avg_mart/screens/home/item56.dart';
import 'package:avg_mart/screens/home/item57.dart';
import 'package:avg_mart/screens/home/item58.dart';
import 'package:avg_mart/screens/home/item59.dart';
import 'package:avg_mart/screens/home/item60.dart';
import 'package:avg_mart/screens/home/item61.dart';
import 'package:avg_mart/screens/home/item62.dart';
import 'package:avg_mart/screens/home/item63.dart';
import 'package:avg_mart/screens/home/item64.dart';
import 'package:avg_mart/screens/home/item65.dart';
import 'package:avg_mart/screens/home/item66.dart';
import 'package:avg_mart/screens/home/item67.dart';
import 'package:avg_mart/screens/home/item68.dart';
import 'package:avg_mart/screens/home/item69.dart';
import 'package:avg_mart/screens/home/item70.dart';
import 'package:avg_mart/screens/home/item71.dart';
import 'package:avg_mart/screens/home/item72.dart';
import 'package:avg_mart/screens/home/item73.dart';
import 'package:avg_mart/screens/home/item74.dart';
import 'package:avg_mart/screens/home/item75.dart';
import 'package:avg_mart/screens/home/item76.dart';
import 'package:avg_mart/screens/home/item77.dart';
import 'package:avg_mart/screens/home/item78.dart';
import 'package:avg_mart/screens/home/item79.dart';
import 'package:avg_mart/screens/home/item80.dart';
import 'package:avg_mart/screens/home/item81.dart';
import 'package:avg_mart/screens/home/item82.dart';
import 'package:avg_mart/screens/home/item83.dart';
import 'package:avg_mart/screens/home/item84.dart';
import 'package:avg_mart/screens/home/item85.dart';
import 'package:avg_mart/screens/home/item86.dart';
import 'package:avg_mart/screens/home/item87.dart';
import 'package:avg_mart/screens/home/item88.dart';
import 'package:avg_mart/screens/home/item89.dart';
import 'package:avg_mart/screens/home/item90.dart';
import 'package:avg_mart/screens/home/item91.dart';
import 'package:avg_mart/screens/home/item92.dart';
import 'package:avg_mart/screens/home/item93.dart';
import 'package:avg_mart/screens/home/item94.dart';
import 'package:avg_mart/screens/home/item95.dart';
import 'package:avg_mart/screens/home/item96.dart';
import 'package:avg_mart/screens/home/item97.dart';
import 'package:avg_mart/screens/home/item98.dart';
import 'package:avg_mart/screens/home/item99.dart';
import 'package:avg_mart/screens/home/item100.dart';
import 'package:avg_mart/screens/home/item101.dart';
import 'package:avg_mart/screens/home/item102.dart';
import 'package:avg_mart/screens/home/item103.dart';
import 'package:avg_mart/screens/home/item104.dart';
import 'package:avg_mart/screens/home/item105.dart';
import 'package:avg_mart/screens/home/item106.dart';
import 'package:avg_mart/screens/home/item107.dart';
import 'package:avg_mart/screens/home/item108.dart';
import 'package:avg_mart/screens/home/item109.dart';
import 'package:avg_mart/screens/home/item110.dart';
import 'package:avg_mart/screens/home/item111.dart';
import 'package:avg_mart/screens/home/item112.dart';
import 'package:avg_mart/screens/home/item113.dart';
import 'package:avg_mart/screens/home/item114.dart';
import 'package:avg_mart/screens/home/item115.dart';
import 'package:avg_mart/screens/home/item116.dart';
import 'package:avg_mart/screens/home/item117.dart';
import 'package:avg_mart/screens/home/item118.dart';
import 'package:avg_mart/screens/home/item119.dart';
import 'package:avg_mart/screens/home/item120.dart';
import 'package:avg_mart/screens/home/item121.dart';
import 'package:avg_mart/screens/home/item122.dart';
import 'package:avg_mart/screens/home/item123.dart';
import 'package:avg_mart/screens/home/item124.dart';
import 'package:avg_mart/screens/home/item125.dart';
import 'package:avg_mart/screens/home/item126.dart';
import 'package:avg_mart/screens/home/item127.dart';
import 'package:avg_mart/screens/home/item128.dart';
import 'package:avg_mart/screens/home/item129.dart';
import 'package:avg_mart/screens/home/item130.dart';
import 'package:avg_mart/screens/home/item131.dart';
import 'package:avg_mart/screens/home/item132.dart';
import 'package:avg_mart/screens/home/item133.dart';
import 'package:avg_mart/screens/home/item134.dart';
import 'package:avg_mart/screens/home/item135.dart';
import 'package:avg_mart/screens/home/item136.dart';
import 'package:avg_mart/screens/home/item137.dart';
import 'package:avg_mart/screens/home/item138.dart';
import 'package:avg_mart/screens/home/item139.dart';
import 'package:avg_mart/screens/home/item140.dart';
import 'package:avg_mart/screens/home/item141.dart';
import 'package:avg_mart/screens/home/item142.dart';
import 'package:avg_mart/screens/home/item143.dart';
import 'package:avg_mart/screens/home/item144.dart';
import 'package:avg_mart/screens/home/item145.dart';
import 'package:avg_mart/screens/home/item146.dart';
import 'package:avg_mart/screens/home/item147.dart';
import 'package:avg_mart/screens/home/item148.dart';
import 'package:avg_mart/screens/home/item149.dart';
import 'package:avg_mart/screens/home/item150.dart';
import 'package:avg_mart/screens/home/item151.dart';
import 'package:avg_mart/screens/home/item152.dart';
import 'package:avg_mart/screens/home/item153.dart';
import 'package:avg_mart/screens/home/item154.dart';
import 'package:avg_mart/screens/home/item155.dart';
import 'package:avg_mart/screens/home/item156.dart';
import 'package:avg_mart/screens/home/item157.dart';
import 'package:avg_mart/screens/home/item158.dart';
import 'package:avg_mart/screens/home/item159.dart';
import 'package:avg_mart/screens/home/item160.dart';
import 'package:avg_mart/screens/home/item161.dart';
import 'package:avg_mart/screens/home/item162.dart';
import 'package:avg_mart/screens/home/item163.dart';
import 'package:avg_mart/screens/home/item164.dart';
import 'package:avg_mart/screens/home/item165.dart';
import 'package:avg_mart/screens/home/item166.dart';
import 'package:avg_mart/screens/home/item167.dart';
import 'package:avg_mart/screens/home/item168.dart';
import 'package:avg_mart/screens/home/item169.dart';
import 'package:avg_mart/screens/home/item170.dart';
import 'package:avg_mart/screens/home/item171.dart';
import 'package:avg_mart/screens/home/item172.dart';
import 'package:avg_mart/screens/home/item173.dart';
import 'package:avg_mart/screens/home/item174.dart';
import 'package:avg_mart/screens/home/item175.dart';
import 'package:avg_mart/screens/home/item176.dart';
import 'package:avg_mart/screens/home/item177.dart';
import 'package:avg_mart/screens/home/item178.dart';
import 'package:avg_mart/screens/home/item179.dart';
import 'package:avg_mart/screens/home/item180.dart';
import 'package:avg_mart/screens/home/item181.dart';
import 'package:avg_mart/screens/home/item182.dart';
import 'package:avg_mart/screens/home/item183.dart';
import 'package:avg_mart/screens/home/item184.dart';
import 'package:avg_mart/screens/home/item185.dart';
import 'package:avg_mart/screens/home/item186.dart';
import 'package:avg_mart/screens/home/item187.dart';
import 'package:avg_mart/screens/home/item188.dart';
import 'package:avg_mart/screens/home/item189.dart';
import 'package:avg_mart/screens/home/item190.dart';
import 'package:avg_mart/screens/home/item191.dart';
import 'package:avg_mart/screens/home/item192.dart';
import 'package:avg_mart/screens/home/item193.dart';
import 'package:avg_mart/screens/home/item194.dart';
import 'package:avg_mart/screens/home/item195.dart';
import 'package:avg_mart/screens/home/item196.dart';
import 'package:avg_mart/screens/home/item197.dart';
import 'package:avg_mart/screens/home/item198.dart';
import 'package:avg_mart/screens/home/item199.dart';
import 'package:avg_mart/screens/home/item200.dart';
import 'package:avg_mart/screens/home/item201.dart';
import 'package:avg_mart/screens/home/item202.dart';
import 'package:avg_mart/screens/home/item203.dart';
import 'package:avg_mart/screens/home/item204.dart';
import 'package:avg_mart/screens/home/item205.dart';
import 'package:avg_mart/screens/home/item206.dart';
import 'package:avg_mart/widgets/location_gate_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cart/cart_cubit.dart';
import '../bloc/category/category_cubit.dart';
import '../bloc/product/product_cubit.dart';
import '../bloc/profile/profile_cubit.dart';
import '../bloc/profile/profile_state.dart';
import '../models/category_response.dart';
import '../models/product_response.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/avg_header.dart';
import '../widgets/shimmer.dart';
import 'product_detail_screen.dart';
import 'search_results_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  static const String _sampleVideoUrl =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

  bool _initialFetchDone = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _initialFetchDone) return;
      _initialFetchDone = true;
      _fetchAllHomeData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  /// Refresh data when the user comes back to Home from any pushed screen.
  @override
  void didPopNext() => _fetchAllHomeData();

  void _fetchAllHomeData() {
    if (!mounted) return;
    context.read<ProductCubit>().fetchProducts();
    context.read<CategoryCubit>().fetchCategories();
    context.read<ProfileCubit>().fetchProfile();
    context.read<HomeCubit>().fetchBanners();
  }

  Future<void> _addProductToCart(
    BuildContext context,
    ProductResponse prod,
  ) async {
    final sizes = prod.sizes ?? [];
    final selectedSize = sizes.isNotEmpty ? sizes.first : null;
    final name = prod.name ?? 'item';

    try {
      await context.read<CartCubit>().addToCart(
        productId: prod.id.toString(),
        name: prod.name ?? '',
        category: prod.category ?? '',
        price: displayPrice(prod),
        image: firstProductImage(prod) ?? '',
        selectedSize: selectedSize,
      );
      _showSnack(context, '$name added to cart!', seconds: 1);
    } catch (_) {
      _showSnack(
        context,
        'Could not add "$name" to cart. Please try again.',
        seconds: 2,
      );
    }
  }

  void _showSnack(
    BuildContext context,
    String message, {
    required int seconds,
  }) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: seconds),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openProduct(BuildContext context, ProductResponse prod) {
    _openProductById(context, prod.id.toString(), prod.name ?? '');
  }

  void _openProductById(BuildContext context, String id, String title) {
    final cartCubit = context.read<CartCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cartCubit,
          child: ProductDetailScreen(productId: id, title: title),
        ),
      ),
    );
  }

  /// Opens the search results screen with all the cubits it needs.
  void _openSearch(
    BuildContext context, {
    String query = '',
    String? category,
  }) {
    final productCubit = context.read<ProductCubit>();
    final cartCubit = context.read<CartCubit>();
    final profileCubit = context.read<ProfileCubit>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: productCubit),
            BlocProvider.value(value: cartCubit),
            BlocProvider.value(value: profileCubit),
          ],
          child: category == null
              ? SearchResultsScreen(searchQuery: query)
              : SearchResultsScreen(
                  searchQuery: query,
                  initialCategory: category,
                ),
        ),
      ),
    );
  }

  void _openCategory(BuildContext context, CategoryiesResponse cat) =>
      _openSearch(context, category: cat.name ?? '');

  void _openBrand(BuildContext context, String brandName) =>
      _openSearch(context, query: brandName);

  void _openBanner(BuildContext context, Banners banner) {
    final productId = banner.productId;
    if (productId != null && productId > 0) {
      _openProductById(
        context,
        productId.toString(),
        banner.productName ?? banner.title ?? '',
      );
      return;
    }

    final title = banner.title?.trim() ?? '';
    if (title.isNotEmpty) _openSearch(context, query: title);
  }

  /// Home sections. Each entry is built lazily by the ListView below, so
  /// only the sections near the viewport are created.
  List<WidgetBuilder> _buildSections({
    required List<ProductResponse> allProducts,
    required List<ProductResponse> featuredOrAll,
    required List<ProductResponse> topProducts,
    required List<Banners> banners,
    required List<CategoryiesResponse> categories,
  }) {
    void onTap(BuildContext c, ProductResponse p) => _openProduct(c, p);
    void onAdd(BuildContext c, ProductResponse p) => _addProductToCart(c, p);

    return <WidgetBuilder>[
      (c) => Item2(banners: banners, onBannerTap: (b) => _openBanner(c, b)),
      (c) => Item1(
        categories: categories,
        onCategoryTap: (cat) => _openCategory(c, cat),
      ),
      (c) => Item3(
        categories: categories,
        onCategoryTap: (cat) => _openCategory(c, cat),
      ),
      if (topProducts.isNotEmpty)
        (c) => Item4(
          products: topProducts,
          onProductTap: (p) => onTap(c, p),
          onAddToCart: (p) => onAdd(c, p),
        ),
      (c) => Item5(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item6(
        videoUrl: _sampleVideoUrl,
        products: featuredOrAll,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item7(
        products: featuredOrAll,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item8(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item9(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item10(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item11(
        products: featuredOrAll,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item12(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item13(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item14(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item15(
        products: allProducts,
        onSeeAll: (category) => _openBrand(c, category),
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item16(
        products: featuredOrAll,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item17(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item18(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item19(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item20(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item21(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item22(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item23(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item24(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item25(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item26(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item27(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item28(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item29(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item30(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item31(
        products: featuredOrAll,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item32(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item33(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item34(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item35(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item36(
        products: featuredOrAll,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item37(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item38(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item39(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item40(
        products: allProducts,
        cartTotal: 0, // TODO: pass your real cart total
        freeDeliveryAt: 999,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item41(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item42(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item43(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item44(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item45(
        products: featuredOrAll,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item46(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item47(
        products: allProducts,
        onCategoryTap: (category) => _openBrand(c, category),
      ),
      (c) => Item48(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item49(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item50(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item51(products: allProducts, onProductTap: (p) => onTap(c, p)),
      (c) => Item52(
        products: featuredOrAll,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item53(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item54(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item55(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item56(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item57(
        products: featuredOrAll,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item58(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item59(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item60(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item61(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item62(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item63(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item64(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item65(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item66(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item67(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item68(
        products: featuredOrAll,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item69(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item70(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item71(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item72(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item73(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item74(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item75(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item76(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item77(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item78(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item79(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item80(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item81(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item82(
        products: featuredOrAll,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item83(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item84(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item85(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item86(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item87(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item88(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item89(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item90(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item91(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item92(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item93(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item94(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item95(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item96(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item97(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item98(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item99(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item100(
        products: featuredOrAll,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item101(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item102(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item103(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item104(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item105(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item106(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item107(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item108(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item109(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item110(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item111(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item112(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item113(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item114(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item115(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item116(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item117(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item118(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item119(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item120(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item121(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item122(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item123(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item124(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item125(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item126(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item127(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item128(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item129(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item130(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item131(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item132(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item133(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item134(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item135(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item136(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item137(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item138(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item139(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item140(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item141(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item142(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item143(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item144(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item145(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item146(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item147(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item148(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item149(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item150(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item151(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item152(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item153(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item154(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item155(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item156(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item157(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item158(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item159(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item160(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item161(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item162(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item163(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item164(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item165(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item166(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item167(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item168(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item169(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item170(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item171(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item172(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item173(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item174(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item175(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item176(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item177(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item178(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item179(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item180(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item181(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item182(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item183(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item184(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item185(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item186(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item187(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item188(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item189(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item190(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item191(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item192(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item193(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item194(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item195(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item196(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item197(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item198(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item199(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item200(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item201(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item202(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item203(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item204(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item205(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
      (c) => Item206(
        products: allProducts,
        onProductTap: (p) => onTap(c, p),
        onAddToCart: (p) => onAdd(c, p),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);

    return LocationGate(
      // Side effect (saving addresses) lives in a listener, not in build.
      child: BlocListener<ProfileCubit, ProfileState>(
        listenWhen: (_, current) => current is ProfileLoaded,
        listener: (_, state) {
          if (state is ProfileLoaded) {
            appState.setAddresses(
              state.addresses,
              primaryAddress: state.primaryAddress,
            );
          }
        },
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, homeState) {
            final banners = homeState is HomeBannerLoaded
                ? homeState.banners
                : <Banners>[];

            return BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, categoryState) {
                return BlocBuilder<ProductCubit, ProductState>(
                  builder: (context, productState) {
                    if (productState is ProductLoading ||
                        categoryState is CategoryLoading) {
                      return const Scaffold(
                        appBar: AvgHeader(isReadOnly: true),
                        backgroundColor: Colors.white,
                        body: HomeShimmerSkeleton(),
                      );
                    }

                    if (productState is ProductError ||
                        categoryState is CategoryError) {
                      final errorMsg = productState is ProductError
                          ? productState.message
                          : (categoryState as CategoryError).message;
                      return Scaffold(
                        body: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Error: $errorMsg'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _fetchAllHomeData,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final allProducts = productState is ProductLoaded
                        ? productState.products
                        : <ProductResponse>[];
                    final categories = categoryState is CategoryLoaded
                        ? categoryState.categories
                        : <CategoryiesResponse>[];

                    final dealProducts = allProducts
                        .where((p) => p.isFeatured ?? false)
                        .toList();
                    final featuredOrAll = dealProducts.isNotEmpty
                        ? dealProducts
                        : allProducts;
                    final topProducts = allProducts.take(4).toList();

                    final sections = _buildSections(
                      allProducts: allProducts,
                      featuredOrAll: featuredOrAll,
                      topProducts: topProducts,
                      banners: banners,
                      categories: categories,
                    );

                    return Scaffold(
                      appBar: const AvgHeader(isReadOnly: true),
                      backgroundColor: AppTheme.background,
                      body: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: sections.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) =>
                            sections[index](context),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
