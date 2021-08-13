import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:retroshare/common/bottom_bar.dart';
import 'package:retroshare/common/color_loader_3.dart';
import 'package:retroshare/common/image_picker_dialog.dart';
import 'package:retroshare/common/styles.dart';

import 'package:retroshare/provider/Idenity.dart';
import 'package:retroshare_api_wrapper/retroshare.dart';

class PseudoSignedIdenityTab extends StatefulWidget {
  final isFirstId;
  final key;
  PseudoSignedIdenityTab(this.isFirstId, this.key);
  @override
  _PseudoSignedIdenityTabState createState() => _PseudoSignedIdenityTabState();
}

class _PseudoSignedIdenityTabState extends State<PseudoSignedIdenityTab> {
  bool _pseduorequestCreateIdentity = false;
  TextEditingController pseudosignednameController = TextEditingController();
  RsGxsImage _image;

  bool _showError = false;
  _setImage(File image) {
    Navigator.pop(context);
    setState(() {
      if (image != null) {
        _image = new RsGxsImage(image.readAsBytesSync());
      }
    });
  }

  bool _validate(text) {
    return pseudosignednameController.text.length < 3 ? false : true;
  }

  void _createIdentity() async {
    await Provider.of<Identities>(context, listen: false).createnewIdenity(
        Identity(
            '', false, pseudosignednameController.text, _image?.base64String),
        _image);
    widget.isFirstId
        ? Navigator.pushReplacementNamed(context, '/home')
        : Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Column(
        children: [
          IntrinsicHeight(
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
                                    BorderRadius.circular(300 * 0.7 * 0.33),
                                image: DecorationImage(
                                  fit: BoxFit.fitWidth,
                                  image: MemoryImage(_image?.mData),
                                ),
                              ),
                        child: Visibility(
                          visible:
                              _image != null ? _image?.mData?.isEmpty : true,
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
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        height: 40,
                        child: TextField(
                          controller: pseudosignednameController,
                          enabled: !_pseduorequestCreateIdentity,
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
                          style: Theme.of(context).textTheme.body2,
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
          Spacer(),
          Visibility(
            visible: !_pseduorequestCreateIdentity,
            child: BottomBar(
              child: Center(
                child: SizedBox(
                  height: 2 * appBarHeight / 3,
                  child: Builder(
                    builder: (context) => FlatButton(
                      onPressed: () {
                        setState(() {
                          _showError =
                              !_validate(pseudosignednameController.text);
                        });
                        if (!_showError) {
                          setState(() {
                            _pseduorequestCreateIdentity = true;
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
        ],
      ),
      Visibility(
        visible: _pseduorequestCreateIdentity,
        child: Center(
          child: ColorLoader3(
            radius: 15.0,
            dotRadius: 6.0,
          ),
        ),
      )
    ]);
  }
}
