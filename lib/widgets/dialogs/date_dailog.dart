import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class DatePickerDialogBox extends StatelessWidget {
  final void Function(DateTime) selectedDate;

  const DatePickerDialogBox({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme;
    return AlertDialog(
      shape: RoundedRectangleBorder(
        side:
        BorderSide(color: Theme.of(context).colorScheme.primary, width: 3),
        borderRadius: BorderRadius.circular(15),
      ),
      shadowColor: Theme.of(context).colorScheme.primary,
      backgroundColor: themeColor.secondary,
      content: Container(
        height: 300,
        width: 300,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: themeColor.secondary,
        ),
        child: SfDateRangePicker(
          headerStyle: DateRangePickerHeaderStyle(
              backgroundColor: themeColor.secondary,
              textStyle: AppTextStyles.style19W600
                  .copyWith(color: themeColor.tertiary)),
          backgroundColor: themeColor.secondary,
          onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
            selectedDate(args.value);
            Navigator.pop(context);
          },
          selectionMode: DateRangePickerSelectionMode.single,
          minDate: DateTime.now(),
          monthViewSettings: DateRangePickerMonthViewSettings(
            viewHeaderStyle: DateRangePickerViewHeaderStyle(
              textStyle: AppTextStyles.style15white
                  .copyWith(color: themeColor.tertiary),
            ),
          ),
          monthCellStyle: DateRangePickerMonthCellStyle(
            textStyle: TextStyle(
              color: themeColor.tertiary,
            ),
          ),
          initialSelectedDate: DateTime.now(),
        ),
      ),
    );
  }
}
