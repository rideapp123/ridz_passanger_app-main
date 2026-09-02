import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../core/theme/size_config.dart';
import '../../../core/theme/styles.dart';
import '../../../stores/users/user_store.dart';
import '../buttons/custom_button.dart';
import '../text/custom_textfield.dart';

class AppFeedBackDialog extends StatefulWidget {
  const AppFeedBackDialog({super.key});

  @override
  State<AppFeedBackDialog> createState() => _AppFeedBackDialogState();
}

class _AppFeedBackDialogState extends State<AppFeedBackDialog> {
  final _feedbackController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int rating = 0;

  @override
  void dispose() {
    super.dispose();
    _feedbackController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(20),
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
                  'Rate your experience',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 1),
                // ReviewStars(
                //   rating: rating,
                //   height: 24,
                //   width: 24,
                //   onTap: (x) {
                //     rating = x;
                //     setState(() {});
                //   },
                // ),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                Form(
                  key: _formKey,
                  child: customTextFormField(
                      hintText: 'Your feedback!',
                      maxLines: 5,
                      removePrefix: true,
                      contentPadding: const EdgeInsets.only(
                        left:
                            12, // Increase this value to move text more to the right
                        top: 15,
                        bottom: 15,
                        right: 12,
                      ),
                      controller: _feedbackController,
                      customValidator: (x) {
                        if (x!.isEmpty) {
                          return null;
                        }
                        if (x.length < 5) {
                          return 'Please describe further';
                        }
                        return null;
                      }),
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      child: const Text('Remind me later'),
                      onPressed: () async {
                        // await LocalNotificationService.showFeedbackNotification(
                        //     minutes: 360);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                    Observer(
                      builder: (ctx) {
                        return CustomButton(
                          text: 'Submit',
                          color: Styles.COLOR_PRIMARY_ORANGE,
                          isLoading: userStoreProvider().isLoginLoading,
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              // await userStoreProvider().appFeedBack(
                              //     ratings: rating,
                              //     feedback: _feedbackController.text);
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            }
                          },
                        );
                      },
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
