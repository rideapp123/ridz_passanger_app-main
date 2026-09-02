import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import '../../../core/services/navigation_service.dart';
import '../../../core/services/toast_service.dart';
import '../../../core/theme/size_config.dart';
import '../../../core/theme/styles.dart';
import '../../../models/contracts/user_details_update_contract.dart';
import '../../../stores/users/user_store.dart';
import '../buttons/custom_button.dart';
import '../text/custom_textfield.dart';

class UpdateUsernameDialog extends HookWidget {
  const UpdateUsernameDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final userNameController = useTextEditingController();
    final formKey = useState(GlobalKey<FormState>());
    final user = useState(userStoreProvider().loggedInUser);

    useEffect(() {
      userNameController.value =
          TextEditingValue(text: user.value?.username ?? '');
      return null;
    }, const []);

    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(20),
        clipBehavior: Clip.hardEdge,
        width: SizeConfig.screenWidth * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Material(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: SizeConfig.safeBlockVertical * 1),
              const Text(
                'Update your username',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: SizeConfig.safeBlockVertical * 2),
              Form(
                key: formKey.value,
                child: customTextFormField(
                    hintText: 'Your username',
                    maxLines: 1,
                    prefixIconData: Icons.person,
                    controller: userNameController,
                    customValidator: (x) {
                      if (x!.isEmpty) {
                        return null;
                      }
                      if (x.length < 5) {
                        return 'Username length must be more than 5 characters';
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
                    child: const Text("I'll do it later"),
                    onPressed: () async {
                      NavigationService().pop();
                    },
                  ),
                  Observer(
                    builder: (ctx) {
                      return CustomButton(
                        text: 'Submit',
                        color: Styles.COLOR_PRIMARY_ORANGE,
                        isLoading: userStoreProvider().isLoginLoading,
                        onTap: () async {
                          if (formKey.value.currentState!.validate()) {
                            await userStoreProvider().updateUser(
                              UserDetailsUpdateContract(
                                  username: userNameController.value.text),
                            );
                            if (userStoreProvider().isError) {
                              ToastService.show('Username Unavailable');
                              return;
                            }

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
    );
  }
}
