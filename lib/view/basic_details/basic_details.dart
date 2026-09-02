import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/widgets/dropdowns/drop_down.dart';

class BasicDetails extends HookWidget {
  const BasicDetails({super.key});

  static const String routeNamed = 'BasicDetails';

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme;
    final selectedGender = useState('Male');
    List<String> bloodGroups = [
      'A+',
      'A-',
      'B+',
      'B-',
      'AB+',
      'AB-',
      'O+',
      'O-'
    ];
    final selectedBloodGroup = useState<String?>(null);
    final loginInFormKey = useRef(GlobalKey<FormState>());
    final emailController = useTextEditingController();
    final nameController = useTextEditingController();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondary,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: loginInFormKey.value,
            child: Padding(
              padding: AppPadding.containerHorizontal40,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: SizeConfig.screenHeight * 0.10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: themeColor.tertiary,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: themeColor.onTertiary,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Expanded(
                          child: Container(
                            height: 4,
                            color: themeColor.onTertiary,
                          ),
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Expanded(
                          child: Container(
                            height: 4,
                            color: themeColor.onTertiary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: SizeConfig.screenHeight * 0.10),
                    Text(AppStrings.basicDetails,
                        style: AppTextStyles.style23W600),
                    customTextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textInputType: TextInputType.emailAddress,
                      customValidator: nameValidator,
                      controller: nameController,
                      inputTextColor:
                          Theme.of(context).colorScheme.onTertiaryContainer,
                      label: AppStrings.name,
                      hintText: AppStrings.pleaseEnterYourEmailAddress,
                    ),
                    const SizedBox(height: 20),
                    customTextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textInputType: TextInputType.emailAddress,
                      customValidator: emailValidator,
                      controller: emailController,
                      inputTextColor:
                          Theme.of(context).colorScheme.onTertiaryContainer,
                      label: AppStrings.email,
                      hintText: AppStrings.enterYourMail,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Select Gender',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                            child: _buildGenderOption(
                                'Male', selectedGender, context)),
                        Expanded(
                            child: _buildGenderOption(
                                'Female', selectedGender, context)),
                        Expanded(
                            child: _buildGenderOption(
                                'Other', selectedGender, context)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CustomDropdownButton(
                      hint: 'Select blood group',
                      value: selectedBloodGroup.value,
                      dropdownItems: bloodGroups,
                      onChanged: (String? newValue) {
                        selectedBloodGroup.value = newValue;
                      },
                      items: bloodGroups.map((String group) {
                        return DropdownMenuItem<String>(
                          value: group,
                          child: Text(
                            group,
                            style: AppTextStyles.style15white.copyWith(
                                color: Theme.of(context).colorScheme.tertiary),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    customTextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      textInputType: TextInputType.number,
                      customValidator: nameValidator,
                      controller: nameController,
                      inputTextColor:
                          Theme.of(context).colorScheme.onTertiaryContainer,
                      label: AppStrings.emergencyContact,
                      hintText: AppStrings.emergencyContact,
                    ),
                    const SizedBox(height: 20),
                    const Text(AppStrings.selectGender),
                    CustomButton(
                      onTap: () async {

                      },
                      isLoading: userStoreProvider().isVerifying,
                      borderRadius: 16,
                      text: AppStrings.proceed,
                      color: Theme.of(context).colorScheme.primary,
                      width: double.infinity,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderOption(String gender, ValueNotifier<String> selectedGender,
      BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        selectedGender.value = gender;
      },
      child: Row(
        children: [
          Icon(
            selectedGender.value == gender
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: Theme.of(context).colorScheme.primary,
          ),
          Text(
            gender,
            style: AppTextStyles.style12W600
                .copyWith(color: Theme.of(context).colorScheme.tertiary),
          ),
        ],
      ),
    );
  }
}
