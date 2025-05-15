import 'package:ecommerence_project/notification.dart';
import 'package:ecommerence_project/widgets/basicwidget.dart';
import 'package:flutter/material.dart';

class DiscoverScreen extends StatefulWidget {
  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  List<bool> isFavourite = List.generate(6, (index) => false);

  final List<Map<String, dynamic>> products = [
    {
      "title": "Regular Fit Slogan",
      "price": "1,190",
      "image": "assets/image1.png",
    },
    {
      "title": "Regular Fit Polo",
      "price": "1,000",
      "oldPrice": "1,100",
      "discount": "-52%",
      "image": "assets/image2.png",
    },
    {
      "title": "Regular Fit Black",
      "price": "1,690",
      "image": "assets/image6.png",
    },
    {
      "title": "Regular Fit V-Neck",
      "price": "1,290",
      "image": "assets/image4.png",
    },
    {
      "title": "Regular Fit Crew",
      "price": "990",
      "image": "assets/image5.png",
    },
    {
      "title": "Regular Fit Stripe",
      "price": "1,050",
      "image": "assets/image3.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Discover',
          style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w600,
              fontSize: 32,
              letterSpacing: -2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => NotificationPage()));
            },
          ),
          SizedBox(
            width: 5,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Search & Filter Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    height: 45,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey)),
                    child: Row(
                      children: const [
                        Icon(Icons.search, color: Colors.grey),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Search for clothes...",
                              hintStyle: TextStyle(
                                fontFamily: 'GeneralSans',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Icon(Icons.mic_none, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const FilterSheet(),
                    );
                  },
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tune, color: Colors.white),
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            // Category Filters
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip("All", true),
                  _buildFilterChip("Tshirts", false),
                  _buildFilterChip("Jeans", false),
                  _buildFilterChip("Shoes", false),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Product Grid
            Expanded(
              child: GridView.builder(
                itemCount: products.length,
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.68,
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Image
                          Container(
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: AssetImage(product['image']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Title
                          Text(
                            product['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontFamily: 'GeneralSans',
                              letterSpacing: -1,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Price Row
                          Row(
                            children: [
                              Text(
                                "₹${product['price']}",
                                style: const TextStyle(
                                    fontFamily: 'GeneralSans',
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600),
                              ),
                              if (product['oldPrice'] != null) ...[
                                const SizedBox(width: 6),
                                Text(
                                  "₹${product['oldPrice']}",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  product['discount'],
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontFamily: 'GeneralSans',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      // Favourite Button
                      Positioned(
                        right: 0,
                        top: 8,
                        child: Card(
                          child: Container(
                            height: 40,
                            width: 40,
                            child: IconButton(
                              icon: Icon(
                                isFavourite[index]
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavourite[index]
                                    ? Colors.red
                                    : Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  isFavourite[index] = !isFavourite[index];
                                });
                              },
                            ),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          elevation: 5,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? Colors.black : Colors.grey)),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
