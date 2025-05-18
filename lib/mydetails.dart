import 'package:ecommerence_project/Account/faqpage.dart';
import 'package:ecommerence_project/widgets/customtextformfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Mydetails extends StatefulWidget {
  const Mydetails({super.key});

  @override
  State<Mydetails> createState() => _MydetailsState();
}

class _MydetailsState extends State<Mydetails> {
  final _textController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedSize = 'Male';

  final List<String> _sizes = ['Male', 'Female', 'Preferred not to say'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar(context,"My Details"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 15,
              ),
              Text(
                "Full Name",
                style: TextStyle(
                  letterSpacing: 0,
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              SizedBox(
                height: 45,
                child: TextFormField(
                  controller: _textController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r"^[a-zA-Z ]+$")),
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
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    hintText: "Enter your name",
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
              SizedBox(
                height: 20,
              ),
              Text(
                "Email",
                style: TextStyle(
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                  fontSize: 16,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              SizedBox(
                height: 45,
                child: TextFormField(
                  controller: _emailController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email cannot be empty';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    if (value.length > 50) {
                      return 'Email must not exceed 50 characters';
                    }
                    return null;
                  },
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    hintText: "Enter your email",
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
                      borderSide: const BorderSide(color: Colors.black, width: 2),
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
        
              SizedBox(
                height: 20,
              ),
              Text(
                "Date of Birth",
                style: TextStyle(
                  letterSpacing: 0,
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              DatePickerTextField(),
              SizedBox(
                height: 20,
              ),
              Text(
                "Gender",
                style: TextStyle(
                  letterSpacing: 0,
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 5,),
              Container(
                height: 40,
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedSize,
                    isExpanded: true,
                    items: _sizes.map((size) {
                      return DropdownMenuItem(
                        value: size,
                        child: Text(size),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedSize = value);
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Text(
                "Phone Number",
                style: TextStyle(
                  letterSpacing: 0,
                  fontFamily: 'GeneralSans',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              SizedBox(
                height: 45,
                child: TextFormField(
                  controller: _textController,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // allows only digits
                    LengthLimitingTextInputFormatter(10),   // limits input to 10 digits
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone number cannot be empty';
                    }
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'Enter a valid 10-digit phone number';
                    }
                    return null;
                  },
        
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    hintText: "Enter your phone number",
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
              SizedBox(height: MediaQuery.of(context).size.height*0.17,),
              SizedBox(
                height: 60,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    // You can collect and use selected filters here

                  },
                  child: const Text('Submit',
                      style: TextStyle(color: Colors.white,fontFamily: 'GeneralSans',
                        fontWeight: FontWeight.w500,fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
