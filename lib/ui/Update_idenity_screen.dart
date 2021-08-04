import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/image_picker_dialog.dart';
import 'package:retroshare/common/show_dialog.dart';
import 'dart:convert';
import 'package:retroshare/common/styles.dart';
import 'package:retroshare/common/bottom_bar.dart';
import 'package:retroshare/model/identity.dart';
import 'package:retroshare/provider/Idenity.dart';
import '../common/color_loader_3.dart';

class UpdateIdentityScreen extends StatefulWidget {
  final curr;
  UpdateIdentityScreen({this.curr});
  @override
  _UpdateIdentityScreenState createState() => _UpdateIdentityScreenState();
}

class _UpdateIdentityScreenState extends State<UpdateIdentityScreen> {
  TextEditingController nameController = TextEditingController();
  RsGxsImage _image;
  bool _showError = false;
  bool _requestCreateIdentity = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController = TextEditingController(text: widget.curr.name);
    if (widget.curr.avatar != null)
      _image = new RsGxsImage(base64.decode(widget.curr.avatar));
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  _setImage(File image) async {
    Navigator.pop(context);
    setState(() {
      if (image != null) {
        _image = new RsGxsImage(image.readAsBytesSync());
      }
    });
  }

  // Validate the Name
  bool _validate(text) {
    return nameController.text.length < 3 ? false : true;
  }

  @override
  Widget build(BuildContext context) {
    // Request create identity
    void _updateIdentity() async {
      bool success = await Provider.of<Identities>(context, listen: false)
          .updateIdentity(
              Identity(widget.curr.mId, widget.curr.signed, nameController.text,
                  _image?.base64String),
              _image);
      if (success)
        Navigator.pop(context);
      else {
        setState(() {
          _requestCreateIdentity = false;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Constants.padding),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: contentBox(context),
            );
          },
        );
      }
    }

    return WillPopScope(
      onWillPop: () {
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
                    Visibility(
                      visible: true,
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
                        padding: EdgeInsets.symmetric(horizontal: 0.0),
                        child: Text(
                          'Update identity',
                          style: Theme.of(context).textTheme.body2,
                        ),
                      ),
                    ),
                    Spacer(),
                    PopupMenuButton(
                      onSelected: (val) {
                        showdeleteDialog(context);
                      },
                      icon: Icon(Icons.more_vert),
                      itemBuilder: (BuildContext context) {
                        return [
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(children: [
                              Icon(
                                Icons.delete,
                                size: 20,
                              ),
                              SizedBox(
                                width: 7,
                              ),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  fontSize: 12,
                                ),
                              )
                            ]),
                          ),
                        ];
                      },
                    ),
                    SizedBox(width: 10),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
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
                                      decoration: _image?.mData == null
                                          ? null
                                          : BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      300 * 0.7 * 0.33),
                                              image: DecorationImage(
                                                fit: BoxFit.fitWidth,
                                                image:
                                                    MemoryImage(_image.mData),
                                              ),
                                            ),
                                      child: Visibility(
                                        visible: _image != null
                                            ? _image?.mData?.isEmpty
                                            : true,
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
              ),
              Visibility(
                visible: !_requestCreateIdentity,
                child: BottomBar(
                  child: Center(
                    child: SizedBox(
                      height: 2 * appBarHeight / 3,
                      child: Builder(
                        builder: (context) => FlatButton(
                          onPressed: () async {
                            setState(() {
                              _showError = !_validate(nameController.text);
                            });
                            if (!_showError) {
                              setState(() {
                                _requestCreateIdentity = true;
                              });

                              await _updateIdentity();
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
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                'Update Identity',
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
