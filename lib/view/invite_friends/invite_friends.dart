import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:ridzs_passenger_app/core/constants/constant.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/core/services/toast_service.dart';
import 'package:ridzs_passenger_app/services/contact_service.dart';
import 'package:share_plus/share_plus.dart';

class InviteFriends extends HookWidget {
  static const String routeNamed = 'InviteFriends';

  const InviteFriends({super.key});

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme;
    final searchController = useTextEditingController();
    final contacts = useState<List<Contact>>([]);
    final filterContacts = useState<List<Contact>>([]);

    useEffect(() {
      ContactService.getContacts().then((value) {
        contacts.value = value;
        filterContacts.value = value;
      }).catchError((error) {
        debugPrint('Error fetching contacts: $error');
        ToastService.show('Failed to load contacts');
      });
      return;
    }, []);

    return Scaffold(
      backgroundColor: themeColor.secondary,
      body: SafeArea(
        bottom: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //
            const TitleRowWidget(text: AppStrings.inviteFriends),

            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(
                  horizontal: SizeConfig.screenWidth * 0.04,
                ),
                padding: EdgeInsets.only(
                  top: SizeConfig.screenHeight * 0.02,
                  left: SizeConfig.screenWidth * 0.04,
                  right: SizeConfig.screenWidth * 0.04,
                ),
                decoration: BoxDecoration(
                  color: themeColor.secondary,
                  border: Border.all(
                    color: themeColor.outlineVariant.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                child: Column(
                  children: [
                    //
                    Text(
                      'Invites your friends and get discounts on your ride',
                      style: AppTextStyles.style15white.copyWith(
                        color: themeColor.surface,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    SizedBox(
                      height: SizeConfig.screenHeight * 0.02,
                    ),

                    customTextFormField(
                      hintText: 'Search by name or phone number',
                      controller: searchController,
                      onChanged: (val) {
                        if (val.isEmpty) {
                          filterContacts.value = contacts.value;
                        } else {
                          filterContacts.value =
                              contacts.value.where((contact) {
                            return contact.displayName
                                    .toLowerCase()
                                    .contains(val.toLowerCase()) ||
                                contact.phones.any((phone) => phone.number
                                    .contains(val.replaceAll(' ', '')));
                          }).toList();
                        }
                      },
                      prefix: const IconButton(
                        onPressed: null,
                        icon: Icon(CupertinoIcons.search),
                      ),
                    ),

                    SizedBox(
                      height: SizeConfig.screenHeight * 0.02,
                    ),

                    Expanded(
                      child: ListView.separated(
                        itemCount: filterContacts.value.length,
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        separatorBuilder: (_, index) {
                          return const SizedBox(
                            height: 20,
                          );
                        },
                        itemBuilder: (context, index) {
                          final contact = filterContacts.value[index];
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (contact.photo != null)
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: MemoryImage(contact.photo!),
                                )
                              else
                                Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: themeColor.primary
                                        .withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    color: themeColor.primary,
                                    size: 24,
                                  ),
                                ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    contact.displayName,
                                    style: AppTextStyles.style15white,
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    contact.phones.isNotEmpty
                                        ? contact.phones.first.number
                                        : 'No phone number',
                                    style: AppTextStyles.style12W600.copyWith(
                                      color: themeColor.onTertiaryContainer,
                                    ),
                                  ),
                                ],
                              ),

                              const Spacer(),

                              //
                              CustomButton(
                                onTap: () {
                                  SharePlus.instance.share(
                                    ShareParams(
                                      text:
                                          'Check out Ridzs\n${Constant.appUrl}',
                                    ),
                                  );
                                },
                                width: 80,
                                height: 40,
                                text: AppStrings.invite,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
