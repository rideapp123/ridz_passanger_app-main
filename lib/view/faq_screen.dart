import 'package:ridzs_passenger_app/core/exports/common_exports.dart';

class FAQScreen extends StatelessWidget {
  static const String routeNamed = 'FAQScreen';
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<FAQ> faqList = [
      FAQ(
        question: "How does this app work?",
        answer:
            "Open the app, request a ride, and get matched with the nearest driver. Payment and ride tracking are handled in the app.",
      ),
      FAQ(
        question: "How is this different from Uber or Lyft?",
        answer:
            "Our platform gives 100% of the fare directly to the driver (after government fees), supporting local drivers fairly.",
      ),
      FAQ(
        question: "How are fares calculated?",
        answer:
            "Fares are based on distance, duration, local base fare, and any applicable taxes (e.g., GST/HST).",
      ),
      FAQ(
        question: "How do I pay for a ride?",
        answer: "Pay securely using credit/debit card or digital wallet.",
      ),
      FAQ(
        question: "Is there a booking or service fee?",
        answer: "No. You only pay the final fare shown upfront.",
      ),
      FAQ(
        question: "Do I need to tip the driver?",
        answer:
            "Tipping is optional but appreciated. You can tip after the ride ends through the app.",
      ),
      FAQ(
        question: "Can I cancel a ride?",
        answer:
            "Yes, but a cancellation fee may apply depending on when you cancel.",
      ),
      FAQ(
        question: "How do I know if my driver is verified?",
        answer:
            "Drivers undergo background checks, vehicle safety checks, and identity verification.",
      ),
      FAQ(
        question: "Is my location and personal data safe?",
        answer:
            "Yes. Your data is encrypted and never shared without consent, following PIPEDA guidelines.",
      ),
      FAQ(
        question: "What if I forget something in the car?",
        answer:
            "Report a lost item via the app. We'll contact the driver on your behalf.",
      ),
      FAQ(
        question: "How do I rate a driver or give feedback?",
        answer:
            "After each ride, leave a 1-5 star rating and optional comment.",
      ),
      FAQ(
        question: "How do I get help or report a problem?",
        answer:
            "Use the app's Help & Support section or email support@yourplatform.ca.",
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: SafeArea(
          child: Column(
        children: [
          //
          const TitleRowWidget(text: 'FAQs'),

          Expanded(
            child: ListView.separated(
              itemCount: faqList.length,
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.screenWidth * 0.04,
              ),
              separatorBuilder: (context, index) => SizedBox(
                height: SizeConfig.screenHeight * 0.01,
              ),
              itemBuilder: (context, index) {
                final faq = faqList[index];
                return Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  child: ExpansionTile(
                    collapsedIconColor: Theme.of(context).colorScheme.shadow,
                    title: Text(
                      faq.question,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          faq.answer,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.shadow,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      )),
    );
  }
}

class FAQ {
  final String question;
  final String answer;

  FAQ({required this.question, required this.answer});
}
