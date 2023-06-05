import 'package:flutter/material.dart';
import 'package:flutter_stripe_app/pay-with-saved-method.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const secretKey =
    "sk_test_51N6pjfJjOgMxOgVuIckY4TcIzo2KHIsT540kwHIjmemQ5ISKcBRDOnMvLv4aZA5d1Cxmj2FEVe3FgdDdKZ1FVakv00qT69qCPx";
const customerId = 'cus_O1WLT448ynbR9N';

class SavedCardsPage extends StatefulWidget {
  @override
  _SavedCardsPageState createState() => _SavedCardsPageState();
}

class _SavedCardsPageState extends State<SavedCardsPage> {
  List<dynamic> savedCards = [];

  @override
  void initState() {
    super.initState();
    _getSavedCards();
  }

  Future<void> _getSavedCards() async {
    final url = 'https://api.stripe.com/v1/payment_methods';
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Authorization': 'Bearer $secretKey',
    };

    final response = await http.get(Uri.parse(url + '?customer=$customerId'),
        headers: headers);
    if (response.statusCode == 200) {
      final paymentMethods = json.decode(response.body)['data'];
      setState(() {
        savedCards = paymentMethods;
      });
      print('paymentMethods: $paymentMethods');
    } else {
      final error = json.decode(response.body)['error']['message'];
      print('Failed to retrieve saved cards: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Cards'),
      ),
      body: ListView.builder(
        itemCount: savedCards.length,
        itemBuilder: (context, index) {
          final card = savedCards[index]['card'];
          final brand = card['brand'];
          final last4 = card['last4'];
          final expMonth = card['exp_month'];
          final expYear = card['exp_year'];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PaymentPage(paymentMethod: savedCards[index]),
                ),
              );
            },
            child: ListTile(
              leading: Icon(Icons.credit_card),
              title: Text('$brand **** **** **** $last4'),
              subtitle: Text('Expires: $expMonth/$expYear'),
            ),
          );
        },
      ),
    );
  }
}
