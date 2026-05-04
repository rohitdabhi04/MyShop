import 'package:flutter/material.dart';
import '../cart_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final items = CartService.cartItems;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
      ),
      body: items.isEmpty
          ? Center(
        child: Text(
          "Your cart is empty",
          style: theme.textTheme.titleMedium,
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Image.asset(
                      item["image"] as String,
                      width: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(
                      item["title"],
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "₹${item["price"]} x ${item["qty"]}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline,
                              color:
                              theme.colorScheme.primary),
                          onPressed: () {
                            setState(() {
                              CartService.decreaseQty(index);
                            });
                          },
                        ),
                        Text(
                          "${item["qty"]}",
                          style: theme.textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline,
                              color:
                              theme.colorScheme.primary),
                          onPressed: () {
                            setState(() {
                              CartService.increaseQty(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 💰 TOTAL SECTION
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              border: Border(
                top: BorderSide(
                  color: theme.dividerColor,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total",
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  "₹${CartService.getTotal()}",
                  style: theme.textTheme.titleMedium
                      ?.copyWith(
                    fontWeight: FontWeight.bold,
                    color:
                    theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
