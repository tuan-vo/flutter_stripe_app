# Flutter Strip App

## Prerequisites

Before running this demo, make sure you have the following prerequisites:

- Flutter SDK (version 3.10.1 or higher)
- Dart SDK (version 3.0.1 or higher)
- Android Studio or VS Code with Flutter extensions installed

## Installation

Follow the steps below to run the demo:

1. Clone the repository:
   ```bash
   https://github.com/tuanvo2908t/flutter_stripe_app.git
   ```
2. Navigate to the project directory:
   ```bash
   cd flutter_stripe_app
   ```
3. flutter pub get
   ```bash
   flutter pub get
   ``
4. Change branch
   ```bash
   git checkout add-and-pay-saved-payment-method
   ``
 
5. Replace the Stripe API keys
- Open .env.dart file.
- Replace :
  ```bash
  const publishable_key = "your_publishable_key";
  const secret_key =  "your_secret_key";
  const customerId = "your_customerId"
  ```
  
6. Run the app:
   ```bash
   flutter run
   ```
---------------------------------
# Functions
- Fast payment : With this function, customers will need to pay with full information
- Add payment methods : With this function, customers will need to pay with full information
- See & Pay saved payment methods : With this function, customers will need to pay with full information

---------------------------------
# Code Explanation
## home_page.dart
This file contains the main logic and UI for the payment page.
- The `HomePage`: class is a stateful widget that represents the home page of the app.
- The `makePayment()`: method handles the payment flow when the "Pay!" button is pressed. It creates a payment intent, configures the payment sheet, initializes it, and then displays it.
- The `createPaymentIntent()` method sends a POST request to the Stripe API to create a payment intent based on the provided amount.
- The `displayPaymentSheet()` method presents the payment sheet UI to the user.

## app.dart
This file defines the MyApp class, which is the entry point for the Flutter app.
- The `MyApp` class extends StatelessWidget and builds the MaterialApp with the specified theme and the HomePage as the initial screen.

## main.dart
This file is the entry point for the Flutter app.
- The `main()` function calls runApp() and starts the MyApp widget.

## payment_page.dart
This page helps users to pay quickly

## add-payment-methods_page.dart
This page allows users to add new payment methods

## saved-cards_page.dart
This page makes it possible for users to view the methods they have saved

## pay-with-saved-method.dart
This page makes it possible for users to view the methods they have saved

---------------------------------
# Steps To Create Application
## 1. Create project.
## 2. Into the file `pubspec.yaml`.
- Add library:
    ```bash
    dependencies:
       flutter_stripe: ^9.2.0
       http: ^0.13.5
    ```
-  Run:
   ``` bash
   flutter pub get 
   ```
   
## 3. Into the folder `lib`

 
## 4. Create `.env.dart` file:
    ```bash
     const publishable_key = "your_publishable_key";
     const secret_key =  "your_secret_key";
     const customerId = "your_customerId";
     ```
     
## 5.  Create `payment_page.dart` file:
- Quick payment page requires full credit card information
   ```bash
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
     
     //interface
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
   ```
   
## 6.  Create `add-payment-methods_page.dart` file:
- New page add user's payment method
   ```bash
   import 'package:flutter/material.dart';
   import 'package:http/http.dart' as http;
   import 'dart:convert';
   import 'package:flutter_stripe_app/.env.dart';

   class PaymentMethodPage extends StatefulWidget {
     @override
     _PaymentMethodPageState createState() => _PaymentMethodPageState();
   }

   class _PaymentMethodPageState extends State<PaymentMethodPage> {
     final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
     final TextEditingController _cardNumberController =
         TextEditingController(text: '4242424242424242');
     final TextEditingController _expiryDateController =
         TextEditingController(text: '12/34');
     final TextEditingController _cvcController =
         TextEditingController(text: '456');
     // final TextEditingController _customerIdController =
     //     TextEditingController(text: customerId);

     @override
     void dispose() {
       _cardNumberController.dispose();
       _expiryDateController.dispose();
       _cvcController.dispose();
       // _customerIdController.dispose();
       super.dispose();
     }

     Future<void> _addPaymentMethod() async {
       if (_formKey.currentState!.validate()) {
         final Map<String, dynamic> paymentMethodData = {
           'type': 'card',
           'card': {
             'number': _cardNumberController.text,
             'exp_month': int.parse(_expiryDateController.text.split('/')[0]),
             'exp_year': int.parse(_expiryDateController.text.split('/')[1]),
             'cvc': _cvcController.text,
           },
         };

         // final customerId = _customerIdController.text;

         final url = 'https://api.stripe.com/v1/payment_methods';
         final headers = {
           'Content-Type': 'application/x-www-form-urlencoded',
           'Authorization': 'Bearer $secret_key',
         };

         final response = await http.post(
           Uri.parse(url),
           headers: headers,
           body: {
             'type': 'card',
             'card[number]': _cardNumberController.text,
             'card[exp_month]': _expiryDateController.text.split('/')[0],
             'card[exp_year]': _expiryDateController.text.split('/')[1],
             'card[cvc]': _cvcController.text,
           },
         );
         print(response.body);
         if (response.statusCode == 200) {
           final paymentMethod = json.decode(response.body);
           final paymentMethodId = paymentMethod['id'];
           print('Payment method created: $paymentMethodId');

           // Associate the payment method with the customer
           final attachUrl =
               'https://api.stripe.com/v1/payment_methods/$paymentMethodId/attach';
           final attachResponse = await http.post(
             Uri.parse(attachUrl),
             headers: headers,
             body: {'customer': customerId},
           );
           if (attachResponse.statusCode == 200) {
             print('Payment method attached to customer successfully');
             // Implement further logic for handling the attached payment method
           } else {
             final error = json.decode(attachResponse.body)['error']['message'];
             print('Failed to attach payment method to customer: $error');
             // Handle the error case
           }
         } else {
           final error = json.decode(response.body)['error']['message'];
           print('Failed to create payment method: $error');
           // Handle the error case
         }
       }
     }

     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(
           title: Text('Add Payment Method'),
         ),
         body: Padding(
           padding: EdgeInsets.all(16.0),
           child: Form(
             key: _formKey,
             child: Column(
               children: [
                 // TextFormField(
                 //   controller: _customerIdController,
                 //   keyboardType: TextInputType.text,
                 //   decoration: InputDecoration(labelText: 'Customer ID'),
                 //   validator: (value) {
                 //     if (value == null || value.isEmpty) {
                 //       return 'Please enter a customer ID';
                 //     }
                 //     return null;
                 //   },
                 // ),
                 TextFormField(
                   controller: _cardNumberController,
                   keyboardType: TextInputType.number,
                   decoration: InputDecoration(labelText: 'Card Number'),
                   validator: (value) {
                     if (value == null || value.isEmpty) {
                       return 'Please enter a card number';
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
                   onPressed: _addPaymentMethod,
                   child: Text('Add Payment Method'),
                 ),
               ],
             ),
           ),
         ),
       );
     }
   }
   ```
   
