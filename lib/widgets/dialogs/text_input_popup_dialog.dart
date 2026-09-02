import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../core/theme/size_config.dart';
import '../../../core/theme/styles.dart';
import '../buttons/custom_button.dart';
import '../text/custom_textfield.dart';

class TextInputPopupDialog extends HookWidget {
  const TextInputPopupDialog({
    super.key,
    required this.title,
    required this.content,
    required this.primaryActionText,
    required this.secondaryActionText,
    required this.onClose,
    required this.onDone,
    this.validator,
  });

  final String title;
  final Widget content;
  final String primaryActionText;
  final String secondaryActionText;
  final FormFieldValidator<String>? validator;
  final VoidCallback onClose;
  final void Function(String) onDone;

  @override
  Widget build(BuildContext context) {
    final formKey = useState(GlobalKey<FormState>());
    final controller = useTextEditingController();

    useEffect(() {
      return () {
        if (formKey.value.currentState != null) {
          // ignore: invalid_use_of_protected_member
          formKey.value.currentState!.dispose();
        }
      };
    }, [formKey]);

    return AlertDialog.adaptive(
      title: Text(title),
      content: Form(
        key: formKey.value,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            content,
            SizedBox(height: 4 * SizeConfig.safeBlockHorizontal),
            customTextFormField(
              label: '',
              hintText: 'https://www.instagram.com/your_post',
              controller: controller,
              customValidator: validator,
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        CustomButton(
          text: secondaryActionText,
          color: Styles.COLOR_PRIMARY_ORANGE,
          onTap: onClose,
        ),
        CustomButton(
          text: primaryActionText,
          color: Styles.COLOR_PRIMARY_ORANGE,
          onTap: () {
            if (formKey.value.currentState != null) {
              if (formKey.value.currentState!.validate()) {
                onDone(controller.text.trim());
              }
            }
          },
        )
      ],
    );
  }
}
