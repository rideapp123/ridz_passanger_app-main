// // // import 'package:flutter/material.dart';
// // // import 'package:flutter_stripe/flutter_stripe.dart';
// // // import 'package:http/http.dart' as http;
// // // import 'dart:convert';
// // //
// // // Future<void> main() async {
// // //   WidgetsFlutterBinding.ensureInitialized();
// // //
// // //   try {
// // //     Stripe.publishableKey = 'pk_test_51Pyen4P9sQVndu6ghKTndZ4gTTbBgA90QRxLfQhaJmLzCIUmVq0yLmeSIaTVRCzFg5evO7W6F3lqmF0WUTfl55L2003nz67X1P';
// // //     await Stripe.instance.applySettings();
// // //   } catch (e) {
// // //     print('Failed to initialize Stripe: $e');
// // //     // You might want to show an error dialog or screen here
// // //   }
// // //
// // //   runApp(MaterialApp(home: AddCardScreen()));
// // // }
// // //
// // // class AddCardScreen extends StatefulWidget {
// // //   @override
// // //   _AddCardScreenState createState() => _AddCardScreenState();
// // // }
// // //
// // // class _AddCardScreenState extends State<AddCardScreen> {
// // //   CardFieldInputDetails? _card;
// // //   bool _isLoading = false;
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(title: Text('Add Card')),
// // //       body: Padding(
// // //         padding: EdgeInsets.all(16),
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.stretch,
// // //           children: [
// // //             CardField(
// // //               onCardChanged: (card) {
// // //                 setState(() {
// // //                   _card = card;
// // //                 });
// // //               },
// // //             ),
// // //             SizedBox(height: 20),
// // //             ElevatedButton(
// // //               child: _isLoading
// // //                   ? CircularProgressIndicator(color: Colors.white)
// // //                   : Text('Add Card'),
// // //               onPressed: _card?.complete == true ? _handleAddCard : null,
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Future<void> _handleAddCard() async {
// // //     setState(() {
// // //       _isLoading = true;
// // //     });
// // //
// // //     try {
// // //       // Step 1: Get SetupIntent client secret from the server
// // //       final response = await http.post(
// // //         Uri.parse('http://0.0.0.0:8081/passanger/payment/create-setup-intent'),
// // //         headers: {
// // //           'Content-Type': 'application/json',
// // //           'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MTI1Y2E0ZjVlYWZkNGRhZjIyZGEyZSIsImlhdCI6MTcyOTI1NjYxMn0.GWmTFdzeDiy_oFvqR63Zi9QvyU1YMwk290-BdtH47Nk',
// // //         },
// // //       );
// // //
// // //       if (response.statusCode != 200) {
// // //         throw Exception('Failed to create setup intent');
// // //       }
// // //
// // //       final data = jsonDecode(response.body);
// // //       final clientSecret = data['clientSecret'];
// // //
// // //       // Step 2: Confirm the SetupIntent with the card details
// // //       final setupIntentResult = await Stripe.instance.confirmSetupIntent(
// // //         params: const PaymentMethodParams.card(
// // //           paymentMethodData: PaymentMethodData(),
// // //         ),
// // //         paymentIntentClientSecret: clientSecret,
// // //       );
// // //
// // //       // Step 3: Send the setupIntentId to your server to complete the process
// // //       final addCardResponse = await http.post(
// // //         Uri.parse('http://0.0.0.0:8081/passanger/payment/add-card'),
// // //         headers: {
// // //           'Content-Type': 'application/json',
// // //           'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3MTI1Y2E0ZjVlYWZkNGRhZjIyZGEyZSIsImlhdCI6MTcyOTI1NjYxMn0.GWmTFdzeDiy_oFvqR63Zi9QvyU1YMwk290-BdtH47Nk',
// // //         },
// // //         body: jsonEncode({
// // //           'setupIntentId': setupIntentResult.id,
// // //         }),
// // //       );
// // //
// // //       if (addCardResponse.statusCode == 200) {
// // //         final addCardData = jsonDecode(addCardResponse.body);
// // //         if (addCardData['success']) {
// // //           ScaffoldMessenger.of(context).showSnackBar(
// // //             SnackBar(content: Text('Card added successfully')),
// // //           );
// // //           Navigator.pop(context);
// // //         } else {
// // //           throw Exception(addCardData['message']);
// // //         }
// // //       } else {
// // //         throw Exception('Failed to add card');
// // //       }
// // //     } catch (e) {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         SnackBar(content: Text('Error: ${e.toString()}')),
// // //       );
// // //     } finally {
// // //       setState(() {
// // //         _isLoading = false;
// // //       });
// // //     }
// // //   }
// // // }
// //
// //
// import 'package:flutter/material.dart';
// import 'package:flutter_mobx/flutter_mobx.dart';
// import 'package:provider/provider.dart';
// import '../stores/map_store.dart';
//
//
//
// void main(){
//   runApp(
//     MaterialApp(
//       home: Provider(
//         create: (context) => NearbyDriversStore(),
//         builder: (context, child) {
//          return PassengerHomeScreen();
//         },
//
//       ),
//     ),
//   );
// }
//
// class PassengerHomeScreen extends StatefulWidget {
//   @override
//   _PassengerHomeScreenState createState() => _PassengerHomeScreenState();
// }
//
// class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
//   late NearbyDriversStore _driversStore;
//
//   @override
//   void initState() {
//     super.initState();
//     _driversStore = context.read<NearbyDriversStore>();
//     _initializeSocket();
//   }
//
//   Future<void> _initializeSocket() async {
//     await _driversStore.initialize('your-jwt-token');
//     _startSearching();
//   }
//
//   void _startSearching() {
//     // Replace with actual location
//     _driversStore.findNearbyDrivers(
//       latitude: 37.7749,
//       longitude: -122.4194,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Observer(
//       builder: (_) => Scaffold(
//         appBar: AppBar(
//           title: Text('Find Drivers'),
//           actions: [
//             if (_driversStore.isConnected)
//               Icon(Icons.cloud_done)
//             else
//               Icon(Icons.cloud_off)
//           ],
//         ),
//         body: Column(
//           children: [
//             if (_driversStore.error != null)
//               MaterialBanner(
//                 content: Text(_driversStore.error!),
//                 actions: [
//                   TextButton(
//                     onPressed: _driversStore.clearError,
//                     child: Text('Dismiss'),
//                   ),
//                 ],
//               ),
//             Expanded(
//               child: Observer(
//                 builder: (_) => _driversStore.nearbyDrivers.isEmpty
//                     ? const Center(
//                   child: Text('No drivers nearby'),
//                 )
//                     : ListView.builder(
//                   itemCount: _driversStore.nearbyDrivers.length,
//                   itemBuilder: (context, index) {
//                     final driver = _driversStore.nearbyDrivers[index];
//                     return ListTile(
//                       title: Text('Driver ${driver.driverId}'),
//                       subtitle: Text(
//                           'Distance: ${driver.distance?.toStringAsFixed(2) ?? "N/A"} km'
//                       ),
//                       trailing: Icon(
//                         driver.isAvailable
//                             ? Icons.circle_rounded
//                             : Icons.circle_outlined,
//                         color: driver.isAvailable
//                             ? Colors.green
//                             : Colors.grey,
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ),
//           ],
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: _startSearching,
//           child: Icon(Icons.refresh),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _driversStore.dispose();
//     super.dispose();
//   }
// }
//
// // import 'dart:async';
// //
// // import 'package:flutter/material.dart';
// // import 'package:pin_code_fields/pin_code_fields.dart';
// // import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
// // import 'package:permission_handler/permission_handler.dart';
// // import 'package:pinput/pinput.dart' as pi;
// //
// // class OTPVerificationScreen extends StatefulWidget {
// //   @override
// //   _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
// // }
// //
// // class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
// //   TextEditingController textEditingController = TextEditingController();
// //   String currentText = "";
// //   final formKey = GlobalKey<FormState>();
// //   bool hasPermission = false;
// //   Timer? _timer;
// //   String? lastMessageId;
// //   @override
// //   void initState() {
// //     super.initState();
// //     _checkPermission();
// //   }
// //
// //   Future<void> _checkPermission() async {
// //     final status = await Permission.sms.status;
// //     setState(() {
// //       hasPermission = status.isGranted;
// //     });
// //
// //     if (!status.isGranted) {
// //       final result = await Permission.sms.request();
// //       setState(() {
// //         hasPermission = result.isGranted;
// //       });
// //       if (result.isGranted) {
// //         // Only try to read SMS if permission was just granted
// //         startListening();
// //       }
// //     }
// //   }
// //
// //   void startListening() {
// //     // Check for new messages every 2 seconds
// //     _timer = Timer.periodic(Duration(seconds: 2), (timer) {
// //       readLatestSMS();
// //       print('Timer running');
// //     });
// //   }
// //
// //   Future<void> readLatestSMS() async {
// //     if (!hasPermission) return;
// //
// //     try {
// //       final SmsQuery query = SmsQuery();
// //       final messages = await query.querySms(
// //         kinds: [SmsQueryKind.inbox],
// //         count: 1,
// //       );
// //
// //       if (messages.isNotEmpty) {
// //         final message = messages.first;
// //
// //         // Check if this is a new message
// //         if (lastMessageId != message.id.toString()) {
// //           lastMessageId = message.id.toString();
// //
// //           final String messageBody = message.body ?? '';
// //           print('New message received: $messageBody'); // For debugging
// //
// //           // You can adjust this regex pattern based on your OTP message format
// //           final RegExp regExp = RegExp(r'Your OTP is: (\d{4})');
// //           final match = regExp.firstMatch(messageBody);
// //
// //           if (match != null) {
// //             final String otp = match.group(1)!;
// //             setState(() {
// //               textEditingController.setText(otp);
// //             });
// //           }
// //         }
// //       }
// //     } catch (e) {
// //       print('Error reading SMS: $e');
// //       // Only show error once, not every 2 seconds
// //       if (_timer?.isActive ?? false) {
// //         _timer?.cancel();
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text('Failed to read SMS: ${e.toString()}'),
// //             action: SnackBarAction(
// //               label: 'Retry',
// //               onPressed: () {
// //                 startListening();
// //               },
// //             ),
// //           ),
// //         );
// //       }
// //     }
// //   }
// //
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('OTP Verification'),
// //       ),
// //       body: Padding(
// //         padding: const EdgeInsets.symmetric(horizontal: 20),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Form(
// //               key: formKey,
// //               child: PinCodeTextField(
// //                 appContext: context,
// //                 length: 4,
// //                 obscureText: false,
// //                 animationType: AnimationType.fade,
// //                 pinTheme: PinTheme(
// //                   shape: PinCodeFieldShape.box,
// //                   borderRadius: BorderRadius.circular(5),
// //                   fieldHeight: 50,
// //                   fieldWidth: 40,
// //                   activeFillColor: Colors.white,
// //                   activeColor: Colors.blue,
// //                   selectedColor: Colors.blue,
// //                   selectedFillColor: Colors.white,
// //                   inactiveFillColor: Colors.white,
// //                   inactiveColor: Colors.grey,
// //                 ),
// //                 animationDuration: Duration(milliseconds: 300),
// //                 enableActiveFill: true,
// //                 controller: textEditingController,
// //                 keyboardType: TextInputType.number,
// //                 onCompleted: (value) {
// //                   print("Completed: $value");
// //                   // Add your verification logic here
// //                 },
// //                 onChanged: (value) {
// //                   setState(() {
// //                     currentText = value;
// //                   });
// //                 },
// //                 beforeTextPaste: (text) {
// //                   return true;
// //                 },
// //               ),
// //             ),
// //             SizedBox(height: 20),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //               children: [
// //                 ElevatedButton(
// //                   onPressed: hasPermission
// //                       ? () {
// //                     if (_timer?.isActive ?? false) {
// //                       _timer?.cancel();
// //                       setState(() {});
// //                     } else {
// //                       startListening();
// //                       setState(() {});
// //                     }
// //                   }
// //                       : _checkPermission,
// //                   child: Text(
// //                       hasPermission
// //                           ? (_timer?.isActive ?? false)
// //                           ? 'Stop Listening'
// //                           : 'Start Listening'
// //                           : 'Grant Permission'
// //                   ),
// //                 ),
// //                 ElevatedButton(
// //                   onPressed: () {
// //                     if (currentText.length == 4) {
// //                       print("Verifying OTP: $currentText");
// //                     }
// //                   },
// //                   child: Text('Verify OTP'),
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   @override
// //   void dispose() {
// //     _timer?.cancel();
// //     textEditingController.dispose();
// //     super.dispose();
// //   }
// // }
// //
// // void main() {
// //   runApp(MaterialApp(
// //     home: OTPVerificationScreen(),
// //   ));
// // }