import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

showFlutterToast(String title, Color color) {
  return Fluttertoast.showToast(
      msg: title,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 16.0);
}

contentBox(BuildContext context) {
  return Stack(
    children: <Widget>[
      Container(
        padding: const EdgeInsets.only(
            left: Constants.padding,
            top: Constants.avatarRadius,
            right: Constants.padding,
            bottom: Constants.padding),
        margin: const EdgeInsets.only(top: Constants.avatarRadius),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Constants.padding),
            boxShadow: const [
              BoxShadow(offset: Offset(0, 10), blurRadius: 10),
            ]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'something went Wrong!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 15,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(fontSize: 14),
                  )),
            ),
          ],
        ),
      ),
      const Positioned(
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

void showdeleteDialog(BuildContext context) {
  final String name =
      Provider.of<Identities>(context, listen: false).currentIdentity.name;
  final List<Identity> ownIdsList =
      Provider.of<Identities>(context, listen: false).ownIdentity;

  if (ownIdsList.length > 1) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete '$name'?"),
          content: const Text(
              // ignore: lines_longer_than_80_chars
              'The deletion of identity cannot be undone. Are you sure you want to continue?'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            FlatButton(
              onPressed: () async {
                try {
                  await Provider.of<Identities>(context, listen: false)
                      .deleteIdentity()
                      .then((value) {
                    Navigator.of(context).pop();
                  });
                } on HttpException catch (e) {
                  warningShowDialog('Retro Service is Down',
                      'Please ensure retroshare service is not down', context);
                } catch (e) {
                  warningShowDialog(
                      'Try Again', 'Something wrong happens!', context);
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  } else {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Too few identities'),
          content: const Text(
              // ignore: lines_longer_than_80_chars
              'You must have at least one more identity to be able to delete this one.'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }
}
