import 'package:TIBU/ui/screens/bookings/bookings.dart';
import 'package:flutter/material.dart';

import '../table/table_cart.dart';
class Success extends StatefulWidget {
  const Success({Key key}) : super(key: key);

  @override
  State<Success> createState() => _SuccessState();
}

class _SuccessState extends State<Success> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: InkWell(onTap: (){
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => TableCart(false)), (route) => false);

      },
          child: Icon(Icons.arrow_back_ios_new)),
        actions: [Container(
            margin: EdgeInsets.only(right: 15),
            child: InkWell(
                onTap: (){
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => BookingScreen()), (route) => false);

                },
                child: Icon(Icons.history)))],

      ),
      body: Container(child:
      Center(child: Container(
        margin: EdgeInsets.only(top: 230),
        child: Column(children: [
          Image.asset('assets/images/success.gif',
            fit: BoxFit.fill,
            alignment: Alignment.bottomCenter,
            width: 100,
            // height: 60,
          ),
          SizedBox(height: 10,),
          Text("Payment Success",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),


        ],),
      )),),
    );
  }
}
