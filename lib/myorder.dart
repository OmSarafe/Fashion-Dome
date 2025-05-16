import 'package:flutter/material.dart';

class Myorder extends StatefulWidget {
  const Myorder({super.key});

  @override
  State<Myorder> createState() => _MyorderState();
}

class _MyorderState extends State<Myorder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrdersPage(),
    );
  }
}

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> ongoingOrders = [
    {
      'title': 'Regular Fit Slogan',
      'size': 'M',
      'price': 1190,
      'status': 'In Transit',
      'image': 'assets/image1.png'
    },
    {
      'title': 'Regular Fit Polo',
      'size': 'L',
      'price': 1100,
      'status': 'Picked',
      'image': 'assets/image2.png'
    },
    {
      'title': 'Regular Fit Black',
      'size': 'L',
      'price': 1690,
      'status': 'In Transit',
      'image': 'assets/image3.png'
    },
    {
      'title': 'Regular Fit V-Neck',
      'size': 'S',
      'price': 1290,
      'status': 'Packing',
      'image': 'assets/image4.png'
    },
    {
      'title': 'Regular Fit Pink',
      'size': 'M',
      'price': 1341,
      'status': 'Picked',
      'image': 'assets/image5.png'
    },
  ];

  final List<Map<String, dynamic>> completedOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Widget orderCard(Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              order['image'],
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order['title'],
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'GeneralSans',
                      fontSize: 14),
                ),
                Text("Size ${order['size']}",
                    style: TextStyle(
                        color: Color(0xff808080),
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  "\$ ${order['price']}",
                  style: const TextStyle(
                      fontFamily: 'GeneralSans',
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 14),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.18,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Color(0xffE6E6E6),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Text(
                    order['status'],
                    style: const TextStyle(
                        fontSize: 10,
                        fontFamily: 'GeneralSans',
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size(90, 30),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text("Track Order",
                    style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w500,
                        color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildOrderList(List<Map<String, dynamic>> orders) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return orderCard(orders[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          SizedBox(
            width: 5,
          ),
        ],
        title: const Text("My Orders",
            style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w600,
                fontSize: 32,
                letterSpacing: -2)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          // indicator: BoxDecoration(
          //   color: Colors.white,
          //   // border: Border.all(color: Colors.black),
          //   borderRadius: BorderRadius.circular(8),
          // ),
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: "Ongoing"),
            Tab(text: "Completed"),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TabBarView(
          controller: _tabController,
          children: [
            buildOrderList(ongoingOrders),
            completedOrders.isEmpty
                ? const Center(child: Text("No completed orders"))
                : buildOrderList(completedOrders),
          ],
        ),
      ),
    );
  }
}
