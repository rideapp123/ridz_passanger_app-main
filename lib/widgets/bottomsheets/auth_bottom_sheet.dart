import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../core/constants/assets.dart';
import '../../../core/theme/size_config.dart';
import '../../../core/theme/styles.dart';
import '../../../stores/users/user_store.dart';
import '../buttons/custom_button.dart';
import '../buttons/social_button.dart';
import '../text/custom_textfield.dart';

class AuthBottomSheet extends HookWidget {
  const AuthBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final loginInFormKey = useRef(GlobalKey<FormState>());
    final showPassword = useState(false);

    return Padding(
      padding: EdgeInsets.only(
        left: 8 * SizeConfig.blockSizeHorizontal,
        right: 8 * SizeConfig.blockSizeHorizontal,
        top: 8 * SizeConfig.blockSizeHorizontal,
        bottom: 8 * SizeConfig.blockSizeHorizontal,
      ),
      child: Form(
        key: loginInFormKey.value,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              children: [
                customTextFormField(
                  controller: emailController,
                  prefixIconData: Icons.email,
                  label: 'Email',
                  hintText: 'Email',
                  customValidator: emailValidator,
                ),
                SizedBox(
                  height: 5 * SizeConfig.blockSizeHorizontal,
                ),
                customTextFormField(
                  controller: passwordController,
                  prefixIconData: Icons.lock,
                  suffixIconData: showPassword.value
                      ? Icons.visibility_off
                      : Icons.visibility,
                  onSuffixIconTap: () {
                    showPassword.value = !showPassword.value;
                  },
                  label: 'Password',
                  hintText: 'Password',
                  obscureText: !showPassword.value,
                  customValidator: passwordValidator,
                ),
                Container(
                  width: double.infinity,
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {
                      // NavigationService()
                      //     .navigateTo(ForgotPasswordPage.routeNamed);
                    },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(
                  height: 2 * SizeConfig.blockSizeHorizontal,
                ),
                Observer(
                  builder: (BuildContext context) {
                    return CustomButton(
                      width: double.infinity,
                      text: 'Log in',
                      borderRadius: 10,
                      onTap: userStoreProvider().isLoginLoading
                          ? null
                          : () {
                              // This is now a synchronous anonymous function
                              if (loginInFormKey.value.currentState!
                                  .validate()) {
                                try {
                                  // String email = emailController.text.trim();
                                  // String password =
                                  //     passwordController.text.trim();
                                  // Call the async function without await
                                  // userStoreProvider()
                                  //     .login(LoginContract(
                                  //         recipient: email))
                                  //     .catchError((e) {
                                  //   ToastService.show(
                                  //       'Incorrect email or password');
                                  // });
                                } catch (e) {
                                  debugPrint(e.toString());
                                  // Handle exceptions that are not related to the login process itself
                                  debugPrint('Error: ${e.toString()}');
                                }
                              }
                            },
                      color: const Color(0xffff5b00),
                      isLoading: userStoreProvider().isLoginLoading,
                    );
                  },
                ),
                SizedBox(
                  height: 2 * SizeConfig.blockSizeHorizontal,
                ),
                const Text(
                  'or',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            SizedBox(
              height: 2 * SizeConfig.blockSizeHorizontal,
            ),
            SocialLoginButton(
              title: 'Login with Phone Number',
              icon: Assets.call,
              borderColor: Colors.black,
              textColor: Colors.black,
              onTap: () {
                // NavigationService().navigateTo(GenerateOTPScreen.routeNamed);
              },
            ),
            // if (!Platform.isIOS)
            //   SizedBox(
            //     height: 4 * SizeConfig.blockSizeHorizontal,
            //   ),
            // if (!Platform.isIOS)
            //   SocialLoginButton(
            //     title: 'Continue with Google',
            //     icon: Assets.GOOGLE,
            //     borderColor: Colors.black,
            //     textColor: Colors.black,
            //     onTap: () async {
            //       await userStoreProvider().googleSignIn();
            //     },
            //   ),
            // if (SizeConfig.screenHeight < 400)
            SizedBox(
              height: 2 * SizeConfig.blockSizeHorizontal,
            ),
            SizedBox(
              height: 2 * SizeConfig.blockSizeHorizontal,
            ),
            Text.rich(
              textAlign: TextAlign.center,
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'By continuing, you agree to our ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                  TextSpan(
                    text: 'Terms and Conditions',
                    style: const TextStyle(
                        color: Styles.COLOR_PRIMARY_ORANGE, fontSize: 12),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // UtilsHelper.openURLinBrowser(
                        //   FirebaseRemoteConfigService()
                        //       .getString(FirebaseRemoteConfigKeys.tncUrl),
                        // );
                      },
                  ),
                  const TextSpan(
                    text: ' & ',
                    style: TextStyle(
                      color: Styles.COLOR_ON_GREY,
                      fontSize: 12,
                    ),
                  ),
                  TextSpan(
                    text: 'Privacy statement',
                    style: const TextStyle(
                        color: Styles.COLOR_PRIMARY_ORANGE, fontSize: 12),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // UtilsHelper.openURLinBrowser(
                        //   FirebaseRemoteConfigService()
                        //       .getString(FirebaseRemoteConfigKeys.privacyUrl),
                        // );
                      },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
