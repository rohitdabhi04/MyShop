
class CartService {
  static final List<Map<String, dynamic>> cartItems = [];

  static void addItem(Map<String, dynamic> product) {
    final int index =
    cartItems.indexWhere((item) => item["title"] == product["title"]);

    if (index >= 0) {
      final int currentQty =
      cartItems[index]["qty"] is int ? cartItems[index]["qty"] as int : 1;
      cartItems[index]["qty"] = currentQty + 1;
    } else {
      cartItems.add({
        "title": product["title"],
        "price": product["price"],
        "image": product["image"],
        "qty": 1,
      });
    }
  }

  static void increaseQty(int index) {
    final int currentQty =
    cartItems[index]["qty"] is int ? cartItems[index]["qty"] as int : 1;
    cartItems[index]["qty"] = currentQty + 1;
  }

  static void decreaseQty(int index) {
    final int currentQty =
    cartItems[index]["qty"] is int ? cartItems[index]["qty"] as int : 1;

    if (currentQty > 1) {
      cartItems[index]["qty"] = currentQty - 1;
    } else {
      cartItems.removeAt(index);
    }
  }

  static int getTotal() {
    int total = 0;
    for (final item in cartItems) {
      final int price = item["price"] as int;
      final int qty = item["qty"] is int ? item["qty"] as int : 1;
      total += price * qty;
    }
    return total;
  }
}