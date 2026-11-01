import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const ECommerceApp());
}

class ECommerceApp extends StatelessWidget {
  const ECommerceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gift Card Shop',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ProductDetailsPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _cartCount = 0;
  final double _productPrice = 1.00;

  void _addToCart() {
    setState(() {
      _cartCount++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gift Card added to cart!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _navigateToCart() async {
    if (_cartCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty!')),
      );
      return;
    }

    final updatedCount = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (context) => CartPage(
          itemCount: _cartCount,
          totalPrice: _productPrice * _cartCount,
          productPrice: _productPrice,
        ),
      ),
    );

    if (updatedCount != null) {
      setState(() {
        _cartCount = updatedCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gift Card Shop'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, size: 28),
                onPressed: _navigateToCart,
              ),
              if (_cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_cartCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade700, Colors.blue.shade800],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.card_membership, size: 80, color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'Premium Gift Card',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '₹1.00 Value',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addToCart,
              icon: const Icon(Icons.add_shopping_cart),
              label: Text(_cartCount > 0 ? 'Add to Cart ($_cartCount items)' : 'Add to Cart'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  final int itemCount;
  final double totalPrice;
  final double productPrice;

  const CartPage({
    super.key,
    required this.itemCount,
    required this.totalPrice,
    required this.productPrice,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late int _currentItemCount;
  late double _currentTotalPrice;

  @override
  void initState() {
    super.initState();
    _currentItemCount = widget.itemCount;
    _currentTotalPrice = widget.totalPrice;
  }

  void _deleteItem() {
    setState(() {
      if (_currentItemCount > 0) {
        _currentItemCount--;
        _currentTotalPrice = _currentItemCount * widget.productPrice;
      }
    });

    if (_currentItemCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart cleared!')),
      );
      Navigator.of(context).pop(_currentItemCount);
    }
  }
  Future<void> _launchGooglePayUPI() async {
    final String amountString = _currentTotalPrice.toStringAsFixed(2);

    // Replace with your real merchant UPI ID details
    const String merchantUpiId = "";
    const String merchantName = "Guest Account";

    // Standardized deep link structure for routing direct payment intents
    final String upiUrl =
        "upi://pay?pa=$merchantUpiId&pn=${Uri.encodeComponent(merchantName)}&am=$amountString&cu=INR";

    try {
      // Explicitly targeting the native Google Pay Android Package Intent
      await launchUrl(
        Uri.parse(upiUrl),
        mode: LaunchMode.externalApplication,
        webViewConfiguration: const WebViewConfiguration(
          headers: <String, String>{
            'X-Requested-With': 'com.google.android.apps.nativetops' // Forces GPay handling
          },
        ),
      );
    } catch (e) {
      debugPrint("UPI Intent Launch Failure: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not trigger Google Pay app automatically. Verify app is active.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(_currentItemCount),
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              if (_currentItemCount > 0)
          Card(
      child: ListTile(
      leading: const Icon(Icons.card_membership, size: 40, color: Colors.purple),
      title: const Text('Premium Gift Card'),
      subtitle: Text('Quantity: $_currentItemCount'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('₹${_currentTotalPrice.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteItem,
            tooltip: 'Remove 1 Item',
          ),
        ],
      ),
    ),
    ),
    const Spacer(),
    const Divider(),
    Padding(
    padding: const EdgeInsets.symmetric(vertical: 16.0),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
    const Text('Total Amount:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    Text('₹${_currentTotalPrice.toStringAsFixed(2)}',
    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
    ],
    ),
    ),
    const SizedBox(height: 8),
    ElevatedButton(
    onPressed: _currentItemCount > 0 ? _launchGooglePayUPI : null,
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
    ),
      child: const Text(
        'Buy Now with Google Pay',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ),
              ],
          ),
      ),
    );
  }
}