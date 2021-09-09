import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/show_dialog.dart';
import 'package:retroshare/provider/Idenity.dart';
import 'package:retroshare/provider/auth.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';

Widget drawerWidget(BuildContext ctx) {
  Widget buildNavList(IconData icon, String title, Function changeState) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: () {
          changeState();
        },
        child: Row(children: <Widget>[
          Icon(
            icon,
            size: 30,
            color: Theme.of(ctx).textTheme.body2.color,
          ),
          const SizedBox(
            width: 15.0,
          ),
          Text(
            title,
            style: const TextStyle(
                fontFamily: 'Vollkorn',
                fontSize: 17,
                fontWeight: FontWeight.w500),
          ),
        ]),
      ),
    );
  }

  return Drawer(
    child: Column(
      children: [
        Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 2),
            height: MediaQuery.of(ctx).size.height * .35,
            child: Stack(children: [
              Center(
                child: Consumer<Identities>(builder: (context, curr, _) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 100,
                        width: 100,
                        decoration: (curr.currentIdentity.avatar == null)
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.black38))
                            : BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.black38),
                                image: DecorationImage(
                                  fit: BoxFit.fitWidth,
                                  image: MemoryImage(base64
                                      .decode(curr.currentIdentity.avatar)),
                                ),
                              ),
                        child: Visibility(
                          visible: curr.currentIdentity?.avatar == null,
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              size: 80,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      FittedBox(
                        child: Text(
                          curr.currentIdentity.name,
                          style: const TextStyle(
                            fontFamily: 'Vollkorn',
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed(
                                    '/updateIdentity',
                                    arguments: {'id': curr.currentIdentity});
                              },
                              icon: const Icon(
                                FontAwesomeIcons.userEdit,
                                size: 18,
                                color: Colors.blue,
                              )),
                          IconButton(
                              onPressed: () {
                                showdeleteDialog(context);
                              },
                              icon: const Icon(
                                FontAwesomeIcons.trash,
                                size: 18,
                                color: Colors.red,
                              ))
                        ],
                      )
                    ],
                  );
                }),
              ),
            ])),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              buildNavList(Icons.person_add_alt, 'Add friend', () {
                Future.delayed(Duration.zero, () {
                  Navigator.pushNamed(ctx, '/add_friend');
                });
              }),
              buildNavList(Icons.add, 'Create new identity', () {
                Navigator.pushNamed(ctx, '/create_identity');
              }),
              buildNavList(Icons.visibility, 'Change identity', () {
                Navigator.pushNamed(ctx, '/change_identity');
              }),
              buildNavList(Icons.devices, 'Friends location', () {
                Navigator.pushNamed(ctx, '/friends_locations');
              }),
              buildNavList(Icons.language, 'Discover public chats', () {
                Navigator.pushNamed(ctx, '/discover_chats');
              }),
              buildNavList(Icons.info_rounded, 'About', () {
                Navigator.pushNamed(ctx, '/about');
              })
            ],
          ),
        ),
        const Spacer(),
        const Text(
          'V 1.0.1',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blueAccent),
        ),
        const SizedBox(
          height: 30,
        )
      ],
    ),
  );
}

AppBar appBar(String title, BuildContext context) {
  return AppBar(
    backgroundColor: Colors.white,
    shadowColor: Colors.transparent,
    title: Text(
      title,
      style: const TextStyle(color: Colors.black, fontSize: 14.5),
    ),
    leading: BackButton(
      color: Colors.black,
      onPressed: () {
        Navigator.of(context).pop();
      },
    ),
  );
}

class NotificationIcon extends StatefulWidget {
  @override
  _NotificationIconState createState() => _NotificationIconState();
}

class _NotificationIconState extends State<NotificationIcon> {
  Future<dynamic> _inviteList() async {
    final AuthToken authToken =
        Provider.of<AccountCredentials>(context, listen: false).authtoken;
    return RsMsgs.getPendingChatLobbyInvites(authToken);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Icon(Icons.notifications,
            color: Theme.of(context).primaryColor, size: 28),
        Positioned(
            top: 1,
            right: 1,
            child: CircleAvatar(
                backgroundColor: Colors.purple,
                radius: 7,
                child: FutureBuilder(
                  future: _inviteList(),
                  builder: (context, snapshot) {
                    return snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData
                        ? FittedBox(
                            child: Text(
                            snapshot.data.length.toString(),
                            style: const TextStyle(fontSize: 8),
                          ))
                        : const FittedBox(
                            child: Text('0', style: TextStyle(fontSize: 8)));
                  },
                ))),
      ],
    );
  }
}
