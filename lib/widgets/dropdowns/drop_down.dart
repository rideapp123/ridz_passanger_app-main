import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:ridzs_passenger_app/core/theme/app_text_styles.dart';
import 'package:ridzs_passenger_app/widgets/text/custom_textfield.dart';

import '../../../core/theme/styles.dart';

class CustomDropdownButton extends StatelessWidget {
  const CustomDropdownButton({
    this.searchMatchFn,
    required this.hint,
    required this.value,
    required this.dropdownItems,
    required this.onChanged,
    this.selectedItemBuilder,
    this.hintAlignment,
    this.valueAlignment,
    this.buttonHeight,
    this.buttonWidth,
    this.buttonPadding,
    this.buttonDecoration,
    this.buttonElevation,
    this.validator,
    this.icon,
    this.iconSize,
    this.iconEnabledColor,
    this.iconDisabledColor,
    this.itemHeight,
    this.itemPadding,
    this.dropdownHeight,
    this.dropdownWidth,
    this.dropdownPadding,
    this.dropdownDecoration,
    this.dropdownElevation,
    this.scrollbarRadius,
    this.scrollbarThickness,
    this.scrollbarAlwaysShow,
    this.items,
    this.offset = Offset.zero,
    this.searchable = false,
    this.textEditingController,
    this.isDisabled = false,
    this.applyTextScaleFactor = true,
    super.key,
  });
  final String hint;
  final String? value;
  final List<String> dropdownItems;
  final List<DropdownMenuItem<String>>? items;
  final ValueChanged<String?>? onChanged;
  final DropdownButtonBuilder? selectedItemBuilder;
  final Alignment? hintAlignment;
  final Alignment? valueAlignment;
  final double? buttonHeight, buttonWidth;
  final EdgeInsetsGeometry? buttonPadding;
  final BoxDecoration? buttonDecoration;
  final int? buttonElevation;
  final Function(String?)? validator;
  final Function(DropdownMenuItem)? searchMatchFn;
  final Widget? icon;
  final double? iconSize;
  final Color? iconEnabledColor;
  final Color? iconDisabledColor;
  final double? itemHeight;
  final EdgeInsetsGeometry? itemPadding;
  final double? dropdownHeight, dropdownWidth;
  final EdgeInsetsGeometry? dropdownPadding;
  final BoxDecoration? dropdownDecoration;
  final int? dropdownElevation;
  final Radius? scrollbarRadius;
  final double? scrollbarThickness;
  final bool? scrollbarAlwaysShow;
  final Offset offset;
  final bool searchable;
  final bool isDisabled;
  final bool applyTextScaleFactor;

  final TextEditingController? textEditingController;

  @override
  Widget build(BuildContext context) {
    var border =DecoratedInputBorder(
      child: OutlineInputBorder(
        borderSide: BorderSide(
            color: Theme.of(context)
                .colorScheme
                .onTertiaryContainer,
            width: 2),
        borderRadius: Styles.textFieldBorderRadius,
      ),
      shadow: const BoxShadow(
        color: Colors.transparent,
      ),
    );
    return IgnorePointer(
      ignoring: isDisabled,
      child: DropdownButtonFormField2<String>(
        decoration: InputDecoration(
          isCollapsed: true,
          contentPadding: EdgeInsets.zero,
          border: border,
          enabledBorder: border,
          focusedBorder: border,
          disabledBorder: border,
          errorBorder: border,
          // constraints: BoxConstraints(
          //   maxWidth: buttonWidth ?? 250,
          // ),
        ),
        //To avoid long text overflowing.
        isExpanded: true,
        hint: Container(
          alignment: hintAlignment,
          child: Text(
            hint,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: AppTextStyles.style15white.copyWith(
                  color: Theme.of(context).colorScheme.tertiary),
          ),
        ),
        dropdownSearchData: searchable
            ? DropdownSearchData(
                searchController: textEditingController,
                searchInnerWidgetHeight: 50,
                searchInnerWidget: Container(
                  height: 50,
                  padding: const EdgeInsets.only(
                    top: 8,
                    bottom: 2,
                    right: 8,
                    left: 8,
                  ),
                  child: TextFormField(
                    expands: true,
                    maxLines: null,
                    controller: textEditingController,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 0,
                      ),
                      hintText: 'Search...',
                      hintStyle: Theme.of(context).textTheme.bodyMedium,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                searchMatchFn: (item, searchValue) {
                  final items = item.value
                      .toString()
                      .toLowerCase()
                      .contains(searchValue.toLowerCase());
                  return items;
                },
              )
            : null,
        // customButton: Container(child: const Icon(Icons.arrow_drop_down_sharp)),
        value: value == null || value!.isEmpty ? null : value,
        items: items ??
            dropdownItems
                .map((String item) => DropdownMenuItem<String>(
                      value: item,
                      child: Container(
                        alignment: valueAlignment,
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ))
                .toList(),
        onChanged: onChanged,
        selectedItemBuilder: selectedItemBuilder,
        validator: (String? value) {
          if (validator != null) {
            String? errorMessage = validator!(value);
            return errorMessage;
          }
          return 'No';
        },
        buttonStyleData: ButtonStyleData(
          height: buttonHeight ?? 50,
          padding: buttonPadding ?? const EdgeInsets.only(left: 14, right: 14),
          decoration: buttonDecoration ??
              BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Styles.COLOR_PRIMARY_ORANGE,
                ),
              ),
          elevation: buttonElevation,
        ),
        iconStyleData: IconStyleData(
          icon: icon ?? const Icon(Icons.arrow_drop_down_sharp),
          iconSize: iconSize ?? 24,
          iconEnabledColor: iconEnabledColor,
          iconDisabledColor: iconDisabledColor,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: dropdownHeight ?? 250,
          padding: dropdownPadding,
          decoration: dropdownDecoration ??
              BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
          elevation: dropdownElevation ?? 8,
          //Null or Offset(0, 0) will open just under the button. You can edit as you want.
          offset: offset,
          // scrollbarTheme: ScrollbarThemeData(
          //   radius: scrollbarRadius ?? const Radius.circular(40),
          //   thickness: scrollbarThickness != null
          //       ? MaterialStateProperty.all<double>(scrollbarThickness!)
          //       : null,
          //   thumbVisibility: scrollbarAlwaysShow != null
          //       ? MaterialStateProperty.all<bool>(scrollbarAlwaysShow!)
          //       : null,
          // ),
        ),
        menuItemStyleData: MenuItemStyleData(
          height: itemHeight ?? 40,
          padding: itemPadding ?? const EdgeInsets.only(left: 14, right: 20),
        ),
      ),
    );
  }
}
