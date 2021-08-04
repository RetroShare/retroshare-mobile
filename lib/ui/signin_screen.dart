import 'dart:io';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/show_dialog.dart';
import 'package:retroshare/model/account.dart';
import 'package:retroshare/provider/Idenity.dart';
import 'package:retroshare/provider/auth.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  TextEditingController passwordController = new TextEditingController();

  List<DropdownMenuItem<Account>> accountsDropdown;
  Account currentAccount;
  bool hideLocations;
  bool wrongPassword;

  @override
  void initState() {
    super.initState();
    hideLocations = true;
    wrongPassword = false;
  }

  /*Future<bool> importAccountFunc(BuildContext context) async {
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
  }*/

  ///data/user/0/cc.retroshare.retroshare/app_flutter/A154FAA45930DB66.txt
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    accountsDropdown = getDropDownMenuItems();

    currentAccount = Provider.of<AccountCredentials>(context, listen: false)
        .getlastAccountUsed;
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  void attemptLogIn(Account currentAccount, String password) async {
    Navigator.pushNamed(context, '/', arguments: {
      'statusText': "Attempt login...\nCrypto in course",
      'isLoading': true,
      'spinner': true
    });
    try {
      await Provider.of<AccountCredentials>(context, listen: false)
          .login(currentAccount, password);
      final ids = Provider.of<Identities>(context, listen: false);
      ids.fetchOwnidenities().then((value) {
        ids.ownIdentity != null && ids.ownIdentity.length == 0
            ? Navigator.pushReplacementNamed(context, '/create_identity',
                arguments: true)
            : Navigator.pushReplacementNamed(context, '/home');
      });
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';
      print(error);
      if (error.toString().contains('WRONG PASSWORD')) {
        errorMessage = 'Your Password is wrong';
        errorShowDialog('WRONG PASSWORD', errorMessage, context);
      } else
        errorShowDialog(
            errorMessage, 'Please input your valid credentials', context);
    } catch (e) {
      errorShowDialog('Retroshare Service Down',
          'Please ensure retroshare dervice is not down!', context);
    }
  }

  void _isWrongPassword() {
    Navigator.pop(context);
    setState(() {
      wrongPassword = true;
    });
  }

  List<DropdownMenuItem<Account>> getDropDownMenuItems() {
    List<DropdownMenuItem<Account>> items = [];
    for (Account account
        in Provider.of<AccountCredentials>(context, listen: true).accountList) {
      items.add(DropdownMenuItem(
        value: account,
        child: Row(
          children: <Widget>[
            Text(account.pgpName),
            Visibility(
              visible: !hideLocations,
              child: Text(':' + account.locationName),
            )
          ],
        ),
      ));
    }
    return items;
  }

  void changedDropDownItem(Account selectedAccount) {
    setState(() {
      currentAccount = selectedAccount;
    });
  }

  void revealLocations() {
    if (hideLocations) {
      setState(() {
        hideLocations = false;
        accountsDropdown = getDropDownMenuItems();
      });

      showToast('Locations revealed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                child: Image.asset('assets/rs-logo.png',
                                    height: 250, width: 250),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Color(0xFFF5F5F5),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  height: 40,
                                  child: GestureDetector(
                                    onLongPress: () {
                                      revealLocations();
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Icon(
                                          Icons.person_outline,
                                          color: Color(0xFF9E9E9E),
                                          size: 22.0,
                                        ),
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Expanded(
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton(
                                              value: currentAccount,
                                              items: accountsDropdown,
                                              onChanged: changedDropDownItem,
                                              disabledHint: Text('Login'),
                                            ),
                                          ),
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
                                    color: Color(0xFFF5F5F5),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  height: 40,
                                  child: TextField(
                                    controller: passwordController,
                                    decoration: InputDecoration(
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
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 52,
                                      ),
                                      Container(
                                        height: 25,
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
                              SizedBox(height: wrongPassword ? 10 : 30),
                              FlatButton(
                                onPressed: () {
                                  attemptLogIn(
                                      currentAccount, passwordController.text);
                                },
                                textColor: Colors.white,
                                padding: const EdgeInsets.all(0.0),
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
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(fontSize: 20),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              FlatButton(
                                onPressed: () async {
                                  //await importAccountFunc(context);
                                },
                                textColor: Color(0xFF9E9E9E),
                                padding: const EdgeInsets.all(0.0),
                                child: Text(
                                  'Import account',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              FlatButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/signup');
                                },
                                textColor: Color(0xFF9E9E9E),
                                padding: const EdgeInsets.all(0.0),
                                child: Text(
                                  'Create account',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
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
