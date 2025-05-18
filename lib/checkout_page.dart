import 'package:ecommerence_project/Account/account.dart';
import 'package:ecommerence_project/Account/faqpage.dart';
import 'package:ecommerence_project/Account/notification_setting.dart';
import 'package:ecommerence_project/addresspage.dart';
import 'package:ecommerence_project/payment_page.dart';
import 'package:ecommerence_project/widgets/basicwidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _sortBy = 'Card';

  final Map<String, IconData> _optionIcons = {
    'Card': Icons.credit_card_outlined,
    'Cash': Icons.money_outlined,
    'Pay': Icons.apple_outlined,
  };
  final List<String> _sortOptions = ['Card', 'Cash', 'Pay'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, "Checkout"),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 5,
            ),
            dividernoti(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Delivery Address",
                    style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Addresspage()), // Replace SecondPage with your target widget
                      );
                    },
                    child: Text(
                      "Change",
                      style: TextStyle(
                          fontFamily: 'GeneralSans',
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.black),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  right: 20.0, left: 20, top: 5, bottom: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 30,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Home",
                          style: TextStyle(
                              fontFamily: 'GeneralSans',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.black)),
                      Text("925 S Chugach St #APT 10, Alaska 99645",
                          style: TextStyle(
                              fontFamily: 'GeneralSans',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Color(0xff808080)))
                    ],
                  )
                ],
              ),
            ),
            dividernoti(),
            Padding(
              padding: const EdgeInsets.only(
                  right: 20.0, left: 20, top: 10, bottom: 10),
              child: Text(
                "Payment Method",
                style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20.0, left: 20, bottom: 10),
              child: Row(
                children: [
                  Row(
                    children: _optionIcons.entries.map((entry) {
                      final option = entry.key;
                      final icon = entry.value;
                      final bool selected = _sortBy == option;
        
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                icon,
                                color: selected ? Colors.white : Colors.black,
                                size: 20,
                              ),
                              SizedBox(width: 4),
                              Text(option),
                            ],
                          ),
                          selected: selected,
                          onSelected: (_) => setState(() => _sortBy = option),
                          selectedColor: Colors.black,
                          backgroundColor: Colors.grey.shade200,
                          showCheckmark: false,
                          labelStyle: TextStyle(
                            fontSize: 16,
                            color: selected ? Colors.white : Colors.black,
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 8),
                        ),
                      );
                    }).toList(),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 20.0, left: 20, bottom: 10),
              child: Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0xffE6E6E6))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "VISA **** **** **** 2512",
                        style: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.black),
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PaymentPage(),
                              ),
                            );
                          },
                          child: Icon(
                            Icons.edit_outlined,
                            color: Colors.black,
                          ))
                    ],
                  )),
            ),
            dividernoti(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  PriceRow(label: "Sub_total", value: "₹ 5,870"),
                  PriceRow(label: "VAT (%)", value: "₹ 0.00"),
                  PriceRow(label: "Shipping fee", value: "₹ 80"),
                  Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                  ),
                  PriceRow(label: "Total", value: "₹ 5,950"),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 10),
              child: Row(
                children: [
                  SizedBox(
                    height: 45,
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: TextFormField(
                      // controller: _emailController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')),
                      ],
                      cursorColor: Colors.black,
        
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.discount_outlined,
                          color: Colors.grey,
                        ),
                        hintText: "Enter promo code",
                        hintStyle: TextStyle(
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.black, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.red),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide:
                              const BorderSide(color: Colors.red, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  SizedBox(
                    height: 45,
                    width: MediaQuery.of(context).size.width * 0.25,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 1),
                      ),
                      onPressed: () {
                        // You can collect and use selected filters here
                      },
                      child: const Text('Add',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'GeneralSans',
                              fontWeight: FontWeight.w500,
                              fontSize: 16)),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: SizedBox(
          height: 45,
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 1),
            ),
            onPressed: () {
              // You can collect and use selected filters here
              showorderDialog(context);
            },
            child: const Text('Place Order',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w500,
                    fontSize: 16)),
          ),
        ),
      ),
    );
  }
}
