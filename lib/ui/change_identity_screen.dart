import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/bottom_bar.dart';
import 'package:retroshare/common/drawer.dart';
import 'package:retroshare/common/person_delegate.dart';
import 'package:retroshare/common/shimmer.dart';
import 'package:retroshare/common/styles.dart';
import 'package:retroshare/provider/Idenity.dart';

class ChangeIdentityScreen extends StatefulWidget {
  @override
  _ChangeIdentityScreenState createState() => _ChangeIdentityScreenState();
}

class _ChangeIdentityScreenState extends State<ChangeIdentityScreen> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<Identities>(context, listen: false).fetchOwnidenities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBar('Change Identity', context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder(
            future: Provider.of<Identities>(context, listen: false)
                .fetchOwnidenities(),
            builder: (context, snapshot) {
              return snapshot.connectionState == ConnectionState.done
                  ? ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: Provider.of<Identities>(context, listen: false)
                              .ownIdentity
                              .length ??
                          0,
                      itemBuilder: (BuildContext context, int index) {
                        return PersonDelegate(
                          data: PersonDelegateData.IdentityData(
                            Provider.of<Identities>(context, listen: false)
                                .ownIdentity[index],
                            context,
                          ),
                          isSelectable: true,
                          onPressed: () {
                            final id =
                                Provider.of<Identities>(context, listen: false)
                                    .ownIdentity[index];
                            Provider.of<Identities>(context, listen: false)
                                .updateSelectedIdentity(id);
                          },
                        );
                      },
                    )
                  : ChangeIdentityShimmer();
            },
          ),
        ),
      ),
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
                  horizontal: 16.0 + personDelegateHeight * 0.04,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: const LinearGradient(
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
                      style: Theme.of(context).textTheme.labelLarge,
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
