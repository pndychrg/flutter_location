import 'package:country_phone_validator/country_phone_validator.dart';
import 'package:flutter/material.dart';

class PhoneView extends StatefulWidget {
  const PhoneView({super.key});

  @override
  State<PhoneView> createState() => _PhoneViewState();
}

class _PhoneViewState extends State<PhoneView> {
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Phone number validation"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
                onPressed: () {
                  Country? country = CountryUtils.getCountryByIsoCode("IN");
                  if (country != null) {
                    bool isValid = CountryUtils.validatePhoneNumberByContry(
                        _controller.text, country);
                    print(isValid);
                  }
                },
                child: Text("Validate"))
          ],
        ),
      ),
    );
  }
}
