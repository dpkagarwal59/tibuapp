import 'dart:core';

import 'package:TIBU/constants/strings.dart';
import 'package:TIBU/logic/bloc/add_on_bloc.dart';
import 'package:TIBU/logic/bloc/create_payment_bloc.dart';
import 'package:TIBU/logic/bloc/sign_up_bloc.dart';
import 'package:TIBU/paypal1/Services.dart';
import 'package:TIBU/ui/screens/vouchers/failed.dart';
import 'package:TIBU/ui/screens/vouchers/success.dart';
import 'package:TIBU/ui/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class PaypalPayment extends StatefulWidget {

  String amount;
  String dropdownValue;
  String name;
  String email;
  String orderId;
  String guestId;
  String userId;

  PaypalPayment({this.amount,this.dropdownValue,this.name,this.email,this.orderId,this.guestId,this.userId});
  @override
  State<StatefulWidget> createState() {
    return PaypalPaymentState();
  }
}
class PaypalPaymentState extends State<PaypalPayment> {

  Future<Response> completePayment(
      String currency,
      String amount,
      String balanceTransaction,
      String orderId,
      String status,
      ) async {
    Map<String, dynamic> body = <String, dynamic>{
      'currency': currency,
      'amount': amount,
      'balance_transaction': balanceTransaction,
      'order_id': orderId,
      'status': status,
    };
    debugPrint(
        'Calling Complete payment profile api ---->  ${ClubApp().complete_payment} with body $body');

    final Response response =
    await http.post(Uri.parse(ClubApp().complete_payment), body: body);
    print(response);
    return response;
  }

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String checkoutUrl;
  String executeUrl;
  String accessToken;
  PaypalServices services = PaypalServices();

  // you can change default currency according to your need
  Map<dynamic,dynamic> defaultCurrency = {"symbol": "USD ", "decimalDigits": 2, "symbolBeforeTheNumber": true, "currency": "USD"};

  bool isEnableShipping = false;
  bool isEnableAddress = false;

  String returnURL = 'return.example.com';
  String cancelURL= 'cancel.example.com';


  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      try {
        accessToken = await services.getAccessToken();

        final transactions = getOrderParams();
        final res =
        await services.createPaypalPayment(transactions, accessToken);
        if (res != null) {
          setState(() {
            checkoutUrl = res["approvalUrl"];
            executeUrl = res["executeUrl"];
          });
        }
      } catch (e) {
        print('exception: '+e.toString());
        final snackBar = SnackBar(
          content: Text(e.toString()),
          duration: Duration(seconds: 10),
          action: SnackBarAction(
            label: 'Close',
            onPressed: () {
              // Some code to undo the change.
            },
          ),
        );
        //_scaffoldKey.currentState.showSnackBar(snackBar);
      }
    });
  }



  // item name, price and quantity

  String itemName = 'Tables ';
  String itemPrice = '300';
  int quantity = 1;

  Map<String, dynamic> getOrderParams() {



    List items = [
      {
        "name": itemName,
        "quantity": quantity,
        "price": '${widget.amount}',
        "currency":
        defaultCurrency["currency"]
      }
    ];
    // checkout invoice details
    String totalAmount = '${widget.amount}';
    String subTotalAmount = '${widget.amount}';
    String shippingCost = '0';
    int shippingDiscountCost = 0;
    String userFirstName = '${widget.name}';
    String userLastName = 'Yadav';
    String addressCity = 'Delhi';
    String addressStreet = 'Mathura Road';
    String addressZipCode = '110014';
    String addressCountry = 'India';
    String addressState = 'Delhi';
    String addressPhoneNumber = '+919990119091';

    Map<String, dynamic> temp = {
      "intent": "sale",
      "payer": {"payment_method": "paypal"},
      "transactions": [
        {

          "amount": {
            "total": '${widget.amount}',
            "currency":  defaultCurrency["currency"],
            "details": {
              "subtotal": '${widget.amount}',
              "shipping": shippingCost,
              "shipping_discount":
              ((-1.0) * shippingDiscountCost).toString()
            }
          },
          "description": "The payment transaction description.",
          "payment_options": {
            "allowed_payment_method": "INSTANT_FUNDING_SOURCE"
          },
          "item_list": {
            "items": items,
            if (isEnableShipping &&
                isEnableAddress)
              "shipping_address": {
                "recipient_name": userFirstName +
                    " " +
                    userLastName,
                "line1": addressStreet,
                "line2": "",
                "city": addressCity,
                "country_code": addressCountry,
                "postal_code": addressZipCode,
                "phone": addressPhoneNumber,
                "state": addressState
              },
          }
        }
      ],
      "note_to_payer": "Contact us for any questions on your order.",
      "redirect_urls": {
        "return_url": returnURL,
        "cancel_url": cancelURL
      }
    };
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    print(checkoutUrl);

    if (checkoutUrl != null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF0C0F1C),

          //backgroundColor: Theme.of(context).backgroundColor,
          leading: GestureDetector(
            child: Icon(Icons.arrow_back_ios),
            onTap: () => Navigator.pop(context),
          ),
        ),
        body: WebView(
          initialUrl: checkoutUrl,
          javascriptMode: JavascriptMode.unrestricted,
          navigationDelegate: (NavigationRequest request) async {
            if (request.url.contains(returnURL)) {
              final uri = Uri.parse(request.url);
              final payerID = uri.queryParameters['PayerID'];
              if (payerID != null) {
                services
                    .executePayment(executeUrl, payerID, accessToken)
                    .then((id) {
                  widget.amount;
                  Navigator.of(context).pop();

                });
              } else {
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => failed()), (route) => false);
                print("payment not succses");
              }
              print("payment succses3");
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => Success()), (route) => false);
              completePayment(
                "EUR",
                widget.amount,
                "pid",
                widget.orderId,
                "succeeded",
              );
            }
            if (request.url.contains(cancelURL)) {
              Navigator.of(context).pop();
              print("payment not cancelURL");
             // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => failed()), (route) => false);
            }
            return NavigationDecision.navigate;
          },
        ),
      );
    } else {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              }),
         // backgroundColor: Colors.black12,

          backgroundColor: Color(0xFF0C0F1C),
          elevation: 0.0,
        ),
        body: Center(child: Container(child: CircularProgressIndicator())),
      );
    }
  }
}