import 'dart:async';
import 'package:TIBU/constants/constants.dart';
import 'package:TIBU/constants/strings.dart';
import 'package:TIBU/logic/bloc/add_on_bloc.dart';
import 'package:TIBU/logic/bloc/stripe_keys_bloc.dart';
import 'package:TIBU/logic/models/add_on_model.dart';
import 'package:TIBU/observer/add_on_observable.dart';
import 'package:TIBU/paypal1/Payment.dart';
import 'package:TIBU/ui/screens/checkout.dart';
import 'package:TIBU/ui/screens/landing.dart';
import 'package:TIBU/ui/screens/table/add_on.dart';
import 'package:TIBU/ui/utils/utility.dart';
import 'package:TIBU/ui/utils/utils.dart';
import 'package:TIBU/ui/widgets/outline_border_button.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:expandable/expandable.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_paypal/flutter_paypal.dart';


class TableCart extends StatefulWidget {
  bool tabbar;
  TableCart(this.tabbar);
  // const TableCart(this.cartTable, this.eventTable);

  // final List<TableCartModel> cartTable;
  // final List<EventCartModel> eventTable;

  @override
  _TableCartState createState() => _TableCartState();
}

class _TableCartState extends State<TableCart> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // TableCartBloc _tableCartBloc;
  AddOnsBloc _addOnsBloc;

  StripeBloc _stripeBloc;
