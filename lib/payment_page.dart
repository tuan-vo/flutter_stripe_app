import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe_app/.env.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  TextEditingController amountController = TextEditingController();
  Map<String, dynamic>? paymentIntent;

  @override
  void initState() {
    super.initState();
    Stripe.publishableKey = publishable_key;
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  void makePayment() async {
    try {
      String amount = amountController.text;

      // Create a payment intent
      paymentIntent = await createPaymentIntent(amount);

      // Create a payment intent
      var gpay = const PaymentSheetGooglePay(
        merchantCountryCode: "US",
        currencyCode: "USD",
        testEnv: true,
      );

      // Create a payment intent
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!["client_secret"],
          style: ThemeMode.light,
          merchantDisplayName: "Sabir",
          googlePay: gpay,
        ),
      );

      // Display the payment sheet
      displayPaymentSheet();
    } catch (e) {
      print(e.toString());
    }
  }

  // Present the payment sheet
  void displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      print("Done");
    } catch (e) {
      print("Failed");
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(amount) async {
    try {
      Map<String, dynamic> body = {
        "amount": amount,
        "currency": "USD",
      };

      // Send a POST request to create a payment intent
      http.Response response = await http.post(
        Uri.parse("https://api.stripe.com/v1/payment_intents"),
        body: body,
        headers: {
          "Authorization": "Bearer $secret_key",
          "Content-Type": "application/x-www-form-urlencoded",
        },
      );
      return json.decode(response.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Total',
              ),
            ),
            ElevatedButton(
              onPressed: makePayment,
              child: const Text("Pay!"),
            ),
          ],
        ),
      ),
    );
  }
}
