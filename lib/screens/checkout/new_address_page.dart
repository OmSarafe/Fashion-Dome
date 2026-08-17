import 'package:ecommerence_project/screens/account/faq_page.dart';
import 'package:ecommerence_project/widgets/basicwidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ecommerence_project/screens/account/notification_settings_page.dart';

class NewAddressPage extends StatefulWidget {
  const NewAddressPage({super.key});

  @override
  State<NewAddressPage> createState() => _NewAddressPageState();
}

class _NewAddressPageState extends State<NewAddressPage> {
  late bool check = false;
  final _textController = TextEditingController();
  String _selectedaddress = 'Home';

  final List<String> _address = ['Home', 'Office', 'Commerical'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, "New Address"),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            "assets/map.png",
            height: 300,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.fitWidth,
          ),
          SizedBox(
            height: 5,
          ),
          Padding(
            padding:
                const EdgeInsets.only(right: 20.0, left: 20, top: 5, bottom: 5),
            child: Text(
              "Address",
              style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Colors.black),
            ),
          ),
          dividernoti(),

          Padding(
            padding:
                const EdgeInsets.only(right: 20.0, left: 20, top: 5, bottom: 5),
            child: Text(
              "Address Nickname",
              style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.black),
            ),
          ),
          // SizedBox(height: 5,),
          Padding(
            padding: const EdgeInsets.only(right: 20.0, left: 20, bottom: 5),
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedaddress,
                  isExpanded: true,
                  items: _address.map((size) {
                    return DropdownMenuItem(
                      value: size,
                      child: Text(size),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedaddress = value);
                    }
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(right: 20.0, left: 20, top: 0, bottom: 5),
            child: Text(
              "Address Nickname",
              style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0, left: 20),
            child: SizedBox(
              height: 70,
              child: TextFormField(
                controller: _textController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r"^[a-zA-Z ]+$")),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field cannot be empty';
                  }
                  if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                    return 'Only alphabetic characters are allowed';
                  }
                  if (value.length < 5) {
                    return 'Name must be at least 5 characters';
                  }
                  if (value.length > 20) {
                    return 'Name must not exceed 20 characters';
                  }
                  return null;
                },
                maxLines: 2,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(10),
                  hintText: "Enter your full address..",
                  hintStyle: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(width: 0.5, color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        const BorderSide(color: Colors.black, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(right: 20.0, left: 5, top: 0, bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Checkbox(
                  activeColor: Colors.black,
                  checkColor: Colors.white,
                  value: check,
                  onChanged: (value) {
                    setState(() {
                      check = !check;
                    });
                  },
                ),
                Text(
                  "Make this as a default address",
                  style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Colors.grey),
                )
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(right: 20.0, left: 20, top: 0, bottom: 4),
            child: SizedBox(
              height: 55,
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
                  showAddressDialog(context);
                },
                child: const Text('Add',
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 16)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
