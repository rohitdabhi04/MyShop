import 'package:flutter/material.dart';
import '../cart_service.dart';

class ProductDetailPage extends StatefulWidget {
  final String title;
  final int price;
  final String image;

  const ProductDetailPage({
    super.key,
    required this.title,
    required this.price,
    required this.image,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {

  bool isLoading = false;
  bool isAdded = false;

  /// 🔥 ADD TO CART ANIMATION
  void handleAddToCart() async {
    setState(() => isLoading = true);

    await Future.delayed(const Duration(milliseconds: 800));

    CartService.addItem({
      "title": widget.title,
      "price": widget.price,
      "image": widget.image,
    });

    setState(() {
      isLoading = false;
      isAdded = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${widget.title} added to cart")),
    );

    await Future.delayed(const Duration(seconds: 1));

    setState(() => isAdded = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Details"),
      ),

      body: Column(
        children: [

          /// 🔥 FULL IMAGE + ZOOM
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  backgroundColor: Colors.black,
                  child: InteractiveViewer(
                    child: _productImage(widget.image),
                  ),
                ),
              );
            },
            child: SizedBox(
              height: 300,
              width: double.infinity,
              child: _productImage(widget.image),
            ),
          ),

          /// DETAILS
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// TITLE
                  Text(
                    widget.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// RATING
                  Row(
                    children: [
                      ...List.generate(
                        4,
                            (index) => Icon(Icons.star,
                            color: theme.colorScheme.primary, size: 18),
                      ),
                      const Icon(Icons.star_half, size: 18),
                      const SizedBox(width: 6),
                      Text("(3.5 rating)",
                          style: theme.textTheme.bodySmall),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// PRICE
                  Text(
                    "₹${widget.price}",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// DESCRIPTION
                  Text(
                    "High quality product with excellent performance. Best choice for daily use.",
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),

          /// 🔥 BUTTONS
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [

                /// 🟢 ADD TO CART (ANIMATED)
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: isLoading ? null : handleAddToCart,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: isLoading
                            ? const SizedBox(
                          key: ValueKey("loading"),
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : isAdded
                            ? const Icon(Icons.check,
                            key: ValueKey("done"))
                            : const Text(
                          "Add to Cart",
                          key: ValueKey("text"),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                /// 🟢 BUY NOW
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.primaryContainer,
                        foregroundColor: isDark
                            ? theme.colorScheme.onSecondary
                            : theme.colorScheme.onPrimaryContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Buy Now",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔥 IMAGE HANDLER
  Widget _productImage(String image) {
    if (image.startsWith("http")) {
      return Image.network(
        image,
        fit: BoxFit.contain,
      );
    } else {
      return Image.asset(
        image,
        fit: BoxFit.contain,
      );
    }
  }
}