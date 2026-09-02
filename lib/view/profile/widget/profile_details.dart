import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ridzs_passenger_app/core/theme/app_text_styles.dart';
import 'package:ridzs_passenger_app/widgets/buttons/text_button.dart';

class ProfileDetails extends HookWidget {
  const ProfileDetails({
    super.key,
    required this.icon,
    required this.value,
    required this.title,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: CustomTextButton(
        height: 50,
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
        childWidget: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  shape: BoxShape.circle),
              child: Center(
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              value,
              style: AppTextStyles.subtitle2
                  .copyWith(color: Theme.of(context).colorScheme.onPrimary),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_outlined,
              size: 18,
              color: Theme.of(context).colorScheme.tertiary,
            )
          ],
        ),
      ),
    );
  }
}
