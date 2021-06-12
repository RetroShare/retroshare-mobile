import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:retroshare/services/init.dart';

import 'package:retroshare/model/account.dart';
import 'package:retroshare/services/account.dart';

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
    hideLocations = true;
    wrongPassword = false;
    accountsDropdown = getDropDownMenuItems();

    currentAccount = lastAccountUsed;
    print(lastAccountUsed);
    super.initState();
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
    int resp = await requestLogIn(currentAccount, password);

    // Login success 0, already logged in 1
    if (resp == 0 || resp == 1) {
      bool isAuthTokenValid =
          await initializeAuth(currentAccount.locationName, password);
      print(isAuthTokenValid);
      if (isAuthTokenValid) {
        loggedinAccount = currentAccount;
        initializeStore(context);
      } else {
        _isWrongPassword();
      }
    } else if (resp == 3) {
      _isWrongPassword();
    }
  }

  void _isWrongPassword() {
    Navigator.pop(context);
    setState(() {
      wrongPassword = true;
    });
  }

  List<DropdownMenuItem<Account>> getDropDownMenuItems() {
    List<DropdownMenuItem<Account>> items = new List();
    for (Account account in accountsList) {
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
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .body2,
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
                                    style: Theme.of(context).textTheme.body2,
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
                                onPressed: () {},
                                textColor: Color(0xFF9E9E9E),
                                padding: const EdgeInsets.all(0.0),
                                child: Text(
                                  'Import account',
                                  style: Theme.of(context).textTheme.body1,
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
                                  style: Theme.of(context).textTheme.body1,
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
