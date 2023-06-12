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
   ```
4. Change branch
   ```bash
   git checkout flutter_stripe_creadit
   ```
 
5. Replace the Stripe API keys
- Open .env.dart file.
- Replace :
  ```bash
  const publishable_key = "your_publishable_key";
  const secret_key =  "your_secret_key";
  const serverUrl = "your_serverUrl"
  ```
  
6. Run the app:
   ```bash
   flutter run
   ```
---------------------------------
# Functions
- Fast payment : With this function, customers will need to pay with full information


---------------------------------
# Code Explanation
## home_page.dart
This file contains the main logic and UI for the payment page.
- The `HomePage`: class is a stateful widget that represents the home page of the app.

## app.dart
This file defines the MyApp class, which is the entry point for the Flutter app.
- The `MyApp` class extends StatelessWidget and builds the MaterialApp with the specified theme and the HomePage as the initial screen.

## main.dart
This file is the entry point for the Flutter app.
- The `main()` function calls runApp() and starts the MyApp widget.

## payment_page.dart
This page helps users to pay quickly


---------------------------------
# Steps To Create Application
## 1. Prepare API
   ```bash
   app.post('/create-customer', async (req, res) => {
   const { name, email } = req.body;
   // Check if customer already exists in Stripe
   const existingCustomers = await stripe.customers.list({ email: email });
   if (existingCustomers.data.length > 0) {
   // Customer already exists, return current customer information
   res.send({ customer: existingCustomers.data[0], isCheck: true });
   return;
   }
   // Create a new customer object
   const customer = await stripe.customers.create({
   name: name,
   email: email,
   });
   res.send({ customer });
   });
   ```
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
  const serverUrl = "your_serverUrl"
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
     TextEditingController emailController = TextEditingController();
     TextEditingController nameController = TextEditingController();
     TextEditingController amountController = TextEditingController();
     bool isLoading = false;
     Map<String, dynamic>? paymentMethod;

     @override
     void dispose() {
       emailController.dispose();
       nameController.dispose();
       amountController.dispose();
       super.dispose();
       Stripe.publishableKey = publishable_key;
     }

     Future<void> createCustomer() async {
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
           await makePayment(customerId);
         } else {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text("Failed to create customer.")),
           );
         }
       } catch (e) {
         print('An error occurred: $e');
       } finally {
         setState(() {
           isLoading = false;
         });
       }
     }

     Future<void> makePayment(String customerId) async {
       try {
         final paymentIntent = await createPaymentIntent(customerId);

         final gpay = const PaymentSheetGooglePay(
           merchantCountryCode: "JP",
           currencyCode: "JPY",
           testEnv: true,
         );
         await Stripe.instance.initPaymentSheet(
           paymentSheetParameters: SetupPaymentSheetParameters(
             paymentIntentClientSecret: paymentIntent!["client_secret"],
             customerId: customerId,
             style: ThemeMode.light,
             merchantDisplayName: "Sabir",
             googlePay: gpay,
           ),
         );
         await Stripe.instance.presentPaymentSheet();
       } catch (e) {
         print("error: $e");
       }
     }

     Future<Map<String, dynamic>> createPaymentIntent(String customerId) async {
       try {
         final amount = amountController.text;
         final body = {
           "amount": amount,
           "currency": "JPY",
           "customer": customerId
         };

         final response = await http.post(
           Uri.parse("https://api.stripe.com/v1/payment_intents"),
           body: body,
           headers: {
             "Authorization": "Bearer $secret_key",
             "Content-Type": "application/x-www-form-urlencoded",
           },
         );
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
                 onPressed: isLoading ? null : createCustomer,
                 child: Text('Payment!'),
               ),
             ],
           ),
         ),
       );
     }
   }

   ```

## 8. Create `home_page.dart` file: 
- The main interface of the page
   ```bash
   import 'package:flutter/material.dart';
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
     WidgetsFlutterBinding.ensureInitialized();
     Stripe.publishableKey = publishable_key;
     runApp(const MyApp());
   }

   ```


-------------------------------------------
# When you have problems, please refer to the following documents:
https://github.com/flutter-stripe/flutter_stripe#android
