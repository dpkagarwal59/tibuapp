import 'dart:convert';

import 'package:TIBU/constants/navigator.dart';
import 'package:TIBU/constants/strings.dart';
import 'package:TIBU/logic/models/stripe_model.dart';
import 'package:TIBU/observer/user_profile_observable.dart';
import 'package:TIBU/repository/club_app_repository.dart';
import 'package:TIBU/ui/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_stripe/flutter_stripe.dart';


class StripeBloc {
  final ClubAppRepository _repository = ClubAppRepository();
  BehaviorSubject<bool> loaderController = BehaviorSubject<bool>();
  String publicKey;
  String secretKey;
  void dispose() {
    loaderController.close();
  }

  Future<void> stripeKeys(BuildContext context) async {
    loaderController.add(true);
    _repository.getStripeKeys().then((Response response) async {
      loaderController.add(false);
      debugPrint('get stripe keys response is ------->  ${response.body}');
      StripeResponseModel stripeResponseModel =
          StripeResponseModel.fromJson(json.decode(response.body));
      if (response.statusCode == 200) {
        var jsonMap = json.decode(response.body);
        stripeResponseModel = StripeResponseModel.fromJson(jsonMap);
        publicKey = stripeResponseModel.data.publishableKey;
        secretKey = stripeResponseModel.data.apiKey;
       // String status = stripeResponseModel.data.status;
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        print("keys------- ${publicKey} ${secretKey}");
        prefs.setString('public_key', publicKey);
        prefs.setString('secret_key', secretKey);
        Stripe.publishableKey = publicKey;
      } else {
       // ackAlert(context, stripeResponseModel.error);
      }
    }).catchError((Object error) {
      loaderController.add(false);
      debugPrint(
          'get stripe response exception is -------->  ${error.toString()}');
     // ackAlert(context, error.toString());
    });
  }
}
