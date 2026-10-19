import 'package:flutter/material.dart';
import 'legal/regional_information_screen.dart';

class FAQScreen extends StatelessWidget {
  static const String routeNamed = 'FAQScreen';
  const FAQScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const RegionalInformationScreen(initialSection: RegionalSection.support);
}
