import 'package:flutter/material.dart';

import 'package:retroshare/common/styles.dart';

class Button extends StatelessWidget {
  const Button({this.name, this.buttonIcon, this.onPressed});

  final String name;
  final IconData buttonIcon;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if(onPressed != null)
          onPressed();
      },
      child: Container(
        color: Colors.white,
        height: buttonHeight,
        child: Row(
          children: <Widget>[
            Container(
              height: personDelegateHeight,
              width: personDelegateHeight,
              child: Center(
                child: Icon(this.buttonIcon,
                    color: Theme.of(context).textTheme.body2.color),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(this.name, style: Theme.of(context).textTheme.body2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}