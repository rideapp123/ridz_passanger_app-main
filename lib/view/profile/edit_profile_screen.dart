import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/core/helpers/image_picker_helper.dart';
import 'package:ridzs_passenger_app/core/services/toast_service.dart';
import 'package:ridzs_passenger_app/models/contracts/user_details_update_contract.dart';

class EditProfileScreen extends HookWidget {
  static const String routeNamed = 'EditProfileScreen';
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final userStore = userStoreProvider();
    final selectedImage =
        useState(userStore.meResponse?.user.profilePicture ?? '');
    final nameController = useTextEditingController(
      text: userStore.meResponse?.user.name ??
          userStore.meResponse?.user.username ??
          '',
    );

    final emailController = useTextEditingController(
      text: userStore.meResponse?.user.email ?? '',
    );

    final phoneController = useTextEditingController(
      text: userStore.meResponse?.user.mobileNumber ?? '',
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      body: SafeArea(
        child: Column(
          children: [
            //
            const TitleRowWidget(text: 'Edit Profile'),

            const SizedBox(height: 10),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.screenWidth * 0.04,
                ),
                child: Column(
                  children: [
                    //
                    SizedBox(
                      height: SizeConfig.screenHeight * 0.16,
                      child: GestureDetector(
                        onTap: () async {
                          final imageSource =
                              await ImagePickerHelper.imageSourceBottomSheet(
                                  context: context);

                          if (imageSource != null) {
                            final imagePath =
                                await ImagePickerHelper.pickImageFrom(
                                    imageSource);

                            if (imagePath.isNotEmpty) {
                              selectedImage.value = imagePath;
                            }
                          }
                        },
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            (selectedImage.value.isEmpty)
                                ? Container(
                                    height: SizeConfig.screenHeight * 0.14,
                                    width: SizeConfig.screenHeight * 0.14,
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.person,
                                        size: SizeConfig.screenHeight * 0.08,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                : ClipOval(
                                    child: CustomImageView(
                                      url: selectedImage.value.isUrl
                                          ? selectedImage.value
                                          : null,
                                      file: selectedImage.value.isUrl
                                          ? null
                                          : File(selectedImage.value),
                                      fit: BoxFit.cover,
                                      height: SizeConfig.screenHeight * 0.14,
                                      width: SizeConfig.screenHeight * 0.14,
                                    ),
                                  ),

                            //
                            Positioned(
                              bottom: 0,
                              child: Container(
                                alignment: Alignment.center,
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                  color: isDarkMode
                                      ? const Color(0xff141414)
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withValues(
                                        alpha: .2,
                                      ),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: SvgPicture.asset(
                                  Assets.uploadIc,
                                  colorFilter: ColorFilter.mode(
                                    Theme.of(context).colorScheme.surface,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Change Photo',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    SizedBox(height: SizeConfig.screenHeight * 0.05),

                    customTextFormField(
                      controller: nameController,
                      label: 'Name',
                      hintText: 'Enter your name',
                    ),

                    SizedBox(height: SizeConfig.screenHeight * 0.027),

                    customTextFormField(
                      controller: emailController,
                      label: 'Email',
                      hintText: 'Enter your email',
                    ),

                    SizedBox(height: SizeConfig.screenHeight * 0.027),

                    customTextFormField(
                      controller: phoneController,
                      label: 'Phone no',
                      hintText: 'Enter your phone number',
                      enabled: false,
                    ),
                  ],
                ),
              ),
            ),

            //
            Observer(builder: (context) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.screenWidth * 0.04,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        showShadow: false,
                        border: Border.all(
                          color: isDarkMode
                              ? const Color(0xff5A5A5A)
                              : Theme.of(context).colorScheme.scrim,
                        ),
                        shadowColor:
                            Theme.of(context).colorScheme.surfaceContainerHigh,
                        textColor: isDarkMode ? Colors.white : Colors.black,
                        text: 'Cancel',
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(width: SizeConfig.screenWidth * 0.04),
                    Expanded(
                      child: CustomButton(
                        isLoading: userStore.isLoginLoading,
                        text: 'Save Changes',
                        onTap: () async {
                          if (nameController.text.isEmpty) {
                            ToastService.show('Name cannot be empty');
                            return;
                          }

                          if (emailController.text.isNotEmpty) {
                            final emailRegEx = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                            );
                            if (!emailRegEx.hasMatch(emailController.text)) {
                              ToastService.show('Enter a valid email');
                              return;
                            }
                          }

                          String image = '';

                          if (selectedImage.value.isNotEmpty &&
                              !selectedImage.value.isUrl) {
                            image = await userStore
                                .uploadImage(selectedImage.value);
                          }

                          try {
                            await userStore.updateUser(
                              UserDetailsUpdateContract(
                                username: nameController.text,
                                email: emailController.text,
                                mobileNumber: phoneController.text,
                                profilePicture:
                                    image.isEmpty ? selectedImage.value : image,
                              ),
                            );

                            ToastService.show('Profile updated successfully');
                          } catch (e) {
                            debugPrint('Error saving changes: $e');
                            ToastService.show('Failed to save changes');
                          }
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

extension StringUrlExtension on String {
  bool get isUrl {
    // Match http/https URLs including IP addresses, ports, and query strings
    final uri = Uri.tryParse(this);
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }
}
