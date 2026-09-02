import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../core/exports/common_exports.dart';

class UserAdditionalInfoView extends StatelessWidget {
  const UserAdditionalInfoView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      final driverData = userStoreProvider().meResponse?.user;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context).colorScheme.onPrimaryFixedVariant,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: .2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            //
            _buildAdditionalInfoWidget(
              context: context,
              title: 'Name',
              value: driverData?.username.toString() ?? 'N/A',
              onTap: () {},
            ),

            const Divider(),

            //
            if ((driverData?.email ?? '').isNotEmpty)
              _buildAdditionalInfoWidget(
                context: context,
                title: 'Email',
                value: driverData?.email.toString() ?? 'N/A',
                onTap: () {},
              ),

            if ((driverData?.email ?? '').isNotEmpty) const Divider(),

            //
            _buildAdditionalInfoWidget(
              context: context,
              title: 'Phone no.',
              value: (driverData?.mobileNumber?.isEmpty ?? false)
                  ? 'N/A'
                  : driverData?.mobileNumber ?? 'N/A',
              onTap: () {},
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAdditionalInfoWidget({
    required String title,
    required String value,
    IconData? icon,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : const Color(0xff1B2850),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                //
                const SizedBox(width: 5),

                //
                Icon(
                  icon ?? Icons.arrow_forward_ios_rounded,
                  color: isDarkMode ? Colors.white : const Color(0xff1B2850),
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
