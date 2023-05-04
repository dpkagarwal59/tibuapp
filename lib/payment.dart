// import 'dart:convert';
//
// import 'package:TIBU/ui/screens/landing.dart';
// import 'package:TIBU/ui/utils/utils.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// // import 'package:stripe_payment/stripe_payment.dart';?
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
//
//
// String publickey;
// String secretkey;
//
// class StripeTransactionResponse {
//   String message;
//   bool success;
//   String pid;
//   StripeTransactionResponse({this.message, this.success, this.pid});
// }
//
// class StripeService {
//   static String apiBase = "https://api.stripe.com/v1";
//   static String paymentApiUrl = '${StripeService.apiBase}/payment_intents';
//   static Uri paymentApiUri = Uri.parse(paymentApiUrl);
//   static String secret = secretkey; //"sk_test_zFsjGhXTwCe7DTsoNRkllzjQ";
//   static String publishable_key =
//       publickey; //"pk_test_AtszjddNytDn1mmlT4ZjgXFy";
//
//   static init() async {
//     final SharedPreferences prefs = await SharedPreferences.getInstance();
//     secretkey = prefs.getString('secret_key');
//     publickey = prefs.getString('public_key');
//     print("keys------- ${publickey} ${secretkey}");
//
//     /*StripePayment.setOptions(StripeOptions(
//         publishableKey: '${StripeService.publishable_key}',
//         androidPayMode: 'test',
//         merchantId: 'test'));*/
//   }
//
//   static Future<Map<String, dynamic>> createPaymentIntent(
//       String amount, String currency) async {
//     try {
//       Map<String, dynamic> body = {
//         'amount': amount,
//         'currency': currency,
//       };
//
//       final SharedPreferences prefs = await SharedPreferences.getInstance();
//       secretkey = prefs.getString('secret_key');
//       Map<String, String>  headers = {
//         'Authorization': 'Bearer ${secretkey}',
//         'content-type': 'application/x-www-form-urlencoded'
//       };
//       print("payment Header: ${headers}");
//       var response =
//           await http.post(paymentApiUri, headers: headers, body: body);
//       print("response");
//       print(jsonDecode(response.body));
//       return jsonDecode(response.body);
//
//     } catch (error) {
//       print('error Happened');
//       throw error;
//     }
//   }
//
//   static Future<StripeTransactionResponse> payNowHandler(
//       {String amount, String currency}) async {
//
//     var paymentIntent =
//     await StripeService.createPaymentIntent(amount, currency);
//     print("payment: ${paymentIntent}");
//
//
//     try {
//
//       await Stripe.instance
//           .initPaymentSheet(
//
//           paymentSheetParameters: SetupPaymentSheetParameters(
//               paymentIntentClientSecret: paymentIntent[
//               'client_secret'], //Gotten from payment intent
//               style: ThemeMode.light,
//               merchantDisplayName: 'App'))
//           .then((value) {});
//
//       await Stripe.instance.presentPaymentSheet().onError((error, stackTrace){
//         return StripeService.getErrorAndAnalyze(error);
//       });
//       print("payment:success ${paymentIntent}");
//       return StripeTransactionResponse(
//           message: 'Transaction successfull',
//           success: true,
//           pid: paymentIntent["id"]);
//       /*await Stripe.instance.presentPaymentSheet().then((value) {
//
//         //Clear paymentIntent variable after successful payment
//         print("payment:success ${paymentIntent}");
//         return StripeTransactionResponse(
//             message: 'Transaction successfull',
//             success: true,
//             pid: paymentIntent["id"]);
//
//       }).onError((error, stackTrace) {
//         throw Exception(error);
//       });*/
//     }
//     on StripeException catch (e) {
//       print('Error is:---> $e');
//     }
//     catch (e) {
//       print("payment:error ${e}");
//       return StripeTransactionResponse(message: "Transcation Failed.", success: false);
//     }
//
//
//
//       /*try {
//       var paymentMethod = await StripePayment.paymentRequestWithCardForm(
//           CardFormPaymentRequest());
//       var p =
//       var paymentIntent =
//           await StripeService.createPaymentIntent(amount, currency);
//       var response = await StripePayment.confirmPaymentIntent(PaymentIntent(
//           clientSecret: paymentIntent['client_secret'],
//           paymentMethodId: paymentMethod.id));
//       print(response.paymentIntentId);
//       print(response.toJson());
//       if (response.status == 'succeeded') {
//         // Navigator.pushNamed(context, '/landing');
//         return StripeTransactionResponse(
//             message: 'Transaction successfull',
//             success: true,
//             pid: response.paymentIntentId);
//       } else {
//         return StripeTransactionResponse(
//             message: 'Transaction failed', success: false);
//       }
//     } catch (error) {
//       return StripeTransactionResponse(
//           message: 'Transaction failed in the catch block', success: false);
//     } on PlatformException catch (error) {
//       return StripeService.getErrorAndAnalyze(error);
//     }*/
//     // return StripeTransactionResponse(
//     //     message: 'Transaction failed', success: false);
//   }
//
//   static getErrorAndAnalyze(err) {
//     String message = 'Something went wrong';
//     if (err.code == 'cancelled') {
//       message = 'Transaction canceled';
//     }
//     return StripeTransactionResponse(message: message, success: false);
//   }
// }
// // import 'package:flutter/material.dart';
// // import 'package:photo_view/photo_view.dart';
// // import 'package:photo_view/photo_view_gallery.dart';
// //
// //
// //
// // class CustomLoader extends StatefulWidget {
// //   const CustomLoader({Key key}) : super(key: key);
// //
// //   @override
// //   State<CustomLoader> createState() => _CustomLoaderState();
// // }
// //
// // class _CustomLoaderState extends State<CustomLoader> with TickerProviderStateMixin {
// //
// //
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //         child:  PhotoView(
// //           imageProvider: AssetImage("assets/images/login.jpg"),
// //         )
// //     );
// //   }
// // }
///////////////////////////////////////////
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
//
// class My extends StatefulWidget {
//   My({Key key}) : super(key: key);
//
//   @override
//   MyState createState() {
//     return MyState();
//   }
// }
//
// class MyState extends State<My> {
//   final items = List<String>.generate(20, (i) => "Item ${i + 1} A B C D E... X Y Z");
//
//   String whatHappened;
//
//   @override
//   Widget build(BuildContext context) {
//     final title = 'Notification Items List';
//
//     return MaterialApp(
//       title: title,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text(title),
//         ),
//         body: ListView.builder(
//           itemCount: items.length,
//           itemBuilder: (context, index) {
//             final item = items[index];
//
//             return Dismissible(
//               key: Key(item),
//               onDismissed: (direction) {
//                 setState(() {
//                   items.removeAt(index);
//                 });
//
//                 // Scaffold.of(context)
//                 //     .showSnackBar(SnackBar(content: Text("$item was $whatHappened")));
//                 ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("$item was $whatHappened")));
//               },
//
//               confirmDismiss: (DismissDirection dismissDirection) async {
//                 switch(dismissDirection) {
//                   case DismissDirection.endToStart:
//                     whatHappened = 'ARCHIVED';
//                     return await _showConfirmationDialog(context, 'Archive') == true;
//                   case DismissDirection.startToEnd:
//                     whatHappened = 'DELETED';
//                     return await _showConfirmationDialog(context, 'Delete') == true;
//                   case DismissDirection.horizontal:
//                   case DismissDirection.vertical:
//                   case DismissDirection.up:
//                   case DismissDirection.down:
//                     assert(false);
//                 }
//                 return false;
//               },
//
//
//
//               background: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12.0),
//                 color: Colors.red,
//                 alignment: Alignment.centerLeft,
//                 child: Icon(Icons.cancel),
//               ),
//               secondaryBackground: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12.0),
//                 color: Colors.green,
//                 alignment: Alignment.centerRight,
//                 child: Icon(Icons.check),
//               ),
//
//
//
//               child: ListTile(title: Text('$item')),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
// Future<bool> _showConfirmationDialog(BuildContext context, String action) {
//   return showDialog<bool>(
//     context: context,
//     barrierDismissible: true,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('Do you want to $action this item?'),
//         actions: <Widget>[
//           ElevatedButton(
//             child: const Text('Yes'),
//             onPressed: () {
//               Navigator.pop(context, true); // showDialog() returns true
//             },
//           ),
//           ElevatedButton(
//             child: const Text('No'),
//             onPressed: () {
//               Navigator.pop(context, false); // showDialog() returns false
//             },
//           ),
//         ],
//       );
//     },
//   );
// }

