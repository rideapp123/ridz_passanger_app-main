import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/core/services/toast_service.dart';

class CancelRideBottomSheet extends HookWidget {
  const CancelRideBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final commentController = useTextEditingController();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final reasons = useState<List<CancelReasonModel>>([
      'Waiting for long time',
      'Unable to contact driver',
      'Driver denied to go to the destination',
      'Driver denied to come to pickup',
      'Wrong address shown',
      'The price is not reasonable',
      'Other',
    ]
        .map((e) => CancelReasonModel(
              reason: e,
              isSelected: false,
            ))
        .toList());

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(
          right: SizeConfig.screenWidth * 0.04,
          left: SizeConfig.screenWidth * 0.04,
          bottom: Platform.isIOS
              ? SizeConfig.screenHeight * 0.03
              : SizeConfig.screenHeight * 0.01,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.screenWidth * 0.04,
          vertical: SizeConfig.screenHeight * 0.02,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            //
            Container(
              height: 4,
              width: SizeConfig.screenWidth * 0.1,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onTertiary.withValues(alpha: .2),
                borderRadius: BorderRadius.circular(24),
              ),
            ),

            SizedBox(height: SizeConfig.screenHeight * 0.02),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                //
                Text(
                  'Cancelling ride',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),

                Text(
                  'Why do you want to cancel? choose below your reasons',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
              ],
            ),

            SizedBox(height: SizeConfig.screenHeight * 0.01),

            Divider(
              color: !isDarkMode
                  ? const Color(0xffF1F5F9)
                  : const Color(0xff3F3F3F),
            ),

            SizedBox(height: SizeConfig.screenHeight * 0.01),

            ListView.separated(
              itemCount: reasons.value.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              separatorBuilder: (_, __) => SizedBox(
                height: SizeConfig.screenHeight * 0.015,
              ),
              itemBuilder: (_, index) {
                final reason = reasons.value[index];

                return Row(
                  children: [
                    //
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: reasons.value[index].isSelected,
                        splashRadius: 0,
                        onChanged: (value) {
                          final list = List.of(reasons.value);
                          list[index] = reason.copyWith(
                            isSelected: value,
                          );
                          reasons.value = [...list];
                        },
                        checkColor: Theme.of(context).colorScheme.secondary,
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.onPrimary,
                          width: 1.5,
                        ),
                      ),
                    ),

                    SizedBox(width: SizeConfig.screenWidth * 0.02),

                    Text(
                      reasons.value[index].reason,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ],
                );
              },
            ),

            SizedBox(height: SizeConfig.screenHeight * 0.02),

            customTextFormField(
              hintText: 'Write your comment here',
              controller: commentController,
              maxLines: 3,
              contentPadding: EdgeInsets.all(
                SizeConfig.screenHeight * 0.015,
              ),
              focusedBorderColor: Theme.of(context).colorScheme.primaryFixedDim,
              borderWidth: 1,
            ),

            SizedBox(height: SizeConfig.screenHeight * 0.04),

            CustomButton(
              text: 'Submit',
              onTap: () {
                final selectedValues = reasons.value
                    .where((e) => e.isSelected)
                    .map((e) => e.reason)
                    .toList();

                if (selectedValues.isEmpty && commentController.text.isEmpty) {
                  ToastService.show(
                    'Please select a reason or write a comment',
                  );
                  return;
                }

                final reason = selectedValues.isNotEmpty
                    ? selectedValues.join(', ')
                    : commentController.text;

                Navigator.of(context).pop(reason);
              },
            ),
          ],
        ),
      ),
    );
  }
}

@immutable
class CancelReasonModel {
  final String reason;
  final bool isSelected;

  const CancelReasonModel({
    required this.reason,
    required this.isSelected,
  });

  CancelReasonModel copyWith({
    String? reason,
    bool? isSelected,
  }) {
    return CancelReasonModel(
      reason: reason ?? this.reason,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CancelReasonModel &&
        other.reason == reason &&
        other.isSelected == isSelected;
  }

  @override
  int get hashCode => reason.hashCode ^ isSelected.hashCode;
}
