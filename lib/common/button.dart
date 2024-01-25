import 'package:flutter/material.dart';

import 'package:retroshare/common/styles.dart';

class Button extends StatelessWidget {
  const Button({required this.name,required this.buttonIcon,required this.onPressed});

  final String name;
  final IconData buttonIcon;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed();
      },
      child: Container(
        color: Colors.white,
        height: buttonHeight,
        child: Row(
          children: <Widget>[
            SizedBox(
              height: personDelegateHeight,
              width: personDelegateHeight,
              child: Center(
                child: Icon(
                  buttonIcon,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      name,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
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
