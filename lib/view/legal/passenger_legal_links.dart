import 'package:flutter/material.dart';
import 'regional_information_screen.dart';

class PassengerLegalLinks extends StatelessWidget {
  const PassengerLegalLinks({super.key});
  @override
  Widget build(BuildContext context) => Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final section in [
            RegionalSection.terms,
            RegionalSection.privacy
          ])
            TextButton(
                onPressed: () => Navigator.of(context).pushNamed(
                    RegionalInformationScreen.routeNamed,
                    arguments: {'section': section.kind}),
                child: Text(section == RegionalSection.privacy
                    ? 'Privacy notice'
                    : 'Terms'))
        ],
      );
}

class PassengerLegalMenu extends StatelessWidget {
  const PassengerLegalMenu({super.key});
  @override
  Widget build(BuildContext context) => Column(children: [
        for (final section in [RegionalSection.terms, RegionalSection.privacy])
          ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(section == RegionalSection.terms
                  ? Icons.description_outlined
                  : Icons.privacy_tip_outlined),
              title: Text(section == RegionalSection.terms
                  ? 'Terms'
                  : 'Privacy notice'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).pushNamed(
                  RegionalInformationScreen.routeNamed,
                  arguments: {'section': section.kind})),
        ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.code),
            title: const Text('Software licences'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showLicensePage(
                context: context, applicationName: 'Ridzs Passenger')),
      ]);
}
