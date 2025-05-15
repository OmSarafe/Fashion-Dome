import 'package:flutter/material.dart';

class Savedpage extends StatefulWidget {
  const Savedpage({super.key});

  @override
  State<Savedpage> createState() => _SavedpageState();
}

class _SavedpageState extends State<Savedpage> {
  List<bool> isFavourite = List.generate(6, (index) => true);
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
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Saved Items',
          style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w600,
              fontSize: 32,
              letterSpacing: -2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
          SizedBox(
            width: 5,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                itemCount: products.length,
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.82,
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
                            height: 150,
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
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isFavourite[index] = !isFavourite[index];
                                });
                              },
                              child: Icon(
                                isFavourite[index]
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavourite[index]
                                    ? Colors.red
                                    : Colors.black,
                              ),
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
}
