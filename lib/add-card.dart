import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '.env.dart';
import 'package:flutter/services.dart';

class AddCardPage extends StatefulWidget {
  final String customerId;

  AddCardPage({required this.customerId});

  @override
  _AddCardPageState createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvcController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  Future<void> addCard() async {
    try {
      final url =
          '$serverUrl/add-card'; // Thay thế bằng URL của API Laravel của bạn

      final response = await http.post(
        Uri.parse(url),
        body: json.encode({'customerId': customerId}),
        headers: {'Content-Type': 'application/json'},
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        // Xử lý phản hồi thành công
        final responseData = json.decode(response.body);
        print(responseData); // Hoặc xử lý dữ liệu theo cách bạn muốn
      } else {
        // Xử lý phản hồi lỗi
        print('Failed to add card: ${response.body}');
      }
    } catch (error) {
      // Xử lý lỗi kết nối hoặc lỗi xử lý
      print('Error adding card: $error');
    }
  }

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
            children: [
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(16), // Giới hạn 16 ký tự
                  FilteringTextInputFormatter
                      .digitsOnly, // Chỉ cho phép nhập số
                ],
                decoration: InputDecoration(labelText: 'Card Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a card number';
                  }
                  if (value.length != 16) {
                    return 'Please enter a valid 16-digit card number';
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
                onPressed: addCard,
                child: Text('Add Card'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
