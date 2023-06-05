import 'package:flutter/material.dart';
import 'package:flutter_stripe_app/app.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  Stripe.publishableKey =
      'pk_test_51N6pjfJjOgMxOgVuOUaXzf9VAReJKHOLgDgQr2kyxM1I055VmjZCJ2WMDA4EB2A0pjjGYr0atHbWU3Cw2fzCFS0y00QcaPZU1G';
  runApp(const MyApp());
}
