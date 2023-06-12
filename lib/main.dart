import 'package:flutter/material.dart';
import 'package:flutter_stripe_app/app.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_stripe_app/.env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = publishable_key;
  runApp(const MyApp());
}
