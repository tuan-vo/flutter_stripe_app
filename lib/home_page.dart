import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

const publishable_key =
    "pk_test_51N6pjfJjOgMxOgVuOUaXzf9VAReJKHOLgDgQr2kyxM1I055VmjZCJ2WMDA4EB2A0pjjGYr0atHbWU3Cw2fzCFS0y00QcaPZU1G";
const secret_key =
    "sk_test_51N6pjfJjOgMxOgVuIckY4TcIzo2KHIsT540kwHIjmemQ5ISKcBRDOnMvLv4aZA5d1Cxmj2FEVe3FgdDdKZ1FVakv00qT69qCPx";

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title});

  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      paymentIntent = await createPaymentIntent(amount);
      var gpay = const PaymentSheetGooglePay(
        merchantCountryCode: "US",
        currencyCode: "USD",
        testEnv: true,
      );
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!["client_secret"],
          style: ThemeMode.light,
          merchantDisplayName: "Sabir",
          googlePay: gpay,
        ),
      );

      displayPaymentSheet();
    } catch (e) {
      print(e.toString());
    }
  }

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
        title: const Text("Flutter Stripe"),
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
