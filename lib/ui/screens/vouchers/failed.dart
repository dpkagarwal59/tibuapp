import 'package:flutter/material.dart';

import '../table/table_cart.dart';
class failed extends StatefulWidget {
  const failed({Key key}) : super(key: key);

  @override
  State<failed> createState() => _failedState();
}

class _failedState extends State<failed> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: InkWell(onTap: (){
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => TableCart(false)), (route) => false);

      },
          child: Icon(Icons.arrow_back_ios_new)),),
      body: Container(child:
      Center(child: Container(
        margin: EdgeInsets.only(top: 180),
        child: Column(children: [
          Image.asset('assets/images/failed.gif',
            fit: BoxFit.fill,
            alignment: Alignment.bottomCenter,
            width: 100,
            // height: 60,
          ),
          SizedBox(height: 10,),
          Text("Payment Failed",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),


        ],),
      )),),
    );
  }
}
