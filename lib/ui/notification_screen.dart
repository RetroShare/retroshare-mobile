import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/styles.dart';
import 'package:retroshare/provider/Idenity.dart';
import 'package:retroshare/provider/auth.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  Future<dynamic> getinvitelist(BuildContext context) async {
    final authToken =
        Provider.of<AccountCredentials>(context, listen: false).authtoken;
    final invites = await RsMsgs.getPendingChatLobbyInvites(authToken);
    for (int i = 0; i < invites.length; i++) {
      invites[i]['location'] = await RsPeers.getPeerDetails(
        invites[i]['peer_id'].toString(),
        authToken,
      );
      invites[i]['authtoken'] = authToken;
    }
    return invites;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: appBarHeight,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: personDelegateHeight,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 25,
                      ),
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Notification',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: getinvitelist(context),
                builder: (context, snapshot) {
                  return snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData
                      ? snapshot.data.length > 0 == true
                          ? ListView.builder(
                              itemCount: snapshot.data.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 8,
                                  ),
                                  child: Container(
                                    height: 100,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              RichText(
                                                text: TextSpan(
                                                  text:
                                                      // ignore: lines_longer_than_80_chars
                                                      '${snapshot.data[index]['location'].accountName}',
                                                  style: const TextStyle(
                                                    fontFamily: 'Oxygen',
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                  ),
                                                  children: <TextSpan>[
                                                    const TextSpan(
                                                      text:
                                                          // ignore: lines_longer_than_80_chars
                                                          ' sent you the invite to join the chatlobby ',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontFamily: 'Oxygen',
                                                      ),
                                                    ),
                                                    TextSpan(
                                                        text:
                                                            // ignore: lines_longer_than_80_chars
                                                            '${snapshot.data[index]['lobby_name']}.',
                                                        // ignore: lines_longer_than_80_chars
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontFamily: 'Oxygen',
                                                        ),),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () async {
                                                        // ignore: lines_longer_than_80_chars
                                                        await RsMsgs
                                                            .denyLobbyInvite(
                                                          snapshot.data[index]
                                                                  ['lobby_id']
                                                              ['xstr64'],
                                                          snapshot.data[index]
                                                              ['authtoken'],
                                                        );
                                                        setState(() {});
                                                      },
                                                      child: const Text(
                                                        'Cancel',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        final mId = Provider.of<
                                                            Identities>(
                                                          context,
                                                          listen: false,
                                                        ).currentIdentity.mId;

                                                        RsMsgs
                                                            .acceptLobbyInvite(
                                                          snapshot.data[index]
                                                                  ['lobby_id']
                                                              ['xstr64'],
                                                          mId,
                                                          snapshot.data[index]
                                                              ['authtoken'],
                                                        ).then((value) {
                                                          if (value) {
                                                            Navigator.of(
                                                              context,
                                                            ).pushNamed(
                                                              '/home',
                                                            );
                                                          }
                                                        });
                                                      },
                                                      child: const Text(
                                                        'Accept',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.blueAccent,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: SizedBox(
                                width: 200,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Image.asset(
                                      'assets/icons8/pluto_notification.png',
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 25,),
                                      child: Text(
                                        "Looks like there aren't any notification",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                      : const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
