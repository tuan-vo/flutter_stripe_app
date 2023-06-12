import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe_app/.env.dart';

const serverUrl = 'http://192.168.1.5:4242'; // Địa chỉ URL của máy chủ

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  TextEditingController amountController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  Map<String, dynamic>? paymentSheetData;
  Map<String, dynamic>? paymentIntent;

  @override
  void initState() {
    super.initState();
    Stripe.publishableKey =
        publishable_key; // Thay thế bằng Publishable Key của bạn
  }

  @override
  void dispose() {
    amountController.dispose();
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> createSubscription() async {
    try {
      final response = await http.post(
        Uri.parse('$serverUrl/create-subscription'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': nameController.text,
          'email': emailController.text,
          'price': int.parse(amountController.text),
        }),
      );
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    } catch (e) {
      throw Exception('Failed to create subscription: $e');
    }
  }

  void makePayment() async {
    try {
      // Kiểm tra xem tên và email đã được nhập
      if (nameController.text.isEmpty || emailController.text.isEmpty) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Please enter your name and email'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
      // Khởi tạo PaymentSheetGooglePay
      final gpay = PaymentSheetGooglePay(
        merchantCountryCode: "JP",
        currencyCode: "JPY",
        testEnv: true,
      );
      // Tạo một subscription trên server
      final subscriptionData = await createSubscription();
      // Khởi tạo Stripe
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: subscriptionData['clientSecret'],
          customerEphemeralKeySecret: subscriptionData['ephemeralKey'],
          customerId: subscriptionData['customer'],
          style: ThemeMode.light,
          merchantDisplayName: "Your Merchant Name",
          googlePay: gpay,
        ),
      );
      // Hiển thị giao diện thanh toán
      await Stripe.instance.presentPaymentSheet();
      print('Payment successful');
    } catch (e) {
      print('Payment failed: $e');
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
            TextField(
              controller: nameController,
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
