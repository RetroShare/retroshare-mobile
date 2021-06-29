import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/image_picker_dialog.dart';
import 'dart:io';
import 'dart:convert';
import 'package:retroshare/common/styles.dart';
import 'package:retroshare/common/bottom_bar.dart';
import 'package:retroshare/model/identity.dart';
import 'package:retroshare/provider/Idenity.dart';
import '../common/color_loader_3.dart';

class CreateIdentityScreen extends StatefulWidget {
  CreateIdentityScreen({Key key, this.isFirstId = false}) : super(key: key);
  final isFirstId;

  @override
  _CreateIdentityScreenState createState() => _CreateIdentityScreenState();
}

class _CreateIdentityScreenState extends State<CreateIdentityScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController nameController = TextEditingController();
  File _image;
  String _imageBase64 = '';
  int _imageSize;
  bool _showError = false;
  bool _requestCreateIdentity = false;
  Animation<Color> _leftTabIconColor;
  Animation<Color> _rightTabIconColor;
  TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(vsync: this, length: 2, initialIndex: 0);
    _leftTabIconColor = ColorTween(begin: Color(0xFFF5F5F5), end: Colors.white)
        .animate(_tabController.animation);
    _rightTabIconColor = ColorTween(begin: Colors.white, end: Color(0xFFF5F5F5))
        .animate(_tabController.animation);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  _setImage(File image) {
    Navigator.pop(context);
    setState(() {
      if (image != null) {
        _image = image;
        _imageSize = image.readAsBytesSync().length;
        _imageBase64 = base64.encode(image.readAsBytesSync());
      }
    });
  }

  // Validate the Name
  bool _validate(text) {
    if (nameController.text.length < 3) {
      return false;
    }
    return true;
  }

  // Request create identity
  void _createIdentity() async {
    await Provider.of<Identities>(context, listen: false).createnewIdenity(
        Identity('', false, nameController.text, _imageBase64), _imageSize);
    widget.isFirstId
        ? Navigator.pushReplacementNamed(context, '/home')
        : Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(!widget.isFirstId);
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
                    Visibility(
                      visible: !widget.isFirstId,
                      child: Container(
                        width: personDelegateHeight,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            size: 25,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: widget.isFirstId
                                ? 16.0 + personDelegateHeight * 0.04
                                : 0.0),
                        child: Text(
                          'Create identity',
                          style: Theme.of(context).textTheme.body2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: (appBarHeight - 40) / 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      AnimatedBuilder(
                        animation: _tabController.animation,
                        builder: (BuildContext context, Widget widget) {
                          return GestureDetector(
                            onTap: () {
                              _tabController.animateTo(0);
                            },
                            child: Container(
                              width: 2 * appBarHeight,
                              decoration: BoxDecoration(
                                color: _leftTabIconColor.value,
                                borderRadius:
                                    BorderRadius.circular(appBarHeight / 2),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Center(
                                  child: Text(
                                    'Pseudo Identity',
                                    style: Theme.of(context).textTheme.body2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      AnimatedBuilder(
                        animation: _tabController.animation,
                        builder: (BuildContext context, Widget widget) {
                          return GestureDetector(
                            onTap: () {
                              _tabController.animateTo(1);
                            },
                            child: Container(
                              width: 2 * appBarHeight,
                              decoration: BoxDecoration(
                                color: _rightTabIconColor.value,
                                borderRadius:
                                    BorderRadius.circular(appBarHeight / 2),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: Center(
                                  child: Text(
                                    'Signed Identity',
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.body2,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                  child: TabBarView(controller: _tabController, children: [
                LayoutBuilder(
                  builder: (BuildContext context,
                      BoxConstraints viewportConstraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: viewportConstraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Center(
                            child: SizedBox(
                              width: 400,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  SizedBox(
                                    height: 20,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      imagePickerDialog(context, _setImage);
                                    },
                                    child: Container(
                                      height: 300 * 0.7,
                                      width: 300 * 0.7,
                                      decoration: _image == null
                                          ? null
                                          : BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      300 * 0.7 * 0.33),
                                              image: DecorationImage(
                                                fit: BoxFit.fitWidth,
                                                image: FileImage(_image),
                                              ),
                                            ),
                                      child: Visibility(
                                        visible: _imageBase64.isEmpty,
                                        child: Center(
                                          child: Icon(
                                            Icons.person,
                                            size: 300 * 0.7,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 50,
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
                                      child: TextField(
                                        controller: nameController,
                                        enabled: !_requestCreateIdentity,
                                        onChanged: (text) {
                                          setState(() {
                                            _showError = !_validate(text);
                                          });
                                        },
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            icon: Icon(
                                              Icons.person_outline,
                                              color: Color(0xFF9E9E9E),
                                              size: 22.0,
                                            ),
                                            hintText: 'Name'),
                                        style:
                                            Theme.of(context).textTheme.body2,
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: _showError,
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
                                                'Name too short',
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
                                  SizedBox(
                                    height: 20,
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
                LayoutBuilder(
                  builder: (BuildContext context,
                      BoxConstraints viewportConstraints) {
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
                                  SizedBox(
                                    height: 20,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      imagePickerDialog(context, _setImage);
                                    },
                                    child: Container(
                                      height: 300 * 0.7,
                                      width: 300 * 0.7,
                                      decoration: _image == null
                                          ? null
                                          : BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      300 * 0.7 * 0.33),
                                              image: DecorationImage(
                                                fit: BoxFit.fitWidth,
                                                image: FileImage(_image),
                                              ),
                                            ),
                                      child: Visibility(
                                        visible: _imageBase64.isEmpty,
                                        child: Center(
                                          child: Icon(
                                            Icons.person,
                                            size: 300 * 0.7,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 50,
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
                                      child: TextField(
                                        controller: nameController,
                                        enabled: !_requestCreateIdentity,
                                        onChanged: (text) {
                                          setState(() {
                                            _showError = !_validate(text);
                                          });
                                        },
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            icon: Icon(
                                              Icons.person_outline,
                                              color: Color(0xFF9E9E9E),
                                              size: 22.0,
                                            ),
                                            hintText: 'Name'),
                                        style:
                                            Theme.of(context).textTheme.body2,
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: _showError,
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
                                                'Name too short',
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
                                  SizedBox(
                                    height: 20,
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
              ])),
              Visibility(
                visible: !_requestCreateIdentity,
                child: BottomBar(
                  child: Center(
                    child: SizedBox(
                      height: 2 * appBarHeight / 3,
                      child: Builder(
                        builder: (context) => FlatButton(
                          onPressed: () {
                            setState(() {
                              _showError = !_validate(nameController.text);
                            });
                            if (!_showError) {
                              setState(() {
                                _requestCreateIdentity = true;
                              });
                              _createIdentity();
                            }
                          },
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
                              padding: const EdgeInsets.all(6.0),
                              child: Center(
                                child: Text(
                                  'Create Identity',
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
                ),
              ),
              Visibility(
                visible: _requestCreateIdentity,
                child: ColorLoader3(
                  radius: 15.0,
                  dotRadius: 6.0,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
