import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_stripe_app/.env.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class AddCardPage extends StatefulWidget {
  @override
  _AddCardPageState createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Card'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardField(
                onCardChanged: (card) {
                  print(card);
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Lấy thông tin thẻ từ CardField
                    final card = await Stripe.instance.createPaymentMethod(
                      PaymentMethodParams.card(
                        billingAddress: Address(
                          postalCode: '12345', // Thay bằng mã bưu điện thực tế
                          // Các trường khác của địa chỉ (nếu cần thiết)
                        ),
                      ),
                    );

                    if (card != null) {
                      // Gọi API để gán phương thức thanh toán vào khách hàng
                      final response = await http.post(
                        Uri.parse('$serverUrl/attach-payment-method'),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({
                          'customerId':
                              customerId, // Thay bằng ID khách hàng thực tế
                          'paymentMethodId': card.id,
                        }),
                      );

                      if (response.statusCode == 200) {
                        Navigator.pop(
                            context); // Quay lại trang trước đó sau khi thêm thẻ thành công
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Card added successfully.')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to add card.')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Invalid card information.')),
                      );
                    }
                  }
                },
                child: Text('Add Card'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
