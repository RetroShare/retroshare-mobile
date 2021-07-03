import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/provider/Idenity.dart';
import 'package:retroshare/common/styles.dart';
import 'package:retroshare/common/bottom_bar.dart';
import 'package:retroshare/common/person_delegate.dart';

class ChangeIdentityScreen extends StatefulWidget {
  @override
  _ChangeIdentityScreenState createState() => _ChangeIdentityScreenState();
}

class _ChangeIdentityScreenState extends State<ChangeIdentityScreen> {
  void _undoChangesOnExit(BuildContext context) {}

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<Identities>(context, listen: false).fetchOwnidenities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        _undoChangesOnExit(context);
        return Future.value(true);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          top: true,
          bottom: true,
          child: Column(
            children: <Widget>[
              Container(
                height: appBarHeight,
                child: Row(
                  children: <Widget>[
                    Container(
                      width: personDelegateHeight,
                      child: Visibility(
                        child: Center(
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              size: 25,
                            ),
                            onPressed: () {
                              _undoChangesOnExit(context);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Change identity',
                        style: Theme.of(context).textTheme.body2,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Consumer<Identities>(
                    builder: (ctx, idsTuple, _) => ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: idsTuple.ownIdentity?.length ?? 0,
                          itemBuilder: (BuildContext context, int index) {
                            return PersonDelegate(
                              data: PersonDelegateData.IdentityData(
                                  idsTuple.ownIdentity[index], context),
                              isSelectable: true,
                              onPressed: () {
                                final id = idsTuple.ownIdentity[index];
                                idsTuple.updateSelectedIdentity(id);
                              },
                            );
                          },
                        )),
              ),
              BottomBar(
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
                              'Change identity',
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
            ],
          ),
        ),
      ),
    );
  }
}
