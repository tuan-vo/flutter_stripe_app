import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const secretKey =
    "sk_test_51N6pjfJjOgMxOgVuIckY4TcIzo2KHIsT540kwHIjmemQ5ISKcBRDOnMvLv4aZA5d1Cxmj2FEVe3FgdDdKZ1FVakv00qT69qCPx";
const customerId = 'cus_O1WLT448ynbR9N';

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> paymentMethod;

  const PaymentPage({Key? key, required this.paymentMethod}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  double totalAmount = 100.0; // Replace with your total amount

  Future<void> _payWithSavedMethod() async {
    final paymentMethodId = widget.paymentMethod['id'];

    final url = 'https://api.stripe.com/v1/payment_intents';
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $secretKey',
    };

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: {
        'amount': (totalAmount * 100).toInt().toString(),
        'currency': 'usd',
        'customer': customerId,
        'payment_method': paymentMethodId,
        'confirmation_method': 'automatic',
        'confirm': 'true',
      },
    );
    if (response.statusCode == 200) {
      final paymentIntent = json.decode(response.body);
      final paymentIntentId = paymentIntent['id'];
      print('Payment successful: $paymentIntentId');
      // Implement further logic for handling successful payment
    } else {
      final error = json.decode(response.body)['error']['message'];
      print('Payment failed: $error');
      // Handle the payment failure case
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Total Amount: \$${totalAmount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _payWithSavedMethod,
              child: Text('Pay with Saved Method'),
            ),
          ],
        ),
      ),
    );
  }
}
