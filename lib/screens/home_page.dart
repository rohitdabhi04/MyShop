import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../cart_service.dart';
import 'product_detail.dart';

class HomePage extends StatelessWidget {
  final String userName;

  const HomePage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("MyShop"),
        actions: const [
          Icon(Icons.notifications),
          SizedBox(width: 12),
        ],
      ),

      body: Column(
        children: [

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// LOCATION
                  Container(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 18,
                            color: theme.colorScheme.primary),
                        const SizedBox(width: 6),
                        Text(
                          "Deliver to $userName - Gujarat",
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                  /// SEARCH
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search products",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  /// WELCOME
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      "Welcome back, $userName 👋",
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Text("Recommended for you"),
                  ),

                  const SizedBox(height: 12),

                  /// PRODUCTS
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('products')
                        .snapshots(),

                    builder: (context, snapshot) {

                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text("No products found"),
                        );
                      }

                      final docs = snapshot.data!.docs;

                      return GridView.builder(
                        itemCount: docs.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(12),

                        /// FIXED CARD HEIGHT
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          mainAxisExtent: 300,
                        ),

                        itemBuilder: (context, index) {

                          final data =
                          docs[index].data() as Map<String, dynamic>;

                          final String title =
                              data["title"] ?? "No Title";

                          final int price =
                          (data["price"] as num).toInt();

                          final String image =
                              data["image"] ?? "";

                          return _productCard(
                            context,
                            title,
                            price,
                            image,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// PRODUCT CARD
  Widget _productCard(
      BuildContext context,
      String title,
      int price,
      String image,
      ) {

    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(
              title: title,
              price: price,
              image: image,
            ),
          ),
        );
      },

      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// PRODUCT IMAGE
            Container(
              height: 150,
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: _productImage(image),
            ),

            /// TITLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 4),

            /// PRICE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "₹$price",
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Spacer(),

            /// BUTTON
            Padding(
              padding: const EdgeInsets.all(8),
              child: SizedBox(
                height: 36,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    CartService.addItem({
                      "title": title,
                      "price": price,
                      "image": image,
                    });
                  },
                  child: const Text("Add to Cart"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// IMAGE HANDLER
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