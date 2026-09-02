import 'package:ridzs_passenger_app/core/exports/common_exports.dart';

class Legal extends HookWidget {
  static const String routeNamed = 'Legal';

  const Legal({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme;
    double height = SizeConfig.screenHeight;
    double width = SizeConfig.screenWidth;
    return Scaffold(
      backgroundColor: themeColor.onSecondary,
      body: SingleChildScrollView(
        child: SafeArea(
          bottom: false,
          child: Container(
            height: height,
            width: width,
            decoration: BoxDecoration(color: themeColor.onSecondary),
            child: Column(
              children: [
                TitleRowWidget(
                  text: AppStrings.legal,
                  imageColor: themeColor.tertiary,
                  textStyle: AppTextStyles.style23W600.copyWith(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                SizedBox(height: height * 0.03),
                Container(
                  height: height * 0.84,
                  width: width,
                  decoration: BoxDecoration(color: themeColor.secondary),
                  child: Padding(
                    padding: AppPadding.scaffoldWithTop,
                    child: Column(
                      children: [
                        Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: themeColor.onSecondary),
                            child: Column(
                              children: [
                                _detailsContainer(
                                    themeColor: themeColor, title: "Vinay"),
                                Divider(
                                  height: 1,
                                  color: themeColor.tertiaryFixedDim
                                      .withValues(alpha: 0.3),
                                ),
                                _detailsContainer(
                                    themeColor: themeColor,
                                    title: "flutter .developer@gmail.com"),
                                Divider(
                                  height: 1,
                                  color: themeColor.tertiaryFixedDim
                                      .withValues(alpha: 0.3),
                                ),
                                _detailsContainer(
                                    themeColor: themeColor,
                                    title: "+91 9099099653"),
                              ],
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailsContainer(
      {required ColorScheme themeColor, required String title}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Text(
                title,
                style: AppTextStyles.style15white
                    .copyWith(color: themeColor.onTertiaryContainer),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_outlined,
                color: themeColor.tertiary,
                size: 17,
              )
            ],
          ),
        ),
      ],
    );
  }
}