import 'package:flutter/material.dart';



class My extends StatefulWidget {
  createState() => MyState();
}

List<String> listItems = [
  "One",
  "Two",
  "Three",
  "Four",
]; //dummy list of items

class MyState extends State<My> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text("Swipe List"),
          ),
          body: Container(
              child: ListView.builder(
                itemCount: listItems.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                      background: stackBehindDismiss(),
                      secondaryBackground: secondarystackBehindDismiss(),
                      key: ObjectKey(listItems[index]),
                      child: Container(
                        padding: EdgeInsets.all(20.0),
                        child: Text(listItems[index]),
                      ),
                      onDismissed: (direction) {
                        if (direction == DismissDirection.startToEnd) {
                          print("Add to favorite");
                          //add "add to favorite" function
                        } else {
                          print('Remove item');
                          deleteItem(index);
                        }
                      },
                      confirmDismiss: (DismissDirection direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Confirm"),
                              content: direction == DismissDirection.startToEnd
                                  ? Text(
                                  "Are you sure you wish add to favorite this item?")
                                  : Text(
                                  "Are you sure you wish to delete this item?"),
                              actions: <Widget>[
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: direction == DismissDirection.startToEnd
                                      ? Text("FAVORITE")
                                      : Text("DELETE"),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text("CANCEL"),
                                ),
                              ],
                            );
                          },
                        );
                      });
                },
              )),
        ));
  }

  void deleteItem(index) {
    setState(() {
      listItems.removeAt(index);
    });
  }

  void undoDeletion(index, item) {
    setState(() {
      listItems.insert(index, item);
    });
  }

  Widget secondarystackBehindDismiss() {
    return Container(
      color: Colors.red,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.delete, color: Colors.white),
            Text('Move to trash', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget stackBehindDismiss() {
    return Container(
      color: Colors.blue,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Icon(Icons.favorite, color: Colors.white),
            Text('Move to favorites', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}