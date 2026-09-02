import 'package:image_picker/image_picker.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';

class PickImageSourceWidget extends StatelessWidget {
  const PickImageSourceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: SizeConfig.screenHeight * 0.02,
      ),
      height: SizeConfig.screenHeight * 0.14,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ///
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: SizeConfig.screenWidth * 0.04,
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          Navigator.of(context).pop(ImageSource.camera),
                      child: Container(
                        margin: EdgeInsets.only(
                          bottom: SizeConfig.screenHeight * 0.005,
                        ),
                        height: SizeConfig.screenHeight * 0.06,
                        width: SizeConfig.screenHeight * 0.06,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .tertiaryContainer
                                .withValues(alpha: 0.5),
                            width: 1.0,
                          ),
                        ),
                        child: Icon(
                          Icons.photo_camera,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    Text(
                      'Camera',
                      style: textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.scrim,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: SizeConfig.screenWidth * 0.06,
                ),

                //
                Column(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          Navigator.of(context).pop(ImageSource.gallery),
                      child: Container(
                        margin: EdgeInsets.only(
                          bottom: SizeConfig.screenHeight * 0.005,
                        ),
                        height: SizeConfig.screenHeight * 0.06,
                        width: SizeConfig.screenHeight * 0.06,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .tertiaryContainer
                                .withValues(alpha: 0.5),
                            width: 1.0,
                          ),
                        ),
                        child: Icon(
                          Icons.collections,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    Text(
                      'Gallery',
                      style: textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.scrim,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
