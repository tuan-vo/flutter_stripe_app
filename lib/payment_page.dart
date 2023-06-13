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
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    amountController.dispose();
    super.dispose();
    Stripe.publishableKey = publishable_key;
  }

  Future<void> makePayment() async {
    setState(() {
      isLoading = true;
    });

    try {
      String email = emailController.text;
      String name = nameController.text;

      final response = await http.post(
        Uri.parse('$serverUrl/create-customer'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final customerId = data['customer']['id'];
        final isCheck = data['isCheck'] ?? false;
        final message = isCheck
            ? "Email is already in use."
            : "Customer created successfully.";

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );

        final paymentIntent = await createPaymentIntent(customerId);
        final gpay = const PaymentSheetGooglePay(
          merchantCountryCode: "JP",
          currencyCode: "JPY",
          testEnv: true,
        );

        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntent!["client_secret"],
            customerEphemeralKeySecret: paymentIntent!["ephemeralKey"],
            customerId: customerId,
            style: ThemeMode.light,
            merchantDisplayName: "Sabir",
            googlePay: gpay,
          ),
        );

        await Stripe.instance.presentPaymentSheet();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment successfully.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create customer.")),
        );
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(String customerId) async {
    try {
      final amount = amountController.text;
      final response = await http.post(
        Uri.parse('$serverUrl/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'customerId': customerId, 'amount': amount}),
      );
      print(response.body);
      return json.decode(response.body);
    } catch (e) {
      throw Exception('Failed to create payment intent: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Demo'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount',
              ),
            ),
            TextField(
              controller: nameController,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                labelText: 'Name',
              ),
            ),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: isLoading ? null : makePayment,
              child: Text('Payment!'),
            ),
          ],
        ),
      ),
    );
  }
}
