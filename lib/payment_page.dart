import 'package:ecommerence_project/Account/faqpage.dart';
import 'package:ecommerence_project/Account/notification_setting.dart';
import 'package:ecommerence_project/Notification/notification.dart';
import 'package:ecommerence_project/newcard_page.dart';
import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  int _selectedIndex = 0;

  final List<Map<String, String>> _addresses = [
    {
      'title': '**** **** **** 5214',
      'tag': 'Default',
    },
    {
      'title': '**** **** **** 6724',

    },
    {
      'title': '**** **** **** 9721',

    },{
      'title': '**** **** **** 5632',

    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Payment Method',
          style: TextStyle(
              fontFamily: 'GeneralSans',
              fontWeight: FontWeight.w600,
              fontSize: 30,
              letterSpacing: -2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=>NotificationPage()));
            },
          ),
          SizedBox(
            width: 5,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          dividernoti(),
          Padding(
            padding: const EdgeInsets.only(
                right: 20.0, left: 20, top: 5, bottom: 5),
            child: Text(
              "Saved Cards",
              style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black),
            ),
          ),
          Container(
            height: 300,
            child: ListView.builder(
              itemCount: _addresses.length,
              padding: EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final address = _addresses[index];
                final selected = _selectedIndex == index;

                return Container(
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                    color: Colors.white,
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: RadioListTile<int>(
                    value: index,
                    groupValue: _selectedIndex,
                    onChanged: (value) {
                      setState(() {
                        _selectedIndex = value!;
                      });
                    },
                    // contentPadding: EdgeInsets.all(16),
                    controlAffinity: ListTileControlAffinity.trailing,
                    activeColor: Colors.black,
                    title: Row(
                      children: [
                        Icon(Icons.credit_card_outlined, size: 20),
                        SizedBox(width: 8),
                        Text(
                          address['title']!,
                          style: TextStyle(fontSize:16,fontWeight: FontWeight.bold),
                        ),
                        if (address.containsKey('tag')) ...[
                          SizedBox(width: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              address['tag']!,
                              style: TextStyle(
                                  fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ],
                    ),

                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0,left: 20,top: 20),
            child: GestureDetector(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          NewcardPage()), // Replace SecondPage with your target widget
                );
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),

                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add),
                    Text("Add New Card",style: TextStyle(fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,color: Colors.black),)
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
