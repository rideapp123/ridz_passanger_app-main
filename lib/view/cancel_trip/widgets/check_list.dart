import 'package:ridzs_passenger_app/core/exports/common_exports.dart';

class CustomCheckBoxTile extends HookWidget {
  final String label;

  const CustomCheckBoxTile({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isChecked =
        useState(false); // Using useState to manage checkbox state
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
      child: Row(
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: Checkbox(
              value: isChecked.value,
              onChanged: (bool? newValue) {
                isChecked.value = newValue ?? false;
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2),
              ),
              checkColor: Theme.of(context).colorScheme.secondary,
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              style: AppTextStyles.style15white
                  .copyWith(color: Theme.of(context).colorScheme.tertiary),
            ),
          ),
        ],
      ),
    );
  }
}
