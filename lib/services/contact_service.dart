import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:ridzs_passenger_app/core/exports/common_exports.dart';
import 'package:ridzs_passenger_app/core/services/toast_service.dart';

class ContactService {
  static Future<List<Contact>> getContacts() async {
    try {
      final hasPermission = await FlutterContacts.requestPermission();
      if (!hasPermission) {
        ToastService.show('Contacts permission denied');
        throw Exception('Contacts permission denied');
      }
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      return contacts;
    } catch (e) {
      debugPrint('Error fetching contacts: $e');
      return [];
    }
  }
}
