import 'package:ecommerence_project/Account/faqpage.dart';
import 'package:ecommerence_project/widgets/basicwidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'Account/notification_setting.dart';

class NewcardPage extends StatefulWidget {
  const NewcardPage({super.key});

  @override
  State<NewcardPage> createState() => _NewcardPageState();
}

class _NewcardPageState extends State<NewcardPage> {
  final _numtextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    // Get the available screen height (excluding system UI)
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: customAppBar(context,"Add Card"),
      backgroundColor: Colors.white,
      body: SafeArea(
          child: SingleChildScrollView(
          child: ConstrainedBox(
          constraints: BoxConstraints(
          minHeight: screenHeight -
          MediaQuery.of(context).padding.top -
          MediaQuery.of(context).padding.bottom,
    ),
      child:Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              dividernoti(),
              Padding(
                padding: const EdgeInsets.only(
                    right: 20.0, left: 20, top: 15, bottom: 5),
                child: Text(
                  "Add Debit or Credit Card",
                  style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    right: 20.0, left: 20, top: 10, bottom: 5),
                child: Text(
                  "Card Number",
                  style: TextStyle(
                    letterSpacing: 0,
                    fontFamily: 'GeneralSans',
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    right: 20.0, left: 20, top: 5, bottom: 15),
                child: SizedBox(
                  height: 45,
                  child: TextFormField(
                    controller: _numtextController,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly, // allows only digits
                      LengthLimitingTextInputFormatter(16),   // limits input to 10 digits
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Phone number cannot be empty';
                      }
                      if (!RegExp(r'^\d{16}$').hasMatch(value)) {
                        return 'Enter a valid 16-digit card number';
                      }
                      return null;
                    },

                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      hintText: "Enter your card number",
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
                        borderSide:
                        const BorderSide(color: Colors.red, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
             Padding(
               padding: const EdgeInsets.only(
                   right: 20.0, left: 20, top: 5, bottom: 5),
               child: Row(
                 children: [
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         "Expiry Date",
                         style: TextStyle(
                           letterSpacing: 0,
                           fontFamily: 'GeneralSans',
                           fontWeight: FontWeight.w500,
                           fontSize: 16,
                         ),
                       ),
                       SizedBox(height: 10,),
                       SizedBox(
                         height: 45,
                         width: 150,
                         child: TextFormField(
                           controller: _numtextController,
                           inputFormatters: [
                             FilteringTextInputFormatter.digitsOnly, // allows only digits
                             LengthLimitingTextInputFormatter(16),   // limits input to 10 digits
                           ],
                           // validator: (value) {
                           //   if (value == null || value.isEmpty) {
                           //     return 'Phone number cannot be empty';
                           //   }
                           //   if (!RegExp(r'^\d{16}$').hasMatch(value)) {
                           //     return 'Enter a valid 16-digit card number';
                           //   }
                           //   return null;
                           // },

                           cursorColor: Colors.black,
                           decoration: InputDecoration(
                             hintText: "MM/YY ",
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
                               borderSide:
                               const BorderSide(color: Colors.red, width: 2),
                               borderRadius: BorderRadius.circular(8),
                             ),
                           ),
                         ),
                       )
                     ],
                   ),
                   SizedBox(width: 20,),
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         "Security Code",
                         style: TextStyle(
                           letterSpacing: 0,
                           fontFamily: 'GeneralSans',
                           fontWeight: FontWeight.w500,
                           fontSize: 16,
                         ),
                       ),
                       SizedBox(height: 10,),
                       SizedBox(
                         height: 45,
                         width: 150,
                         child: TextFormField(
                           controller: _numtextController,
                           inputFormatters: [
                             FilteringTextInputFormatter.digitsOnly, // allows only digits
                             LengthLimitingTextInputFormatter(3),   // limits input to 10 digits
                           ],
                           validator: (value) {
                             if (value == null || value.isEmpty) {
                               return 'CVV cannot be empty';
                             }
                             if (!RegExp(r'^\d{3}$').hasMatch(value)) {
                               return 'Enter a valid 3-digit CVV number';
                             }
                             return null;
                           },

                           cursorColor: Colors.black,
                           decoration: InputDecoration(

                             hintText: "Enter CVV",
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
                               borderSide:
                               const BorderSide(color: Colors.red, width: 2),
                               borderRadius: BorderRadius.circular(8),
                             ),
                           ),
                         ),
                       )
                     ],
                   ),


                 ],
               ),
             ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(bottom: keyboardHeight + 80,right: 20,left: 20),
            child: GestureDetector(
              onTap: () {
                showcardDialog(context);
              },
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                ),
                child: const Center(
                  child: Text(
                    "Add Card",
                    style: TextStyle(
                      fontFamily: 'GeneralSans',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ))));
  }
}
