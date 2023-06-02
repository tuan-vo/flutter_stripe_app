import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// final FirebaseFirestore firestore = FirebaseFirestore.instance;

class AddPaymentCard extends StatefulWidget {
  @override
  _AddPaymentCardState createState() => _AddPaymentCardState();
}

class _AddPaymentCardState extends State<AddPaymentCard> {
  TextEditingController userIDController = TextEditingController();
  TextEditingController cardNumberController = TextEditingController();
  TextEditingController expirationController = TextEditingController();
  TextEditingController cvvController = TextEditingController();

  void savePaymentCard() {
    // Lấy giá trị từ các trường nhập liệu
    String userID = userIDController.text;
    String cardNumber = cardNumberController.text;
    String expiration = expirationController.text;
    String cvv = cvvController.text;

    // Tạo một Map chứa dữ liệu
    Map<String, dynamic> data = {
      'userID': userID,
      'cardNumber': cardNumber,
      'expiration': expiration,
      'cvv': cvv,
    };

    // Kiểm tra tính hợp lệ của thông tin thẻ
    bool isValidCardNumber = validateCardNumber(cardNumber);
    bool isValidExpiration = validateExpiration(expiration);
    bool isValidCvv = validateCvv(cvv);

    // Kiểm tra các ràng buộc
    if (isValidCardNumber && isValidExpiration && isValidCvv) {
      // Lưu thông tin thẻ tín dụng vào cơ sở dữ liệu hoặc thực hiện hành động khác
      CollectionReference collRef =
          FirebaseFirestore.instance.collection('method-payment');
      collRef.add(data).then((value) {
        // Hiển thị thông báo hoặc chuyển về trang trước đó
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Thông báo'),
              content: Text('Thẻ tín dụng đã được lưu thành công.'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Đóng hộp thoại
                    Navigator.pop(context); // Quay về trang trước đó
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }).catchError((error) {
        // Xảy ra lỗi khi lưu dữ liệu
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Lỗi'),
              content: Text('Đã xảy ra lỗi khi lưu dữ liệu.'),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Đóng hộp thoại
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      });
    } else {
      // Hiển thị thông báo lỗi khi thông tin thẻ không hợp lệ
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Lỗi'),
            content: Text('Thông tin thẻ không hợp lệ. Vui lòng kiểm tra lại.'),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Đóng hộp thoại
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  bool validateCardNumber(String cardNumber) {
    // Kiểm tra độ dài của số thẻ
    if (cardNumber.length != 16) {
      return false;
    }

    // Kiểm tra định dạng số thẻ (chỉ chấp nhận chữ số)
    if (!RegExp(r'^[0-9]+$').hasMatch(cardNumber)) {
      return false;
    }

    // Các kiểm tra khác tùy theo yêu cầu, ví dụ:
    // - Kiểm tra tính hợp lệ của số thẻ bằng thuật toán Luhn
    // - Kiểm tra hợp lệ với cơ sở dữ liệu thẻ tín dụng

    return true; // Nếu tất cả các ràng buộc đều được thoả mãn
  }

  bool validateExpiration(String expiration) {
    // Kiểm tra độ dài của chuỗi ngày hết hạn
    if (expiration.length != 5) {
      return false;
    }

    // Kiểm tra định dạng ngày hết hạn (MM/YY)
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(expiration)) {
      return false;
    }

    // Kiểm tra tính hợp lệ của ngày hết hạn
    // Ví dụ: Kiểm tra xem ngày hết hạn có lớn hơn ngày hiện tại không

    return true; // Nếu tất cả các ràng buộc đều được thoả mãn
  }

  bool validateCvv(String cvv) {
    // Kiểm tra độ dài của số CVV
    if (cvv.length != 3) {
      return false;
    }

    // Kiểm tra định dạng của số CVV (chỉ chấp nhận chữ số)
    if (!RegExp(r'^[0-9]+$').hasMatch(cvv)) {
      return false;
    }

    return true; // Nếu tất cả các ràng buộc đều được thoả mãn
  }

  @override
  void dispose() {
    userIDController.dispose();
    cardNumberController.dispose();
    expirationController.dispose();
    cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thêm thẻ tín dụng'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: userIDController,
              decoration: InputDecoration(
                labelText: 'Mã người dùng',
              ),
            ),
            TextFormField(
              controller: cardNumberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Số thẻ',
              ),
            ),
            TextFormField(
              controller: expirationController,
              decoration: InputDecoration(
                labelText: 'Ngày hết hạn (MM/YY)',
              ),
            ),
            TextFormField(
              controller: cvvController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'CVV',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: savePaymentCard,
              child: Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }
}
