import 'dart:io';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/show_dialog.dart';
import 'package:retroshare/provider/Idenity.dart';
import 'package:retroshare/provider/auth.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController passwordController = TextEditingController();

  late List<DropdownMenuItem<Account>> accountsDropdown;
  late Account currentAccount;
  late bool hideLocations;
  late bool wrongPassword;

  @override
  void initState() {
    super.initState();
    hideLocations = true;
    wrongPassword = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    currentAccount = Provider.of<AccountCredentials>(context, listen: false)
        .getlastAccountUsed;
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  Future<void> attemptLogIn(Account currentAccount, String password) async {
    Navigator.pushNamed(context, '/', arguments: {
      'statusText': 'Attempt login...\nCrypto in course',
      'isLoading': true,
      'spinner': true,
    },);
    try {
      await Provider.of<AccountCredentials>(context, listen: false)
          .login(currentAccount, password)
          .then((value) {
        final ids = Provider.of<Identities>(context, listen: false);
        ids.fetchOwnidenities().then((value) {
          ids.ownIdentity.isEmpty
              ? Navigator.pushReplacementNamed(
                  context,
                  '/create_identity',
                  arguments: true,
                )
              : Navigator.pushReplacementNamed(context, '/home');
        });
      });
    } on HttpException catch (error) {
      const errorMessage = 'Authentication failed';
      if (error.message.contains('WRONG PASSWORD')) {
        _isWrongPassword();
      } else {
        errorShowDialog(
          errorMessage,
          'Please input your valid credentials',
          context,
        );
      }
    } catch (e) {
      errorShowDialog(
        'Retroshare Service Down',
        'Try to  restart the app',
        context,
      );
    }
  }

  void _isWrongPassword() {
    Navigator.pop(context);
    setState(() {
      wrongPassword = true;
    });
  }

  List<DropdownMenuItem<Account>> getDropDownMenuItems(BuildContext context) {
    final List<DropdownMenuItem<Account>> items = [];
    for (final Account account
        in Provider.of<AccountCredentials>(context, listen: false)
            .accountList) {
      items.add(DropdownMenuItem(
        value: account,
        key: UniqueKey(),
        child: Row(
          children: <Widget>[
            Text(account.pgpName),
            Visibility(
              visible: !hideLocations,
              child: Text(':${account.locationName}'),
            ),
          ],
        ),
      ),);
    }
    return items;
  }

  void changedDropDownItem(Account selectedAccount) {
    setState(() {
      currentAccount = selectedAccount;
    });
  }

  void revealLocations(BuildContext context) {
    if (hideLocations) {
      setState(() {
        hideLocations = false;
      });
      showToast('Locations revealed');
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Center(
                  child: SizedBox(
                    width: 300,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Hero(
                                tag: 'logo',
                                child: Image.asset(
                                  'assets/rs-logo.png',
                                  height: 250,
                                  width: 250,
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: const Color(0xFFF5F5F5),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  height: 40,
                                  child: GestureDetector(
                                    onLongPress: () {
                                      revealLocations(context);
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        const Icon(
                                          Icons.person_outline,
                                          color: Color(0xFF9E9E9E),
                                          size: 22.0,
                                        ),
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        Expanded(
                                          child: getDropDownMenuItems(context)
                                                      .isNotEmpty
                                              ? DropdownButtonHideUnderline(
                                                  child: DropdownButton(
                                                    value: currentAccount,
                                                    items: getDropDownMenuItems(
                                                        context,),
                                                    onChanged:
                                                        changedDropDownItem,
                                                    disabledHint:
                                                        const Text('Login'),
                                                  ),
                                                )
                                              : const SizedBox(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              SizedBox(
                                width: double.infinity,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: const Color(0xFFF5F5F5),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                  ),
                                  height: 40,
                                  child: TextField(
                                    controller: passwordController,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      icon: Icon(
                                        Icons.lock_outline,
                                        color: Color(0xFF9E9E9E),
                                        size: 22.0,
                                      ),
                                      hintText: 'Password',
                                    ),
                                    obscureText: true,
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: wrongPassword,
                                child: const SizedBox(
                                  width: double.infinity,
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(
                                        height: 25,
                                        width: 52,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            'Wrong password',
                                            style: TextStyle(
                                              color: Colors.red,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: wrongPassword ? 8 : 24),
                              TextButton(
                                onPressed: () {
                                  attemptLogIn(
                                    currentAccount,
                                    passwordController.text,
                                  );
                                },
                                style: TextButton.styleFrom(
                                    foregroundColor: Colors.white),
                                // padding: EdgeInsets.zero,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: const LinearGradient(
                                        colors: <Color>[
                                          Color(0xFF00FFFF),
                                          Color(0xFF29ABE2),
                                        ],
                                        begin: Alignment(-1.0, -4.0),
                                        end: Alignment(1.0, 4.0),
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(7.0),
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(fontSize: 17),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              const Text(
                                'OR',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Oxygen',
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(
                                height: 6,
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/signup');
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white),
                                // padding: EdgeInsets.zero,
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: const LinearGradient(
                                        colors: <Color>[
                                          Color(0xFF00FFFF),
                                          Color(0xFF29ABE2),
                                        ],
                                        begin: Alignment(-1.0, -4.0),
                                        end: Alignment(1.0, 4.0),
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(7.0),
                                    child: const Text(
                                      'Create Account',
                                      style: TextStyle(fontSize: 17),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// WIP : Import Identity Functionlity
/** 

Future<bool> importAccountFunc(BuildContext context) async {
    // FilePickerResult result = await FilePicker.platform.pickFiles();
    final result = 'abc';
    if (result != null) {
      File pgpFile = File(
          '/data/user/0/cc.retroshare.retroshare/app_flutter/A154FAA45930DB66.txt');
      try {
        final file = pgpFile;
        final contents = await file.readAsString();
        final pgpId = await importIdentity(contents);
      } catch (e) {
        final snackBar = SnackBar(
          content: Text('Oops! Something went wrong'),
          duration: Duration(milliseconds: 200),
          backgroundColor: Colors.red[200],
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } else {
      final snackBar = SnackBar(
        content: Text('Oops! Please pick up the file'),
        duration: Duration(milliseconds: 200),
        backgroundColor: Colors.red[200],
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
  **/

///data/user/0/cc.retroshare.retroshare/app_flutter/A154FAA45930DB66.txt