//  List<TableModel> tableCarts = <TableModel>[];
  double totalAmount = 0.0;

  String currency = ClubApp.currencyLbl;
  static String id = 'exploreScreen';
  // double total = 0.0;
  bool isLoading = false;

  // List<TableCartModel> cartTable;
  // List<EventCartModel> eventTable;

  @override
  Future<void> initState() {
    super.initState();
    _addOnsBloc = AddOnsBloc();
    _stripeBloc = StripeBloc();
    fetchTableCartList();
    getKeys();
    setState(() {});
  }

  Future<void> fetchTableCartList() async {
    print("inside fetch table");
    final bool isInternetAvailable = await isNetworkAvailable();
    if (isInternetAvailable) {
      await _addOnsBloc.fetchTableCartList();
      // setState(() {
      //   cartTable = _addOnsBloc.tableCart;
      //   eventTable = _addOnsBloc.eventCart;
      // });
    } else {
      ackAlert(context, ClubApp.no_internet_message);
    }
  }

  void callThisMethod(bool isVisible) {
    debugPrint('ExploreScreen.callThisMethod: isVisible: ${isVisible}');
    if (isVisible) {
      _addOnsBloc = AddOnsBloc();
      _stripeBloc = StripeBloc();
      fetchTableCartList();
      getKeys();
      setState(() {});
    }
  }

  Future<void> getKeys() async {
    final bool isInternetAvailable = await isNetworkAvailable();
    if (isInternetAvailable) {
      _stripeBloc.stripeKeys(context);
    } else {
      ackAlert(context, ClubApp.no_internet_message);
    }
  }

  Future<void> fetchAddOns() async {
    final bool isInternetAvailable = await isNetworkAvailable();
    if (isInternetAvailable) {
      await _addOnsBloc.fetchTableCartList();
      _addOnsBloc.fetchAddOns();
    } else {
      ackAlert(context, ClubApp.no_internet_message);
    }
  }

  @override
  void dispose() {
    // _tableCartBloc.dispose();
    _addOnsBloc.dispose();
    _stripeBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
        key: Key(id),
        onVisibilityChanged: (VisibilityInfo info) {
          bool isVisible = info.visibleFraction != 0;
          callThisMethod(isVisible);
        },
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: appBackgroundColor,
          appBar: widget.tabbar == false
              ? AppBar(
                  title: Text('Cart'),
                  leading: IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) => AddOns(

                          ),
                        ),
                      );
                      //Navigator.of(context).pop();
                    },
                    icon: Icon(Icons.arrow_back),
                  ),
                )
              : AppBar(
                  toolbarHeight: 0,
                ),
          body: SafeArea(
            child: StreamBuilder<bool>(
              stream: _addOnsBloc.loaderController
                  .stream, //_tableCartBloc.isLoadingController.stream,
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                bool isLoading = false;
                if (snapshot.hasData) {
                  isLoading = snapshot.data;
                }

                return ModalProgressHUD(
                    inAsyncCall: isLoading,
                    color: Colors.black,
                    progressIndicator: const CircularProgressIndicator(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 4,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            child: SingleChildScrollView(
                              child: isLoading
                                  ? const SizedBox()
                                  : _addOnsBloc.tableCart.isEmpty &&
                                          _addOnsBloc.eventCart.isEmpty
                                      ? Center(
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                20, 100, 10, 10),
                                            child: Text(
                                              "No Table or Event Added !",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 16),
                                              child: Row(
                                                children: [
                                                  _addOnsBloc.tableCart ==
                                                              null ||
                                                          _addOnsBloc.tableCart
                                                              .isEmpty ||
                                                          _addOnsBloc
                                                              .isTableListNull
                                                      ? Container()
                                                      : Text(
                                                          'Tables',
                                                          maxLines: 1,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .headline6
                                                                  .apply(
                                                                    color:
                                                                        textColorDarkPrimary,
                                                                  ),
                                                        ),
                                                  // Expanded(child: Container()),
                                                  // widget.tabbar == true
                                                  //     ? IconButton(
                                                  //         onPressed: () {
                                                  //           fetchTableCartList();
                                                  //           getKeys();
                                                  //         },
                                                  //         icon: Icon(
                                                  //             Icons.refresh,
                                                  //             color:
                                                  //                 Colors.white),
                                                  //       )
                                                  //     : Container(),
                                                ],
                                              ),
                                            ),
                                            _addOnsBloc.tableCart == null ||
                                                    _addOnsBloc
                                                        .tableCart.isEmpty ||
                                                    _addOnsBloc.isTableListNull
                                                ? Container()
                                                : generateTableChartsList(
                                                    context),
                                            _addOnsBloc.eventCart == null ||
                                                    _addOnsBloc
                                                        .eventCart.isEmpty ||
                                                    _addOnsBloc.isEventListNull
                                                ? Container()
                                                : Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        vertical: 8,
                                                        horizontal: 16),
                                                    child: Text(
                                                      'Events',
                                                      maxLines: 1,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headline6
                                                          .apply(
                                                            color:
                                                                textColorDarkPrimary,
                                                          ),
                                                    ),
                                                  ),
                                            _addOnsBloc.eventCart == null ||
                                                    _addOnsBloc
                                                        .eventCart.isEmpty ||
                                                    _addOnsBloc.isEventListNull
                                                ? Container()
                                                //  Padding(
                                                //     padding: const EdgeInsets.fromLTRB(
                                                //         20, 10, 10, 10),
                                                //     child: Text(
                                                //       "No Event Added !",
                                                //       style: TextStyle(
                                                //           color: Colors.white),
                                                //     ),
                                                //   )
                                                : generateEventChartsList(
                                                    context)
                                          ],
                                        ),
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 1.0,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 8),
                          color: detailsDividerColor,
                        ),
                        getBottomView(context),
                        const SizedBox(
                          height: 4,
                        ),
                      ],
                    ));
              },
            ),
          ),
        ));
  }

