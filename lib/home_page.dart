import 'package:flutter/material.dart';
import 'package:flutter_stripe_app/payment_page.dart';
import 'package:flutter_stripe_app/add-card.dart';
import 'package:flutter_stripe_app/saved-cards_page.dart';
import 'package:flutter_stripe_app/payment_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddCardPage()),
                );
              },
              child: const Text("Add payment methods!"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SavedCardsPage()),
                );
              },
              child: const Text("See & Pay saved payment methods!"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PaymentPage()),
                );
              },
              child: const Text("Fast pay!"),
            ),
          ],
        ),
      ),
    );
  }
}
