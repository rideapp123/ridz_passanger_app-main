import 'package:ridzs_passenger_app/core/exports/common_exports.dart';

class TermsAndConditionScreen extends StatelessWidget {
  static const String routeNamed = 'TermsAndConditionScreen';
  const TermsAndConditionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: SafeArea(
        child: Column(
          children: [
            //
            const TitleRowWidget(text: 'Terms and Conditions'),

            Expanded(
              child: ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  itemCount: TermSection.termsAndConditions.length,
                  itemBuilder: (context, index) {
                    final section = TermSection.termsAndConditions[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            section.content,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.surface,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class TermSection {
  final String title;
  final String content;

  const TermSection({required this.title, required this.content});

  static const termsAndConditions = [
    TermSection(
      title: "0. Definitions",
      content:
          '"Platform": The ride-hailing mobile and web application owned and operated by the Company.\n'
          '"Driver": An individual authorized to use the Platform to provide transportation services.\n'
          '"User": Any person using the Platform to book and pay for rides.\n'
          '"Company": The legal entity operating the Platform.',
    ),
    TermSection(
      title: "1. Agreement",
      content:
          "By registering on or using the Platform, both Drivers and Users agree to these Terms and Conditions. "
          "These terms govern access to and usage of the Platform and its services.",
    ),
    TermSection(
      title: "2. Eligibility",
      content: "For Drivers:\n"
          "- Must hold a valid Canadian driver’s license.\n"
          "- Must own or lease a vehicle that meets applicable provincial regulations.\n"
          "- Must carry valid personal or commercial auto insurance.\n"
          "- Must pass a background check and vehicle inspection.\n"
          "- Must be legally authorized to work in Canada.\n\n"
          "For Users:\n"
          "- Must be at least 18 years old.\n"
          "- Must provide accurate personal and payment information.",
    ),
    TermSection(
      title: "3. Driver Platform Access Fee",
      content:
          "Drivers pay a fixed monthly fee (e.g., \$100 CAD) to access the Platform.\n"
          "- The fee is non-refundable and due in advance.\n"
          "- The Company may revise this fee with 15 days’ prior notice.",
    ),
    TermSection(
      title: "4. Ride Payments",
      content:
          "Users are charged per ride based on time, distance, and applicable taxes.\n\n"
          "- 100% of the ride fare (excluding taxes and payment fees) is paid to the Driver.\n"
          "- The Platform deducts government-mandated fees (GST/HST) and payment processing fees.\n"
          "- Drivers are responsible for tax reporting and remittance.",
    ),
    TermSection(
      title: "5. Driver Conduct",
      content: "- Must treat Users professionally and respectfully.\n"
          "- Must comply with local driving and safety laws.\n"
          "- Misconduct, harassment, or unsafe behavior may lead to suspension or removal.",
    ),
    TermSection(
      title: "6. User Conduct",
      content: "- Users must respect Drivers and their vehicles.\n"
          "- Abuse, fraud, or violation of rules may lead to account suspension.",
    ),
    TermSection(
      title: "7. Insurance and Liability",
      content:
          "The Company provides insurance coverage only while Drivers are active on the Platform (marked 'Available').\n"
          "Insurance covers:\n"
          "- Third-party liability\n"
          "- Collision\n"
          "- Accident benefits\n"
          "- Uninsured motorist incidents\n\n"
          "Drivers must still hold personal/commercial insurance.",
    ),
    TermSection(
      title: "8. Service Availability",
      content:
          "The Company strives to provide continuous Platform access but does not guarantee availability. "
          "Temporary downtime may occur for maintenance or unforeseen issues.",
    ),
    TermSection(
      title: "9. Data and Privacy",
      content:
          "The Platform collects personal and location data to provide its services.\n"
          "- All data is handled according to PIPEDA (Canada’s privacy law).\n"
          "- Data is not shared with third parties without consent, unless required by law.",
    ),
    TermSection(
      title: "10. Termination",
      content: "Users and Drivers may terminate their accounts anytime.\n\n"
          "The Company reserves the right to suspend or terminate access for violations, fraud, or legal non-compliance.",
    ),
    TermSection(
      title: "11. Amendments",
      content:
          "The Company may modify these Terms with prior notice of at least 15 days.\n"
          "Continued use of the Platform implies acceptance of the updated Terms.",
    ),
    TermSection(
      title: "12. Governing Law",
      content:
          "These Terms are governed by the laws of the Province of [Insert Province], Canada.",
    ),
    TermSection(
      title: "13. Contact",
      content: "📧 support@yourplatform.ca\n📞 1-800-XXX-XXXX",
    ),
  ];
}
