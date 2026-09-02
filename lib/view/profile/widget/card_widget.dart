import '../../../core/exports/common_exports.dart';
import '../../../models/response/payment/get_card_response.dart';

class CardWidget extends StatelessWidget {
  const CardWidget({
    super.key,
    required this.cardDetail,
    this.isSelected = false,
    this.isSelectableTile = false,
    this.onRemoveCard,
  });

  final CardDetails cardDetail;
  final bool isSelected;
  final VoidCallback? onRemoveCard;
  final bool isSelectableTile;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelectableTile && isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onPrimaryFixedVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: .2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          //
          SizedBox(
            height: 34,
            width: 60,
            child: Center(
              child: Text(
                '${cardDetail.brand}',
                style: AppTextStyles.style15white.copyWith(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${cardDetail.brand![0].toUpperCase()}${cardDetail.brand!.substring(1)} Card',
                  style: AppTextStyles.style15white.copyWith(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  '**** **** **** ${cardDetail.last4}',
                  style: AppTextStyles.style12W500.copyWith(
                    color: Theme.of(context).colorScheme.onTertiary,
                  ),
                ),
              ],
            ),
          ),

          isSelectableTile
              ? Container(
                  height: SizeConfig.screenHeight * 0.016,
                  width: SizeConfig.screenHeight * 0.016,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    height: SizeConfig.screenHeight * 0.016,
                    width: SizeConfig.screenHeight * 0.016,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: onRemoveCard ?? () {},
                  child: Container(
                    height: SizeConfig.screenHeight * 0.024,
                    width: SizeConfig.screenHeight * 0.024,
                    decoration: const BoxDecoration(
                      color: Color(0xffF34235),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.remove,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),

          const SizedBox(
            width: 10,
          ),
        ],
      ),
    );
  }
}
