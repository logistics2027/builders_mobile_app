import 'package:flutter/material.dart';

/// Reusable shimmering placeholder box.
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(6)),
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final slide = _controller.value * 2 - 1; // -1 .. 1
            return LinearGradient(
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
              stops: const [0.3, 0.5, 0.7],
              begin: Alignment(-1 + slide * 2, 0),
              end: Alignment(1 + slide * 2, 0),
            ).createShader(bounds);
          },
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: widget.borderRadius,
            ),
          ),
        );
      },
    );
  }
}

/// Shimmer card simulating a product card.
class ShimmerProductCard extends StatelessWidget {
  const ShimmerProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(8),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: ShimmerBox(height: double.infinity, borderRadius: BorderRadius.all(Radius.circular(8))),
            ),
          ),
          SizedBox(height: 8),
          ShimmerBox(width: 100, height: 12),
          SizedBox(height: 6),
          ShimmerBox(width: 60, height: 12),
          SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox(width: 50, height: 14),
              ShimmerBox(width: 20, height: 20, borderRadius: BorderRadius.all(Radius.circular(10))),
            ],
          ),
        ],
      ),
    );
  }
}

/// Home Screen Shimmer Skeleton
class HomeShimmerSkeleton extends StatelessWidget {
  const HomeShimmerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Banner area shimmer
          const ShimmerBox(height: 180, borderRadius: BorderRadius.zero),
          const SizedBox(height: 16),

          // Categories horizontal list
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.0),
            child: ShimmerBox(width: 120, height: 16),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: 6,
              itemBuilder: (context, index) {
                return const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Column(
                    children: [
                      ShimmerBox(width: 50, height: 50, borderRadius: BorderRadius.all(Radius.circular(25))),
                      SizedBox(height: 6),
                      ShimmerBox(width: 45, height: 10),
                    ],
                  ),
                );
              },
            ),
          ),

          // Deal of the Day section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
            child: ShimmerBox(width: 150, height: 16),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.0),
            child: ShimmerBox(height: 140, borderRadius: BorderRadius.all(Radius.circular(12))),
          ),
          const SizedBox(height: 20),

          // Product Grid Section Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
            child: ShimmerBox(width: 110, height: 16),
          ),

          // Grid of products
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: 4,
              itemBuilder: (context, index) => const ShimmerProductCard(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Explore Screen Shimmer Skeleton
class ExploreShimmerSkeleton extends StatelessWidget {
  const ExploreShimmerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left categories sidebar
        Container(
          width: 100,
          color: Colors.grey.shade50,
          child: ListView.builder(
            itemCount: 8,
            itemBuilder: (context, index) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Column(
                  children: [
                    ShimmerBox(width: 36, height: 36, borderRadius: BorderRadius.all(Radius.circular(18))),
                    SizedBox(height: 6),
                    ShimmerBox(width: 50, height: 10),
                  ],
                ),
              );
            },
          ),
        ),
        VerticalDivider(width: 1, color: Colors.grey.shade200),
        // Right products grid
        Expanded(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox(width: 100, height: 16),
                    ShimmerBox(width: 50, height: 12),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) => const ShimmerProductCard(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Profile Screen Shimmer Skeleton
class ProfileShimmerSkeleton extends StatelessWidget {
  const ProfileShimmerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Row(
              children: [
                ShimmerBox(width: 60, height: 60, borderRadius: BorderRadius.all(Radius.circular(30))),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 120, height: 16),
                    SizedBox(height: 8),
                    ShimmerBox(width: 150, height: 12),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Order history header
          const ShimmerBox(width: 140, height: 18),
          const SizedBox(height: 16),

          // Order cards list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShimmerBox(width: 90, height: 12),
                        ShimmerBox(width: 60, height: 12),
                      ],
                    ),
                    SizedBox(height: 12),
                    Divider(height: 1),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        ShimmerBox(width: 50, height: 50, borderRadius: BorderRadius.all(Radius.circular(6))),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShimmerBox(width: 150, height: 12),
                              SizedBox(height: 6),
                              ShimmerBox(width: 80, height: 10),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Cart Screen Shimmer Skeleton
class CartShimmerSkeleton extends StatelessWidget {
  const CartShimmerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(14.0),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 80, height: 80, borderRadius: BorderRadius.all(Radius.circular(8))),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox(width: double.infinity, height: 14),
                          SizedBox(height: 6),
                          ShimmerBox(width: 100, height: 12),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ShimmerBox(width: 70, height: 16),
                              Row(
                                children: [
                                  ShimmerBox(width: 24, height: 24, borderRadius: BorderRadius.all(Radius.circular(12))),
                                  SizedBox(width: 8),
                                  ShimmerBox(width: 20, height: 12),
                                  SizedBox(width: 8),
                                  ShimmerBox(width: 24, height: 24, borderRadius: BorderRadius.all(Radius.circular(12))),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        // Bottom check out card shimmer
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerBox(width: 100, height: 14),
                  ShimmerBox(width: 85, height: 16),
                ],
              ),
              SizedBox(height: 12),
              ShimmerBox(width: double.infinity, height: 48, borderRadius: BorderRadius.all(Radius.circular(10))),
            ],
          ),
        ),
      ],
    );
  }
}

