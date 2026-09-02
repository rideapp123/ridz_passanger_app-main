import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ridzs_passenger_app/core/constants/assets.dart';
import 'package:ridzs_passenger_app/core/constants/strings_constant.dart';
import 'package:ridzs_passenger_app/core/theme/app_text_styles.dart';
import 'package:ridzs_passenger_app/core/theme/size_config.dart';
import 'package:ridzs_passenger_app/widgets/containers/custom_image_view.dart';

class TripSearchCommon extends HookWidget {
  final VoidCallback onTapNow;
  final bool isAddButton;
  final bool readOnly;
  final bool isNotNow;
  final void Function(String)? onChanged;
  final void Function(String)? onChangedSecond;
  final String? bottomText;
  final String? topText;
  final TextEditingController currentLocationController;
  final TextEditingController designationController;

  const TripSearchCommon({
    super.key,
    required this.onTapNow,
    this.bottomText,
    this.onChangedSecond,
    this.onChanged,
    this.topText,
    this.isAddButton = false,
    this.isNotNow = false,
    this.readOnly = false,
    required this.designationController,
    required this.currentLocationController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          width: 1.3,
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(10),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: 14.0,
          right: 14,
          top: 10,
          bottom: 10,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 6,
                        width: 6,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: SizeConfig.screenHeight * 0.050,
                        width: 1,
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 6,
                        width: 6,
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        readOnly: true,
                        ignorePointers: true,
                        style: AppTextStyles.style15white.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .tertiaryContainer),
                        cursorColor:
                            Theme.of(context).colorScheme.tertiaryContainer,
                        controller: currentLocationController,
                        decoration: InputDecoration(
                          isDense: true,
                          fillColor: Theme.of(context).colorScheme.secondary,
                          focusColor: Colors.transparent,
                          hintText: topText ?? AppStrings.sanFranciscoUS,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          hintStyle: AppTextStyles.style15white.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerLowest),
                          border: InputBorder.none,
                        ),
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 2,
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerLowest,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 26,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: TextFormField(
                                readOnly: true,
                                ignorePointers: true,
                                style: AppTextStyles.style15white.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onTertiaryContainer),
                                cursorColor: Theme.of(context)
                                    .colorScheme
                                    .onTertiaryContainer,
                                controller: designationController,
                                decoration: InputDecoration(
                                  fillColor:
                                      Theme.of(context).colorScheme.secondary,
                                  focusColor: Colors.transparent,
                                  hintText: bottomText ?? AppStrings.whereTo,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  hintStyle: AppTextStyles.style15white
                                      .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onTertiaryContainer),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: onTapNow,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerLowest,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                ),
                                child: Center(
                                    child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    CustomImageView(
                                      imagePath: Assets.icTime,
                                      height: 15,
                                      width: 15,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppStrings.now,
                                      style: AppTextStyles.style12W600.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary),
                                    ),
                                    const SizedBox(width: 8),
                                    CustomImageView(
                                      imagePath: Assets.icDropdown,
                                      height: 5,
                                      width: 9,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                )),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TripSearchCommonWithADD extends HookWidget {
  final VoidCallback onTapNow;
  final void Function(String)? onChanged;
  final void Function(String)? onChangedSecond;
  final String? bottomText;
  final String? topText;
  final TextEditingController currentLocationController;
  final TextEditingController designationController;

  const TripSearchCommonWithADD(
      {super.key,
      required this.onTapNow,
      this.bottomText,
      this.onChangedSecond,
      this.onChanged,
      this.topText,
      required this.designationController,
      required this.currentLocationController});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              width: 1.3),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 14.0, right: 14, top: 10, bottom: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 6,
                        width: 6,
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary,
                            shape: BoxShape.circle),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: SizeConfig.screenHeight * 0.050,
                        width: 1,
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 6,
                        width: 6,
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        onChanged: onChanged,
                        style: AppTextStyles.style15white.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerLowest),
                        cursorColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerLowest,
                        controller: currentLocationController,
                        decoration: InputDecoration(
                          fillColor: Colors.transparent,
                          isDense: true,
                          focusColor: Colors.transparent,
                          hintText: 'From where',
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          hintStyle: AppTextStyles.style15white.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .tertiaryContainer),
                          border: InputBorder.none,
                        ),
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 2,
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerLowest,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        onChanged: onChangedSecond,
                        style: AppTextStyles.style15white.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerLowest),
                        cursorColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerLowest,
                        controller: designationController,
                        decoration: InputDecoration(
                          isDense: true,
                          fillColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hintText: bottomText ?? AppStrings.whereTo,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          hintStyle: AppTextStyles.style15white.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .tertiaryContainer),
                          border: InputBorder.none,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                InkWell(
                  onTap: onTapNow,
                  child: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerLowest,
                    radius: 18,
                    child: Center(
                      child: Icon(
                        Icons.add,
                        size: 20,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TripSearchCommonWithoutButton extends HookWidget {
  final VoidCallback onTapNow;
  final void Function(String)? onChanged;
  final void Function(String)? onChangedSecond;
  final String? bottomText;
  final String? topText;
  final TextEditingController currentLocationController;
  final TextEditingController designationController;

  const TripSearchCommonWithoutButton(
      {super.key,
      required this.onTapNow,
      this.bottomText,
      this.onChangedSecond,
      this.onChanged,
      this.topText,
      required this.designationController,
      required this.currentLocationController});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              width: 1.3),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Padding(
        padding:
            const EdgeInsets.only(left: 14.0, right: 14, top: 10, bottom: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 6,
                        width: 6,
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.tertiary,
                            shape: BoxShape.circle),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: SizeConfig.screenHeight * 0.050,
                        width: 1,
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 6,
                        width: 6,
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        // height: 26,
                        child: TextFormField(
                          onChanged: onChanged,
                          style: AppTextStyles.style15white.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .tertiaryContainer),
                          cursorColor:
                              Theme.of(context).colorScheme.tertiaryContainer,
                          controller: currentLocationController,
                          ignorePointers: true,
                          decoration: InputDecoration(
                            fillColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            isDense: true,
                            hintText: topText ?? AppStrings.sanFranciscoUS,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            hintStyle: AppTextStyles.style15white.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerLowest),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 2,
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerLowest,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        // height: 26,
                        child: TextFormField(
                          onChanged: onChangedSecond,
                          style: AppTextStyles.style15white.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .tertiaryContainer),
                          cursorColor:
                              Theme.of(context).colorScheme.tertiaryContainer,
                          controller: designationController,
                          ignorePointers: true,
                          decoration: InputDecoration(
                            isDense: true,
                            fillColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hintText: bottomText ?? AppStrings.whereTo,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            hintStyle: AppTextStyles.style15white.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerLowest),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
