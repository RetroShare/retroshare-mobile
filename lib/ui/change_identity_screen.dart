import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/provider/Idenity.dart';
import 'package:retroshare/common/styles.dart';
import 'package:retroshare/common/bottom_bar.dart';
import 'package:retroshare/common/person_delegate.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';
import 'package:shimmer/shimmer.dart';

class ChangeIdentityScreen extends StatefulWidget {
  @override
  _ChangeIdentityScreenState createState() => _ChangeIdentityScreenState();
}

class _ChangeIdentityScreenState extends State<ChangeIdentityScreen> {
  void _undoChangesOnExit(BuildContext context) {}

  @override
  void initState() {
    Provider.of<Identities>(context, listen: false).fetchOwnidenities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          "Change Identity",
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 16, fontFamily: "Oxygen"),
        ),
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
          top: true,
          bottom: true,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder(
                future: Provider.of<Identities>(context, listen: false)
                    .fetchOwnidenities(),
                builder: (context, snapshot) {
                  return snapshot.connectionState == ConnectionState.done
                      ? Consumer<Identities>(builder: (ctx, idsTuple, _) {
                          List<Identity>ownIdentity = idsTuple.ownIdentity
                              .where(
                                  (element) => element.mId != '00000000000000000000000000000000')
                              .toList();
                          return ListView.builder(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: ownIdentity?.length ?? 0,
                            itemBuilder: (BuildContext context, int index) {
                              return PersonDelegate(
                                data: PersonDelegateData.IdentityData(
                                    ownIdentity[index], context),
                                isSelectable: true,
                                onPressed: () {
                                  final id = ownIdentity[index];
                                  idsTuple.updateSelectedIdentity(id);
                                },
                              );
                            },
                          );
                        })
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 0),
                          child: Shimmer(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFEBEBF4),
                                Color(0xFFF4F4F4),
                                Color(0xFFEBEBF4),
                              ],
                              stops: [
                                0.1,
                                0.3,
                                0.4,
                              ],
                              begin: Alignment(-1.0, -0.3),
                              end: Alignment(1.0, 0.3),
                              tileMode: TileMode.clamp,
                            ),
                            enabled: true,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              itemBuilder: (_, __) => Container(
                                  padding: const EdgeInsets.only(
                                      bottom: 8.0, left: 8, right: 8, top: 8),
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 8),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.white),
                                      borderRadius: BorderRadius.circular(14)),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          width: 60,
                                          height: 60,
                                          alignment: Alignment.topCenter,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15))),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.all(8)),
                                        Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 60,
                                                height: 8,
                                                color: Colors.white,
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    top: 4),
                                                width: 210,
                                                height: 18,
                                                color: Colors.white,
                                              ),
                                            ])
                                      ])),
                              itemCount: 6,
                            ),
                          ),
                        );
                }),
          )),
      bottomNavigationBar: BottomBar(
        child: Center(
          child: SizedBox(
            height: 2 * appBarHeight / 3,
            child: FlatButton(
              onPressed: () {
                Provider.of<Identities>(context, listen: false)
                    .updatecurrentIdentity();
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0 + personDelegateHeight * 0.04),
                child: SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: <Color>[
                          Color(0xFF00FFFF),
                          Color(0xFF29ABE2),
                        ],
                        begin: Alignment(-1.0, -4.0),
                        end: Alignment(1.0, 4.0),
                      ),
                    ),
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'Change Identity',
                      style: Theme.of(context).textTheme.button,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
