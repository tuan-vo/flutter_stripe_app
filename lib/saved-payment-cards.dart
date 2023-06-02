import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class SavedPaymentCards extends StatelessWidget {
  static Future<List<PaymentCard>> getPaymentCards() async {
    List<PaymentCard> paymentCards = [];

    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('method-payment').get();
    for (QueryDocumentSnapshot document in snapshot.docs) {
      String cardNumber = (document.get('cardNumber')).toString();
      String expiration = document.get('expiration');

      PaymentCard paymentCard =
          PaymentCard(cardNumber: cardNumber, expiration: expiration);
      paymentCards.add(paymentCard);
    }

    return paymentCards;
  }

  // final List<PaymentCard> savedCards;

  // SavedPaymentCards({required this.savedCards});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách thẻ đã lưu'),
      ),
      body: FutureBuilder<List<PaymentCard>>(
        future: getPaymentCards(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Đã xảy ra lỗi.'));
          } else if (snapshot.hasData) {
            List<PaymentCard> paymentCards = snapshot.data!;
            return ListView.builder(
              itemCount: paymentCards.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(paymentCards[index].cardNumber),
                  subtitle: Text(paymentCards[index].expiration),
                  trailing: Icon(Icons.credit_card),
                );
              },
            );
          } else {
            return Center(child: Text('Không có dữ liệu.'));
          }
        },
      ),
    );
  }
}

class PaymentCard {
  final String cardNumber;
  final String expiration;

  PaymentCard({required this.cardNumber, required this.expiration});
}
