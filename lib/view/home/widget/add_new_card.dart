import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';

class AddNewCard extends HookWidget {
  static const routeNamed = 'AddNewCard';
  const AddNewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = useTextEditingController();
    final complete = useState(false);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final userStore = userStoreProvider();
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colors.secondary,
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const TitleRowWidget(text: 'Add New Card'),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          Assets.cardBG,
                          height: 100,
                          fit: BoxFit.cover,
                          excludeFromSemantics: true,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: nameController,
                        textCapitalization: TextCapitalization.words,
                        autofillHints: const [AutofillHints.creditCardName],
                        decoration: const InputDecoration(
                          labelText: 'Cardholder name',
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Enter the cardholder name'
                                : null,
                      ),
                      const SizedBox(height: 20),
                      Observer(
                        builder: (_) => CardFormField(
                          countryCode: 'CA',
                          disabled: userStore.isAddingCard,
                          onCardChanged: (details) {
                            complete.value = details?.complete ?? false;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Observer(
                  builder: (_) => SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: !complete.value || userStore.isAddingCard
                          ? null
                          : () {
                              if (formKey.currentState!.validate()) {
                                userStore.addCard(
                                  cardHolderName: nameController.text.trim(),
                                );
                              }
                            },
                      child: userStore.isAddingCard
                          ? const SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Add Card'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
