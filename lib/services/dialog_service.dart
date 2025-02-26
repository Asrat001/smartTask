import 'package:flutter/material.dart';
import 'package:task_manager/components/rounded_alert_dialog.dart';
import 'package:task_manager/components/rounded_button.dart';
import 'package:task_manager/l10n/l10n.dart';

class DialogService {

  GlobalKey<NavigatorState>? _navigatorKey;
  void init(GlobalKey<NavigatorState> key) => _navigatorKey = key;

  BuildContext? get _getCurrentContext => _navigatorKey?.currentContext;

  void showNoInternetConnectionDialog() {
    final context = _getCurrentContext;

    if(context != null){
      RoundedAlertDialog(
        buildContext: context,
        svgImage: "assets/svg/stars.svg",
        title: context.l10n.alertDialog_noInternetConnection,
        description: context.l10n.alertDialog_noInternetConnection_description,
        actions: [
          RoundedTextButton(
            expandWidth: false,
            textPadding: const EdgeInsets.symmetric(horizontal: 32.0),
            text: context.l10n.gotIt_button,
            onPressed: () => Navigator.of(context, rootNavigator: true).pop()
          ),
        ],
      ).show();
    } 
  }
  void showLoadingDialog() {
    final context = _getCurrentContext;
   if(context !=null){
     showDialog(
       context: context,
       barrierDismissible: false, // Prevent closing by tapping outside
       builder: (context) {
         return Dialog(
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
           child: Padding(
             padding: const EdgeInsets.all(20.0),
             child: Column(
               mainAxisSize: MainAxisSize.min,
               children: const [
                 CircularProgressIndicator(),
               ],
             ),
           ),
         );
       },
     );
   }
  }
  void showSomethingWentWrongDialog(String errorMsg){
    final context = _getCurrentContext;

    if(context != null){
      RoundedAlertDialog(
        buildContext: context,
        svgImage: "assets/svg/stars.svg",
        title: context.l10n.alertDialog_somethingWentWrong,
        description:errorMsg,
        actions: [
          RoundedTextButton(
            expandWidth: false,
            textPadding: const EdgeInsets.symmetric(horizontal: 32.0),
            text: context.l10n.gotIt_button,
            onPressed: () => Navigator.of(context, rootNavigator: true).pop()
          ),
        ],
      ).show();
    }
  }
}