/// Address Screen Shimmer Skeleton
class AddressShimmerSkeleton extends StatelessWidget {
  const AddressShimmerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerBox(width: 60, height: 14),
                  Row(
                    children: [
                      ShimmerBox(width: 20, height: 20, borderRadius: BorderRadius.all(Radius.circular(10))),
                      SizedBox(width: 12),
                      ShimmerBox(width: 20, height: 20, borderRadius: BorderRadius.all(Radius.circular(10))),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12),
              ShimmerBox(width: 120, height: 14),
              SizedBox(height: 8),
              ShimmerBox(width: 200, height: 12),
              SizedBox(height: 6),
              ShimmerBox(width: 150, height: 12),
              SizedBox(height: 12),
              ShimmerBox(width: 90, height: 12),
            ],
          ),
        );
      },
    );
  }
}

/// Checkout Screen Shimmer Skeleton
class CheckoutShimmerSkeleton extends StatelessWidget {
  const CheckoutShimmerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shipping address box
          const ShimmerBox(width: 120, height: 14),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 100, height: 12),
                SizedBox(height: 8),
                ShimmerBox(width: double.infinity, height: 10),
                SizedBox(height: 6),
                ShimmerBox(width: 180, height: 10),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Payment options box
          const ShimmerBox(width: 110, height: 14),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Column(
              children: [
                Row(
                  children: [
                    ShimmerBox(width: 16, height: 16, borderRadius: BorderRadius.all(Radius.circular(8))),
                    SizedBox(width: 12),
                    ShimmerBox(width: 140, height: 12),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    ShimmerBox(width: 16, height: 16, borderRadius: BorderRadius.all(Radius.circular(8))),
                    SizedBox(width: 12),
                    ShimmerBox(width: 100, height: 12),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Items summary
          const ShimmerBox(width: 90, height: 14),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 2,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    const ShimmerBox(width: 40, height: 40, borderRadius: BorderRadius.all(Radius.circular(4))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ShimmerBox(width: 150, height: 12),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const ShimmerBox(width: 80, height: 10),
                              const ShimmerBox(width: 50, height: 12),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Pricing details card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox(width: 60, height: 12),
                    ShimmerBox(width: 50, height: 12),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox(width: 80, height: 12),
                    ShimmerBox(width: 40, height: 12),
                  ],
                ),
                SizedBox(height: 12),
                Divider(),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox(width: 70, height: 14),
                    ShimmerBox(width: 65, height: 16),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // CTA Button
          const ShimmerBox(width: double.infinity, height: 48, borderRadius: BorderRadius.all(Radius.circular(10))),
        ],
      ),
    );
  }
}

/// Menu Screen Shimmer Skeleton
class MenuShimmerSkeleton extends StatelessWidget {
  const MenuShimmerSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          padding: const EdgeInsets.all(8),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShimmerBox(width: 40, height: 40, borderRadius: BorderRadius.all(Radius.circular(20))),
              SizedBox(height: 10),
              ShimmerBox(width: 50, height: 10),
            ],
          ),
        );
      },
    );
  }
}
