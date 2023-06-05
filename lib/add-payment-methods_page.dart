import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const secret_key =
    "sk_test_51N6pjfJjOgMxOgVuIckY4TcIzo2KHIsT540kwHIjmemQ5ISKcBRDOnMvLv4aZA5d1Cxmj2FEVe3FgdDdKZ1FVakv00qT69qCPx";

class PaymentMethodPage extends StatefulWidget {
  @override
  _PaymentMethodPageState createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController =
      TextEditingController(text: '4242424242424242');
  final TextEditingController _expiryDateController =
      TextEditingController(text: '12/34');
  final TextEditingController _cvcController =
      TextEditingController(text: '456');
  final TextEditingController _customerIdController =
      TextEditingController(text: 'cus_O1WLT448ynbR9N');

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvcController.dispose();
    _customerIdController.dispose();
    super.dispose();
  }

  Future<void> _addPaymentMethod() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> paymentMethodData = {
        'type': 'card',
        'card': {
          'number': _cardNumberController.text,
          'exp_month': int.parse(_expiryDateController.text.split('/')[0]),
          'exp_year': int.parse(_expiryDateController.text.split('/')[1]),
          'cvc': _cvcController.text,
        },
      };

      final customerId = _customerIdController.text;

      final url = 'https://api.stripe.com/v1/payment_methods';
      final headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Bearer $secret_key',
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: {
          'type': 'card',
          'card[number]': _cardNumberController.text,
          'card[exp_month]': _expiryDateController.text.split('/')[0],
          'card[exp_year]': _expiryDateController.text.split('/')[1],
          'card[cvc]': _cvcController.text,
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final paymentMethod = json.decode(response.body);
        final paymentMethodId = paymentMethod['id'];
        print('Payment method created: $paymentMethodId');

        // Associate the payment method with the customer
        final attachUrl =
            'https://api.stripe.com/v1/payment_methods/$paymentMethodId/attach';
        final attachResponse = await http.post(
          Uri.parse(attachUrl),
          headers: headers,
          body: {'customer': customerId},
        );
        if (attachResponse.statusCode == 200) {
          print('Payment method attached to customer successfully');
          // Implement further logic for handling the attached payment method
        } else {
          final error = json.decode(attachResponse.body)['error']['message'];
          print('Failed to attach payment method to customer: $error');
          // Handle the error case
        }
      } else {
        final error = json.decode(response.body)['error']['message'];
        print('Failed to create payment method: $error');
        // Handle the error case
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Payment Method'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _customerIdController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: 'Customer ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a customer ID';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Card Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a card number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _expiryDateController,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(labelText: 'Expiry Date (MM/YY)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an expiry date';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _cvcController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'CVC'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the CVC';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _addPaymentMethod,
                child: Text('Add Payment Method'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
