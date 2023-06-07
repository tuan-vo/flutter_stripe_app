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
2. Navigate to the project directory:
   ```bash
   cd flutter_stripe_app
3. flutter pub get
   ```bash
   flutter pub get
4. Change branch
   ```bash
   git checkout add-and-pay-saved-payment-method
 
5. Replace the Stripe API keys
- Open .env.dart file.
- Replace :
  ```bash
  // Constants for Stripe API keys
  const publishable_key = "your_publishable_key";
  const secret_key =  "your_secret_key";
  const customerId = "your_customerId"
  
6. Run the app:
   ```bash
   flutter run
   
# Functions
- Fast payment : With this function, customers will need to pay with full information
- Add payment methods : With this function, customers will need to pay with full information
- See & Pay saved payment methods : With this function, customers will need to pay with full information

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

-------------------------------------------
# When you have problems, please refer to the following documents:
https://github.com/flutter-stripe/flutter_stripe#android
