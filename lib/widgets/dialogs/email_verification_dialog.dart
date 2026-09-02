import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/constants/assets.dart';
import '../../../core/theme/size_config.dart';
import '../../../core/theme/styles.dart';
import '../../../stores/users/user_store.dart';
import '../buttons/custom_button.dart';
import '../text/textfield/otpfield.dart';

class EmailVerificationDialog extends StatefulWidget {
  const EmailVerificationDialog({super.key, required this.email});
  final String email;

  @override
  State<EmailVerificationDialog> createState() =>
      _EmailVerificationDialogState();
}

class _EmailVerificationDialogState extends State<EmailVerificationDialog> {
  final PageController _pageController = PageController(initialPage: 0);
  final TextEditingController _otpController = TextEditingController();
  int _currentPage = 0;
  Timer? _timer;
  late int _start;
  bool enableResend = false;

  @override
  void initState() {
    _start = 30;
    super.initState();
  }

  void startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
            enableResend = true;
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: (page) {
          setState(() {
            _currentPage = page.toInt();
          });
        },
        children: [
          _buildSentPage(context),
          _buildCheckPage(context),
          _buildVerifiedPage(context),
        ],
      ),
    );
  }

  Widget _buildSentPage(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            clipBehavior: Clip.hardEdge,
            width: SizeConfig.screenWidth * 0.8,
            child: IntrinsicHeight(
              child: Material(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: SizeConfig.safeBlockVertical * 1),
                    const Text(
                      'Verify your email address',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: SizeConfig.safeBlockVertical * 2),
                    SvgPicture.asset(
                      Assets.emailSent,
                    ),
                    SizedBox(height: SizeConfig.safeBlockVertical * 2),
                    const Text(
                      'Please confirm that you want to use this as your email address',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: SizeConfig.safeBlockVertical * 2),
                    Observer(builder: (ctx) {
                      return CustomButton(
                        text: 'Verify',
                        width: 100,
                        height: 35,
                        color: Styles.COLOR_PRIMARY_ORANGE,
                        isLoading: userStoreProvider().isVerifying,
                        onTap: userStoreProvider().isVerifying
                            ? null
                            : () async {
                                await userStoreProvider().requestCode('email');
                                startTimer();
                                _nextPage();
                              },
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckPage(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            clipBehavior: Clip.hardEdge,
            width: SizeConfig.screenWidth * 0.8,
            child: IntrinsicHeight(
              child: Material(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: SizeConfig.safeBlockVertical * 2),
                    SvgPicture.asset(
                      Assets.emailVerify,
                    ),
                    SizedBox(height: SizeConfig.safeBlockVertical * 2),
                    const Text(
                      'Enter the Verification code sent to',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      widget.email,
                      overflow: TextOverflow.clip,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: SizeConfig.safeBlockVertical * 2),
                    OTPField(
                      controller: _otpController,
                      onCompleted: () async {
                        // if (_otpController.length == 6) {
                        //   final response = await userStoreProvider()
                        //       .verifyCode(_otpController.text, 'email');
                        //   if (response == true) {
                        //     _nextPage();
                        //   }
                        // }
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text('$_start seconds'),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Didn't receive the Code?"),
                        TextButton(
                          onPressed: enableResend
                              ? () async {
                                  await userStoreProvider()
                                      .requestCode('email');
                                  setState(() {
                                    _start = 30;
                                    enableResend = false;
                                    startTimer();
                                  });
                                }
                              : null,
                          child: Text(
                            'Resend',
                            style: TextStyle(
                              color: enableResend
                                  ? Styles.COLOR_PRIMARY_ORANGE
                                  : Styles.COLOR_OFF_GREY,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: SizeConfig.safeBlockVertical * 2),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifiedPage(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            clipBehavior: Clip.hardEdge,
            width: SizeConfig.screenWidth * 0.8,
            child: IntrinsicHeight(
              child: Material(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: SizeConfig.safeBlockVertical * 2),
                    const Text(
                      'Hurray!Your email address has been verified',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: SizeConfig.safeBlockVertical * 2),
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xfffd7a2f),
                      size: 100,
                    ),
                    SizedBox(height: SizeConfig.safeBlockVertical * 2),
                    const Text(
                      'You’ve successfully verified your account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: SizeConfig.safeBlockVertical * 2),
                    CustomButton(
                      text: 'LesGo',
                      width: 100,
                      height: 35,
                      fontWeight: FontWeight.w700,
                      color: Styles.COLOR_PRIMARY_ORANGE,
                      onTap: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }
}
