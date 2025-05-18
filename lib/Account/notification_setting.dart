import 'package:ecommerence_project/Account/faqpage.dart';
import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatefulWidget {
  @override
  _NotificationSettingsPageState createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool generalNotifications = true;
  bool sound = true;
  bool vibrate = false;
  bool specialOffers = true;
  bool promoDiscounts = false;
  bool payments = false;
  bool cashback = true;
  bool appUpdates = false;
  bool newServiceAvailable = true;
  bool newTipsAvailable = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar(context, "Notifications"),
      body: ListView(
        children: [
          dividernoti(),
          buildSwitchTile("General Notifications", generalNotifications,
              (val) => setState(() => generalNotifications = val)),
          dividernoti(),
          buildSwitchTile("Sound", sound, (val) => setState(() => sound = val)),
          dividernoti(),
          buildSwitchTile(
              "Vibrate", vibrate, (val) => setState(() => vibrate = val)),
          dividernoti(),
          buildSwitchTile("Special Offers", specialOffers,
              (val) => setState(() => specialOffers = val)),
          dividernoti(),
          buildSwitchTile("Promo & Discounts", promoDiscounts,
              (val) => setState(() => promoDiscounts = val)),
          dividernoti(),
          buildSwitchTile(
              "Payments", payments, (val) => setState(() => payments = val)),
          dividernoti(),
          buildSwitchTile(
              "Cashback", cashback, (val) => setState(() => cashback = val)),
          dividernoti(),
          buildSwitchTile("App Updates", appUpdates,
              (val) => setState(() => appUpdates = val)),
          dividernoti(),
          buildSwitchTile("New Service Available", newServiceAvailable,
              (val) => setState(() => newServiceAvailable = val)),
          dividernoti(),
          buildSwitchTile("New Tips Available", newTipsAvailable,
              (val) => setState(() => newTipsAvailable = val)),
        ],
      ),
    );
  }

  Widget buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'GeneralSans',
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      activeColor: Colors.white,
      activeTrackColor: Colors.black,
      inactiveTrackColor: Color(0xffE6E6E6),
      inactiveThumbColor: Colors.white,
      trackOutlineColor: WidgetStatePropertyAll(Colors.transparent),
      value: value,
      onChanged: onChanged,
    );
  }
}

Widget dividernoti() {
  return Divider(
    thickness: 0.3,
    color: Colors.grey,
    indent: 20,
    endIndent: 25,
  );
}
