import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../core/theme/size_config.dart';
import '../../../core/theme/styles.dart';
import '../../../stores/users/user_store.dart';
import '../buttons/custom_button.dart';
import '../text/custom_textfield.dart';

class AccountDeleteDialog extends StatefulWidget {
  const AccountDeleteDialog({super.key});

  @override
  State<AccountDeleteDialog> createState() => _AccountDeleteDialogState();
}

class _AccountDeleteDialogState extends State<AccountDeleteDialog> {
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    _confirmController.dispose();
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
        width: SizeConfig.screenWidth * 0.9,
        child: IntrinsicHeight(
          child: Material(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: SizeConfig.safeBlockVertical * 1),
                const Text(
                  'Are you sure want to delete your account?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Styles.TEXT_TITLE_MEDIUM,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                const Icon(
                  Icons.delete_outline,
                  size: 60,
                  color: Colors.red,
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                const Text(
                  'This action is permanent and cannot be undone. All your data will be deleted from our servers after 30 days.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Styles.TEXT_BODY_SMALL,
                    color: Colors.black38,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                Form(
                  key: _formKey,
                  child: customTextFormField(
                      hintText: 'Type "Yes" to confirm',
                      maxLines: 1,
                      removePrefix: true,
                      textAlign: TextAlign.center,
                      controller: _confirmController,
                      contentPadding: EdgeInsets.zero,
                      customValidator: (x) {
                        if (x?.trim().toUpperCase() != 'YES') {
                          return 'Invalid input';
                        }
                        return null;
                      }),
                ),
                SizedBox(height: SizeConfig.safeBlockVertical * 2),
                Wrap(
                  direction: SizeConfig.screenHeight < 400
                      ? Axis.vertical
                      : Axis.horizontal,
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  children: [
                    TextButton(
                      child: const Text(
                        "No, I've changed my mind",
                        style: TextStyle(
                          color: Colors.black45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();
                      },
                    ),
                    if (SizeConfig.screenHeight > 400)
                      const SizedBox(
                        width: 10,
                      ),
                    Observer(
                      builder: (BuildContext context) {
                        return CustomButton(
                          text: 'Delete',
                          color: Colors.red,
                          isLoading: userStoreProvider().isLoginLoading,
                          textColor: Colors.white,
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              await userStoreProvider().logoutUser();
                            }
                          },
                        );
                      },
                    ),
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