/////// TABLE CART
  Widget generateTableChartsList(BuildContext context) {
    return RefreshIndicator(
      onRefresh: (){
    Timer(
    Duration(seconds: 1),
    () {
    fetchTableCartList();
    getKeys();
    }
    );
    },
      child: ListView.builder(
        shrinkWrap: true,
        //padding: const EdgeInsets.only(top: 8.0),
        physics: NeverScrollableScrollPhysics(),
        itemCount: _addOnsBloc.tableCart.length,
        itemBuilder: generateExpandableCart,
      ),
    );

  }

  Widget generateExpandableCart(BuildContext context, int index) {
    // final item = items[index];

    return ExpandableNotifier(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Dismissible(
          background: Container(
            padding: EdgeInsets.only(right: 20.0),
            alignment: Alignment.centerRight,
            color: Colors.pink,
            child: Text(
              'Delete',
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          direction: DismissDirection.endToStart,
          resizeDuration: const Duration(milliseconds: 200),
          key: UniqueKey(),
          onDismissed: (direction) {
            setState(() {
              debugPrint(
                  "-----table id----  ${_addOnsBloc.tableCart[index].id}");
              _addOnsBloc.deleteTable(
                  _addOnsBloc.tableCart[index].id, widget.tabbar, context);

              // Timer(Duration(seconds: 5), () {
              //   print("------------table deleted---------");
              //   fetchTableCartList();
              //   getKeys();
              // });
            });
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('dismissed')));
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            color: cardBackgroundColor,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    theme: const ExpandableThemeData(
                      headerAlignment: ExpandablePanelHeaderAlignment.center,
                      iconSize: 28,
                      iconColor: Colors.white,
                      tapBodyToCollapse: true,
                    ),
                    header: generateChartsCard(context, index),
                    collapsed: (_addOnsBloc.tableCart[index].addons == null || _addOnsBloc.tableCart[index].addons.length == 0)
                        ? Container()
                        : Container(
                            height:
                                _addOnsBloc.tableCart[index].addons.length == 1
                                    ? MediaQuery.of(context).size.height * 0.15
                                    : MediaQuery.of(context).size.height * 0.20,
                            child: ListView.builder(
                                itemCount:
                                    _addOnsBloc.tableCart[index].addons.length,
                                itemBuilder: (context, i) {
                                  return Dismissible(
                                    background: Container(
                                      padding: EdgeInsets.only(right: 20.0),
                                      alignment: Alignment.centerRight,
                                      color: Colors.green,
                                      child: Text(
                                        'Delete',
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                    ),
                                    key: UniqueKey(),
                                    direction: DismissDirection.endToStart,
                                    onDismissed: (direction) async {
                                      print(
                                          "addon cart id ------ > ${_addOnsBloc.tableCart[index].addons[i].addonCartId}");
                                      await _addOnsBloc.deleteAddon(
                                        _addOnsBloc.tableCart[index].addons[i]
                                            .addonCartId,
                                        context,
                                      );
                                      fetchAddOns();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text("dismissed"),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      color: Colors
                                          .grey.shade700, //cardBackgroundColor,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 0),
                                      elevation: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 8),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 100,
                                              width: 100,
                                              child: _addOnsBloc
                                                          .tableCart[index]
                                                          .addons[i]
                                                          .thumbnail ==
                                                      null
                                                  ? Image.asset(
                                                      'assets/images/placeholder.png',
                                                      fit: BoxFit.fill,
                                                      alignment:
                                                          Alignment.center,
                                                    )
                                                  : FadeInImage.assetNetwork(
                                                      placeholder:
                                                          'assets/images/placeholder.png',
                                                      image: _addOnsBloc
                                                          .tableCart[index]
                                                          .addons[i]
                                                          .thumbnail,
                                                      fadeInDuration:
                                                          const Duration(
                                                              milliseconds:
                                                                  500),
                                                      fit: BoxFit.fill,
                                                      alignment:
                                                          Alignment.center,
                                                    ),
                                            ),
                                            const SizedBox(
                                              width: 12,
                                            ),
                                            Expanded(
                                              flex: 7,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Text(
                                                  //   'Quantity: ${_addOnsBloc.tableCart[index].addons[i].quantity}',
                                                  //   maxLines: 2,
                                                  //   style: Theme.of(context)
                                                  //       .textTheme
                                                  //       .bodyText2
                                                  //       .apply(
                                                  //           color:
                                                  //               textColorDarkPrimary),
                                                  // ),
                                                  // const SizedBox(
                                                  //   height: 2,
                                                  // ),

                                                  Text(
                                                    '${_addOnsBloc.tableCart[index].addons[i].name}', // ${tableModel.currency}',
                                                    maxLines: 2,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2
                                                        .apply(
                                                        color:
                                                        textColorDarkPrimary),
                                                  ),
                                                  const SizedBox(
                                                    height: 2,
                                                  ),

                                                  Text(
                                                    'Price: ${ClubApp.currencyLbl} ${_addOnsBloc.tableCart[index].addons[i].rate}', // ${tableModel.currency}',
                                                    maxLines: 2,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2
                                                        .apply(
                                                        color:
                                                        textColorDarkPrimary),
                                                  ),
                                                  const SizedBox(
                                                    height: 2,
                                                  ),

                                                  Text(
                                                    'Quantity:  ${_addOnsBloc.tableCart[index].addons[i].quantity}', // ${tableModel.currency}',
                                                    maxLines: 2,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2
                                                        .apply(
                                                        color:
                                                        textColorDarkPrimary),
                                                  ),
                                                  const SizedBox(
                                                    height: 2,
                                                  ),

                                                  Text(
                                                    'Total: ${ClubApp.currencyLbl} ${_addOnsBloc.tableCart[index].addons[i].quantity * _addOnsBloc.tableCart[index].addons[i].rate}', // ${tableModel.currency}',
                                                    maxLines: 2,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2
                                                        .apply(
                                                        color:
                                                        textColorDarkPrimary),
                                                  ),


                                                  /*Container(
                                          alignment: Alignment.bottomRight,
                                          child: OutlinedButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              totalAmount -= tableModel.price;
                                                              tableCarts.removeAt(index);
                                                            });
                                                          },
                                                          borderSide: BorderSide(color: borderColor),
                                                          child: Text(
                                                            ClubApp.btn_remove_table,
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .subtitle2
                                                                .apply(color: Colors.white),
                                                          ),
                                          )),*/
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                    expanded:
                        // (_addOnsBloc.tableCart[index].addOns != null &&
                        //     _addOnsBloc.tableCart[index].addOns.isNotEmpty)
                        //     ?
                        Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 4),
                      color: backgroundColor,
                      // child: generateAddOnCartList(
                      //   _addOnsBloc.tableCart[0].addOns, context, _addOnsBloc.tableCart[0].tableId),
                    )
                    // : const SizedBox(),
                    ,
                    builder: (_, Widget collapsed, Widget expanded) {
                      return Expandable(
                        collapsed: collapsed,
                        expanded: expanded,
                        theme: const ExpandableThemeData(crossFadePoint: 0),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget generateChartsCard(BuildContext context, int index) {
    // TableModel tableModel = _addOnsBloc.tableCart[0];
    return Card(
      color: cardBackgroundColor,
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              width: 100,
              child:
                  // Text("name")
                  _addOnsBloc.tableCart[index].thumbnail == null
                      ? Image.asset(
                          'assets/images/placeholder.png',
                          fit: BoxFit.fill,
                          alignment: Alignment.center,
                        )
                      : FadeInImage.assetNetwork(
                          placeholder: 'assets/images/placeholder.png',
                          image: _addOnsBloc.tableCart[index].thumbnail,
                          fadeInDuration: const Duration(milliseconds: 500),
                          fit: BoxFit.fill,
                          alignment: Alignment.center,
                        ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              flex: 7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${_addOnsBloc.tableCart[index].categoryName} - ${_addOnsBloc.tableCart[index].tableName}",
                    maxLines: 1,
                    style: Theme.of(context).textTheme.subtitle1.apply(
                          color: textColorDarkPrimary,
                        ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    // "dummy data",
                    'Max: ${_addOnsBloc.tableCart[index].capacity} GUESTS',
                    maxLines: 2,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .apply(color: textColorDarkPrimary),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    // "52898",
                    'Price: ${ClubApp.currencyLbl} ${_addOnsBloc.tableCart[index].rate}', // ${tableModel.currency}',
                    maxLines: 2,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .apply(color: textColorDarkPrimary),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    // "10/50/22",
                    'Date: ' + _addOnsBloc.tableCart[index].date.toString(),
                    maxLines: 2,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .apply(color: textColorDarkPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

/////// EVENT CART
  Widget generateEventChartsList(BuildContext context) {
    return RefreshIndicator(
      onRefresh: (){

        // Timer(
        //     Duration(seconds: 4),
        //         () {
        //       fetchTableCartList();
        //       getKeys();
        //     }
        // );
      },
      child: ListView.builder(
        shrinkWrap: true,
        //padding: const EdgeInsets.only(top: 8.0),
        physics: NeverScrollableScrollPhysics(),
        itemCount: _addOnsBloc.eventCart.length,
        itemBuilder: generateEventExpandableCart,
      ),
    );
  }

  Widget generateEventExpandableCart(BuildContext context, int index) {
    // final item = items[index];

    return ExpandableNotifier(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        child: Dismissible(
          background: Container(
            padding: EdgeInsets.only(right: 20.0),
            alignment: Alignment.centerRight,
            color: Colors.red,
            child: Text(
              'Delete',
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          direction: DismissDirection.endToStart,
          resizeDuration: const Duration(milliseconds: 200),
          key: UniqueKey(),
          onDismissed: (direction) {
            setState(() {
              debugPrint(
                  "-----event id----  ${_addOnsBloc.eventCart[index].id}");
              _addOnsBloc.deleteEvent(_addOnsBloc.eventCart[index].id, context);
            });
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('dismissed')));
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            color: cardBackgroundColor,
            child: Column(
              children: <Widget>[
                ScrollOnExpand(
                  scrollOnExpand: true,
                  scrollOnCollapse: false,
                  child: ExpandablePanel(
                    theme: const ExpandableThemeData(
                      headerAlignment: ExpandablePanelHeaderAlignment.center,
                      iconSize: 28,
                      iconColor: Colors.white,
                      tapBodyToCollapse: true,
                    ),
                    header: generateEventChartsCard(context, index),
                    collapsed: _addOnsBloc.eventCart == null
                        ? Container
                        : (_addOnsBloc.eventCart[index].addons == null || _addOnsBloc.eventCart[index].addons.length == 0)
                            ? Container()
                            : Container(
                                height: _addOnsBloc
                                            .eventCart[index].addons.length ==
                                        1
                                    ? MediaQuery.of(context).size.height * 0.15
                                    : MediaQuery.of(context).size.height * 0.20,
                                child: ListView.builder(
                                    itemCount: _addOnsBloc
                                        .eventCart[index].addons.length,
                                    itemBuilder: (context, i) {
                                      return Dismissible(
                                        background: Container(
                                          padding: EdgeInsets.only(right: 20.0),
                                          alignment: Alignment.centerRight,
                                          color: Colors.red,
                                          child: Text(
                                            'Delete',
                                            textAlign: TextAlign.right,
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        key: UniqueKey(),
                                        direction: DismissDirection.endToStart,
                                        onDismissed: (direction) async {
                                          print(
                                              "addon cart id ------ > ${_addOnsBloc.eventCart[index].addons[i].addonCartId}");
                                          await _addOnsBloc.deleteAddon(
                                            _addOnsBloc.eventCart[index]
                                                .addons[i].addonCartId,
                                            context,
                                          );
                                          fetchAddOns();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text("dismissed"),
                                            ),
                                          );
                                        },
                                        child: Card(
                                          color: Colors.grey
                                              .shade700, //cardBackgroundColor,
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 0),
                                          elevation: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12, horizontal: 8),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  height: 100,
                                                  width: 100,
                                                  child: _addOnsBloc
                                                              .eventCart[index]
                                                              .addons[i]
                                                              .thumbnail ==
                                                          null
                                                      ? Image.asset(
                                                          'assets/images/placeholder.png',
                                                          fit: BoxFit.fill,
                                                          alignment:
                                                              Alignment.center,
                                                        )
                                                      : FadeInImage
                                                          .assetNetwork(
                                                          placeholder:
                                                              'assets/images/placeholder.png',
                                                          image: _addOnsBloc
                                                              .eventCart[index]
                                                              .addons[i]
                                                              .thumbnail,
                                                          fadeInDuration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      500),
                                                          fit: BoxFit.fill,
                                                          alignment:
                                                              Alignment.center,
                                                        ),
                                                ),
                                                const SizedBox(
                                                  width: 12,
                                                ),
                                                Expanded(
                                                  flex: 7,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      // Text(
                                                      //   'Quantity: ${_addOnsBloc.eventCart[index].addons[i].quantity}',
                                                      //   maxLines: 2,
                                                      //   style: Theme.of(context)
                                                      //       .textTheme
                                                      //       .bodyText2
                                                      //       .apply(
                                                      //           color:
                                                      //               textColorDarkPrimary),
                                                      // ),
                                                      // const SizedBox(
                                                      //   height: 2,
                                                      // ),
                                                      Text(
                                                        'Price: ${ClubApp.currencyLbl} ${_addOnsBloc.eventCart[index].addons[i].rate}', // ${tableModel.currency}',
                                                        maxLines: 2,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText2
                                                            .apply(
                                                                color:
                                                                    textColorDarkPrimary),
                                                      ),
                                                      const SizedBox(
                                                        height: 2,
                                                      ),
                                                      Text(
                                                        // "10/50/22",
                                                        'Date: ' +
                                                            _addOnsBloc
                                                                .eventCart[
                                                                    index]
                                                                .addons[i]
                                                                .createdAt
                                                                .toString(),
                                                        maxLines: 2,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText2
                                                            .apply(
                                                                color:
                                                                    textColorDarkPrimary),
                                                      ),
                                                      /*Container(
                                          alignment: Alignment.bottomRight,
                                          child: OutlinedButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              totalAmount -= tableModel.price;
                                                              tableCarts.removeAt(index);
                                                            });
                                                          },
                                                          borderSide: BorderSide(color: borderColor),
                                                          child: Text(
                                                            ClubApp.btn_remove_table,
                                                            style: Theme.of(context)
                                                                .textTheme
                                                                .subtitle2
                                                                .apply(color: Colors.white),
                                                          ),
                                          )),*/
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                    expanded:
                        // (_addOnsBloc.tableCart[index].addOns != null &&
                        //     _addOnsBloc.tableCart[index].addOns.isNotEmpty)
                        //     ?
                        Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 4),
                      color: backgroundColor,
                      // child: generateAddOnCartList(
                      //   _addOnsBloc.tableCart[0].addOns, context, _addOnsBloc.tableCart[0].tableId),
                    )
                    // : const SizedBox(),
                    ,
                    builder: (_, Widget collapsed, Widget expanded) {
                      return Expandable(
                        collapsed: collapsed,
                        expanded: expanded,
                        theme: const ExpandableThemeData(crossFadePoint: 0),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget generateEventChartsCard(BuildContext context, int index) {
    // TableModel tableModel = _addOnsBloc.tableCart[0];
    return Card(
      color: cardBackgroundColor,
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              width: 100,
              child:
                  // Text("name")
                  _addOnsBloc.eventCart[index].thumbnail == null
                      ? Image.asset(
                          'assets/images/placeholder.png',
                          fit: BoxFit.fill,
                          alignment: Alignment.center,
                        )
                      : FadeInImage.assetNetwork(
                          placeholder: 'assets/images/placeholder.png',
                          image: _addOnsBloc.eventCart[index].thumbnail,
                          fadeInDuration: const Duration(milliseconds: 500),
                          fit: BoxFit.fill,
                          alignment: Alignment.center,
                        ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              flex: 7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    //"Name",
                    _addOnsBloc.eventCart[index].eventName,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.subtitle1.apply(
                      color: textColorDarkPrimary,
                    ),
                  ),
                  Text(
                    //"Name",
                    _addOnsBloc.eventCart[index].name,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.subtitle1.apply(
                          color: textColorDarkPrimary,
                        ),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  // Text(
                  //   // "dummy data",
                  //   'Max: ${_addOnsBloc.tableCart[index].capacity} GUESTS',
                  //   maxLines: 2,
                  //   style: Theme.of(context)
                  //       .textTheme
                  //       .bodyText2
                  //       .apply(color: textColorDarkPrimary),
                  // ),
                  // const SizedBox(
                  //   height: 2,
                  // ),
                  Text(
                    // "52898",
                    'Price: ${ClubApp.currencyLbl} ${_addOnsBloc.eventCart[index].rate} ', // ${tableModel.currency}',
                    maxLines: 2,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .apply(color: textColorDarkPrimary),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    // "10/50/22",
                    'Quantity: ' +
                        _addOnsBloc.eventCart[index].quantity.toString(),
                    maxLines: 2,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .apply(color: textColorDarkPrimary),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    // "10/50/22",
                    'Date: ' + _addOnsBloc.eventCart[index].date.toString(),
                    maxLines: 2,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .apply(color: textColorDarkPrimary),
                  ),
                  /*Container(
                      alignment: Alignment.bottomRight,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            totalAmount -= tableModel.price;
                            tableCarts.removeAt(index);
                          });
                        },
                        borderSide: BorderSide(color: borderColor),
                        child: Text(
                          ClubApp.btn_remove_table,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2
                              .apply(color: Colors.white),
                        ),
                      )),*/
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget generateAddOnCartList(
      List<AddOnModel> addOns, BuildContext context, int tableId) {
    return ListView.builder(
        shrinkWrap: true,
        //padding: const EdgeInsets.only(top: 8.0),
        physics: NeverScrollableScrollPhysics(),
        itemCount: addOns.length,
        itemBuilder: (BuildContext context, int index) {
          return generateAddOnCard(addOns, index, tableId);
        });
  }

  Widget generateAddOnCard(List<AddOnModel> addOns, int index, int tableId) {
    AddOnModel addOnModel = addOns[index];
    return Card(
      color: cardBackgroundColor,
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 1.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              width: 100,
              child: addOnModel.imageLink == null
                  ? Image.asset(
                      'assets/images/placeholder.png',
                      fit: BoxFit.fill,
                      alignment: Alignment.center,
                    )
                  : FadeInImage.assetNetwork(
                      placeholder: addOnModel.imageLink,
                      image: addOnModel.imageLink,
                      fadeInDuration: const Duration(milliseconds: 500),
                      fit: BoxFit.fill,
                      alignment: Alignment.center,
                    ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              flex: 7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    addOnModel.description,
                    maxLines: 2,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .apply(color: textColorDarkSecondary),
                  ),
                  const SizedBox(
                    height: 2,
                  ),
                  Text(
                    'Price: ${ClubApp.currencyLbl} ${addOnModel.cost} ${addOnModel.currency}',
                    maxLines: 2,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .apply(color: textColorDarkPrimary),
                  ),
                  Container(
                      alignment: Alignment.bottomRight,
                      child: OutlinedButton(
                        onPressed: () {
                          final AddOnObservable addOnObservable =
                              AddOnObservable();
                          addOnObservable.notifyRemoveAddOn(
                              addOnModel.id, tableId);
                          setState(() {
                            totalAmount -= addOnModel.cost;
                            // _tableCartBloc.totalAmountController
                            //     .add(totalAmount);
                            addOns.removeAt(index);
                          });
                        },
                        // borderSide: BorderSide(color: borderColor),
                        child: Text(
                          ClubApp.btn_remove_table,
                          style: Theme.of(context)
                              .textTheme
                              .subtitle2
                              .apply(color: Colors.white),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getBottomView(context) {
    return StreamBuilder<double>(
      // stream: _tableCartBloc.totalAmountController,
      builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
        if (snapshot.hasData) {
          totalAmount = snapshot.data;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _addOnsBloc.total_amount == _addOnsBloc.pay_amount ?
                    Text('To Pay:' + ' ${ClubApp.currencyLbl} ' +
                        _addOnsBloc.total_amount.toStringAsFixed(2),
                        style: Theme.of(context)
                            .textTheme
                            .subtitle1
                            .apply(color: textColorDarkPrimary))
                    :
                  Text(
                        'Total Amount:' + ' ${ClubApp.currencyLbl} ' +
                            _addOnsBloc.total_amount.toStringAsFixed(2),
                        style: Theme.of(context)
                            .textTheme
                            .bodyText2
                            .apply(color: textColorDarkPrimary)),
                    _addOnsBloc.total_amount != _addOnsBloc.pay_amount ?
                    Text(
                        'To Pay:' + ' ${ClubApp.currencyLbl} ' +
                            _addOnsBloc.pay_amount.toStringAsFixed(2),
                        style: Theme.of(context)
                            .textTheme
                            .headline5
                            .apply(color: textColorDarkPrimary))
                        :
                        Text("")

                  ],
                ),
              ),
              Container(
                //color: Colors.cyan,


                // color: transparentBlack,
//      color: Colors.grey.withAlpha(75),
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: Row(

                  mainAxisAlignment: MainAxisAlignment.center,


                  children: [
                    InkWell(
                      onTap: () async {

        if (_addOnsBloc.totalPrice > 0) {
        print(
        "total from table cart ----------  ${_addOnsBloc.totalPrice}");

        Navigator.push(
        context,
        MaterialPageRoute(
        builder: (context) =>
        Checkout(_addOnsBloc.pay_amount)));


        } else {
        Utility.showSnackBarMessage(_scaffoldKey,
        "Please add atleast one table/event first.");
        }
        if (totalAmount > 0.0) {
        final bool isInternetAvailable =
        await isNetworkAvailable();
        if (isInternetAvailable) {
        // _tableCartBloc.checkoutTable(_addOnsBloc.tableCart, context);
        } else {
        ackAlert(context, ClubApp.no_internet_message);
        }
        } else {
        Utility.showSnackBarMessage(
        _scaffoldKey, ClubApp.table_booking_warning);
        }
        },
                      child: Container(

                        width: MediaQuery.of(context).size.width * 0.40,
                        height: 36,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(
                              color: colorAccent,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(10))),
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Center(
                            child: Text(
                              ClubApp.btn_checkout,style: TextStyle(color: Colors.white,fontSize: 20),

                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     OutlineBorderButton(
              //         buttonBackground,
              //         12.0,
              //         32.0,
              //         ClubApp.btn_checkout,
              //         Theme.of(context)
              //             .textTheme
              //             .subtitle1
              //             .apply(color: Colors.white),
              //         onPressed: () async {
              //
              //       if (_addOnsBloc.totalPrice > 0) {
              //         print(
              //             "total from table cart ----------  ${_addOnsBloc.totalPrice}");
              //
              //         Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //                 builder: (context) =>
              //                     Checkout(_addOnsBloc.pay_amount)));
              //
              //
              //       } else {
              //         Utility.showSnackBarMessage(_scaffoldKey,
              //             "Please add atleast one table/event first.");
              //       }
              //       if (totalAmount > 0.0) {
              //         final bool isInternetAvailable =
              //             await isNetworkAvailable();
              //         if (isInternetAvailable) {
              //           // _tableCartBloc.checkoutTable(_addOnsBloc.tableCart, context);
              //         } else {
              //           ackAlert(context, ClubApp.no_internet_message);
              //         }
              //       } else {
              //         Utility.showSnackBarMessage(
              //             _scaffoldKey, ClubApp.table_booking_warning);
              //       }
              //     }),
              //   ],
              // ),
            ],
          ),
        );
      },
    );
  }
}
