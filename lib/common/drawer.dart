import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/show_dialog.dart';
import 'package:retroshare/provider/Idenity.dart';

Widget drawerWidget(BuildContext ctx) {
  Widget buildList(IconData icon, String title, Function changeState) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
          child: Row(children: [
            Icon(
              icon,
              size: 30,
              color: Colors.black,
            ),
            SizedBox(
              width: 15,
            ),
            Text(
              title,
              style: TextStyle(
                  fontSize: 17,
                  fontFamily: 'Vollkorn',
                  fontWeight: FontWeight.w500),
            ),
          ]),
          onTap: changeState),
    );
  }

  return Drawer(
    child: Column(
      children: [
        Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top:15),
            height: MediaQuery.of(ctx).size.height * .3,
            child: Center(
              child: Consumer<Identities>(builder: (context, curr, _) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 100,
                      width: 100,
                      decoration:  (curr.currentIdentity.avatar == null)
                          ? BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.black))
                          : BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.black),
                              image: DecorationImage(
                                fit: BoxFit.fitWidth,
                                image: MemoryImage(
                                    base64.decode(curr.currentIdentity.avatar)),
                              ),
                            ),
                      child: Visibility(
                        visible: (curr.currentIdentity?.avatar == null),
                        child: Center(
                          child: Icon(
                            Icons.person,
                            size: 80,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    FittedBox(
                      child: Text(
                        curr.currentIdentity.name,
                        style: TextStyle(
                            fontFamily: "Vollkorn",
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacementNamed(
                                  '/updateIdentity',
                                  arguments: {'id': curr.currentIdentity});
                            },
                            icon: Icon(
                              FontAwesomeIcons.userEdit,
                              size: 18,
                              color: Colors.blue,
                            )),
                        IconButton(
                            onPressed: () {
                             showdeleteDialog(context);
                            },
                            icon: Icon(
                              FontAwesomeIcons.trash,
                              size: 18,
                              color: Colors.red,
                            ))
                      ],
                    )
                  ],
                );
              }),
            )),
        Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              buildList(Icons.person_add_alt, 'Add friend', () {
                Future.delayed(Duration.zero, () {
                  Navigator.pushNamed(ctx, '/add_friend');
                });
              }),
              buildList(Icons.add, 'Create new identity', () {
                Navigator.pushNamed(ctx, '/create_identity');
              }),
              buildList(Icons.visibility, 'Change identity', () {
                Navigator.pushNamed(ctx, '/change_identity');
              }),
              buildList(Icons.devices, 'Friends location', () {
                Navigator.pushNamed(ctx, '/friends_locations');
              }),
              buildList(Icons.emoji_symbols_rounded, 'Forum', () {
                Navigator.pushNamed(ctx, '/forum');
              }),
              buildList(Icons.info_rounded, 'About', () {
                Navigator.pushNamed(ctx, '/about');
              })
            ],
          ),
        ),
        Spacer(),
        Text(
          "V 1.0.1",
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blueAccent),
        ),
        SizedBox(
          height: 30,
        )
      ],
    ),
  );
}
