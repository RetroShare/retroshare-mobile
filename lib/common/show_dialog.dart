import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/styles.dart';
import 'package:retroshare/model/http_exception.dart';

import 'package:retroshare/provider/Idenity.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';

errorShowDialog(String title, String text, BuildContext context) {
  return CoolAlert.show(
    context: context,
    type: CoolAlertType.error,
    onConfirmBtnTap: () {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    },
    title: title,
    text: text,
  );
}

loading(BuildContext context) {
  return CoolAlert.show(context: context, type: CoolAlertType.loading);
}

successShowDialog(String title, String text, BuildContext context) {
  return CoolAlert.show(
    context: context,
    type: CoolAlertType.success,
    onConfirmBtnTap: () {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    },
    title: title,
    text: text,
  );
}

warningShowDialog(String title, String text, BuildContext context) {
  return CoolAlert.show(
    context: context,
    type: CoolAlertType.warning,
    onConfirmBtnTap: () {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    },
    title: title,
    text: text,
  );
}

contentBox(context) {
  return Stack(
    children: <Widget>[
      Container(
        padding: EdgeInsets.only(
            left: Constants.padding,
            top: Constants.avatarRadius,
            right: Constants.padding,
            bottom: Constants.padding),
        margin: EdgeInsets.only(top: Constants.avatarRadius),
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(Constants.padding),
            boxShadow: [
              BoxShadow(
                  color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
            ]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'something went Wrong!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 15,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "OK",
                    style: TextStyle(fontSize: 14),
                  )),
            ),
          ],
        ),
      ),
      Positioned(
        left: Constants.padding,
        right: Constants.padding,
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: Constants.avatarRadius,
          child: ClipRRect(
            borderRadius:
                BorderRadius.all(Radius.circular(Constants.avatarRadius)),
            child: Image(
              image: AssetImage('assets/rs-logo.png'),
            ),
          ),
        ),
      ),
    ],
  );
}

// delete dialog Box

void showdeleteDialog(context) {
  String name =
      Provider.of<Identities>(context, listen: false).currentIdentity.name;
  List<Identity> ownIdsList =
      Provider.of<Identities>(context, listen: false).ownIdentity;

  if (ownIdsList.length > 1)
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete '$name'?"),
          content: Text(
              "The deletion of identity cannot be undone. Are you sure you want to continue?"),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Delete'),
              onPressed: () async {
                try {
                  await Provider.of<Identities>(context, listen: false)
                      .deleteIdentity();
                  Navigator.of(context).pop();
                } on HttpException catch (err) {
                  warningShowDialog("Retro Service is Down",
                      "Please ensure retroshare service is not down", context);
                } catch (e) {
                  warningShowDialog(
                      "Try Again", "Something wrong happens!", context);
                }
              },
            ),
          ],
        );
      },
    );
  else
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Too few identities"),
          content: Text(
              "You must have at least one more identity to be able to delete this one."),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
}