## 7. Create  `saved-cards_page.dart` and `pay-with-saved-method.dart` file:
- This page shows users the payment methods they have saved, and clicks to choose a method to pay.

pay-with-saved-method.dart
   ```bash
   import 'package:flutter/material.dart';
   import 'package:http/http.dart' as http;
   import 'dart:convert';
   import 'package:flutter_stripe_app/.env.dart';

   class PaymentPage extends StatefulWidget {
     final Map<String, dynamic> paymentMethod;

     const PaymentPage({Key? key, required this.paymentMethod}) : super(key: key);

     @override
     _PaymentPageState createState() => _PaymentPageState();
   }

   class _PaymentPageState extends State<PaymentPage> {
     double totalAmount = 100.0; // Replace with your total amount

     Future<void> _payWithSavedMethod() async {
       final paymentMethodId = widget.paymentMethod['id'];

       final url = 'https://api.stripe.com/v1/payment_intents';
       final headers = {
         'Content-Type': 'application/x-www-form-urlencoded',
         'Authorization': 'Bearer $secret_key',
       };

       final response = await http.post(
         Uri.parse(url),
         headers: headers,
         body: {
           'amount': (totalAmount * 100).toInt().toString(),
           'currency': 'usd',
           'customer': customerId,
           'payment_method': paymentMethodId,
           'confirmation_method': 'automatic',
           'confirm': 'true',
         },
       );
       if (response.statusCode == 200) {
         final paymentIntent = json.decode(response.body);
         final paymentIntentId = paymentIntent['id'];
         print('Payment successful: $paymentIntentId');
         // Implement further logic for handling successful payment
       } else {
         final error = json.decode(response.body)['error']['message'];
         print('Payment failed: $error');
         // Handle the payment failure case
       }
     }

     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(
           title: Text('Payment Page'),
         ),
         body: Center(
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Text(
                 'Total Amount: \$${totalAmount.toStringAsFixed(2)}',
                 style: TextStyle(fontSize: 20),
               ),
               SizedBox(height: 16),
               ElevatedButton(
                 onPressed: _payWithSavedMethod,
                 child: Text('Pay with Saved Method'),
               ),
             ],
           ),
         ),
       );
     }
   }
   ```
saved-cards_page.dart:

   ```bash
   import 'package:flutter/material.dart';
   import 'package:flutter_stripe_app/pay-with-saved-method.dart';
   import 'package:http/http.dart' as http;
   import 'dart:convert';
   import 'package:flutter_stripe_app/.env.dart';

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
         'Authorization': 'Bearer $secret_key',
       };

       // Retrieve the saved cards for the customer from the Stripe API
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
                 // When a card is tapped, navigate to the PaymentPage and pass the selected payment method
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
   ```
## 8. Create `home_page.dart` file: 
- The main interface of the page
   ```bash
   import 'package:flutter/material.dart';
   import 'package:flutter_stripe_app/add-payment-methods_page.dart';
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
                     MaterialPageRoute(builder: (context) => PaymentMethodPage()),
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
   ```
## 9. Create `app.dart` file:
   ```bash
   import 'package:flutter/material.dart';
   import 'package:flutter_stripe_app/home_page.dart';

   class MyApp extends StatelessWidget {
     const MyApp({Key? key});

     @override
     Widget build(BuildContext context) {
       return MaterialApp(
         title: 'Flutter Demo',
         debugShowCheckedModeBanner: false,
         theme: ThemeData(
           primarySwatch: Colors.blue,
         ),
         home: const HomePage(title: 'Flutter Demo Home Page'),
       );
     }
   }
   ```
   
## 10. into the `main.dart` file to change and import the library:
   ```bash
   import 'package:flutter/material.dart';
   import 'package:flutter_stripe_app/app.dart';
   import 'package:flutter_stripe/flutter_stripe.dart';
   import 'package:flutter_stripe_app/.env.dart';

   void main() async {
     Stripe.publishableKey = publishable_key;
     runApp(const MyApp());
   }
   ```


-------------------------------------------
# When you have problems, please refer to the following documents:
https://github.com/flutter-stripe/flutter_stripe#android
