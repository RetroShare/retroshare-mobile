
import 'package:flutter/material.dart';


class LaunchTransitionScreen extends StatefulWidget {
  @override
  _LaunchTransitionScreenState createState() => _LaunchTransitionScreenState();
}

class _LaunchTransitionScreenState extends State<LaunchTransitionScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          flex: 7,
                          child: Hero(
                            tag: 'logo',
                            child: Image.asset(
                              'assets/rs-logo.png',
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: <Widget>[
                              FlatButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/signup');
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
                                      'Create account',
                                      style: TextStyle(fontSize: 18),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              FlatButton(
                                onPressed: () async {
                                  //await importAccountFunc(context);
                                  // todo: implement import account
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
                                      'Import account',
                                      style: TextStyle(fontSize: 18),
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


  /*Future<bool> importAccountFunc(BuildContext context) async {
    FilePickerResult result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File pgpFile = File(result.files.single.path);
      try {
        final file = pgpFile;
        final contents = await file.readAsString();
        await importIdentity(contents);
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