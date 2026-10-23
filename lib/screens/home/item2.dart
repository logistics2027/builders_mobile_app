import 'dart:async';
import 'package:avg_mart/models/banner_response.dart';
import 'package:avg_mart/widgets/network_image.dart';
import 'package:flutter/material.dart' hide Banner;
import '../../theme/app_theme.dart';

class Item2 extends StatefulWidget {
  const Item2({
    super.key,
    required this.banners,
    this.onBannerTap,
    this.aspectRatio = 16 / 8,
    this.autoScrollDuration = const Duration(seconds: 4),
  });

  final List<Banners> banners;
  final ValueChanged<Banners>? onBannerTap;
  final double aspectRatio;
  final Duration autoScrollDuration;

  @override
  State<Item2> createState() => _Item2State();
}

class _Item2State extends State<Item2> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void didUpdateWidget(covariant Item2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Banner list can change after the initial loading state resolves
    // (HomeBannerLoading -> HomeBannerLoaded), so make sure we don't keep
    // animating toward a page index that no longer exists.
    if (widget.banners.length != oldWidget.banners.length) {
      _currentPage = 0;
      if (_controller.hasClients) {
        _controller.jumpToPage(0);
      }
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _timer?.cancel();
    if (widget.banners.length <= 1) return;
    _timer = Timer.periodic(widget.autoScrollDuration, (_) {
      if (!_controller.hasClients || widget.banners.isEmpty) return;
      int next = _currentPage + 1;
      if (next >= widget.banners.length) next = 0;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AspectRatio(
                aspectRatio: widget.aspectRatio,
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (page) => setState(() => _currentPage = page),
                  itemCount: widget.banners.length,
                  itemBuilder: (context, index) {
                    final banner = widget.banners[index];
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final image = HomeNetworkImage(
                          url: banner.imageUrl,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          fit: BoxFit.cover,
                        );
                        if (widget.onBannerTap == null) return image;
                        return GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => widget.onBannerTap!(banner),
                          child: image,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          _DotsIndicator(
            itemCount: widget.banners.length,
            currentIndex: _currentPage,
          ),
        ],
      ),
    );
  }
}

/// Simple, clean animated dot indicator. Active dot is a slightly wider
/// pill in the theme's primary color; inactive dots are small neutral dots.
class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.itemCount, required this.currentIndex});

  final int itemCount;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 1) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: isActive
                ? AppTheme.primary
                : AppTheme.primary.withOpacity(0.2),
          ),
        );
      }),
    );
  }
}
