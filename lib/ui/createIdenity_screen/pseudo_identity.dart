import 'dart:async';
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
  const PseudoSignedIdenityTab(this.isFirstId, this.key);
  final bool isFirstId;
  @override
  final Key key;

  @override
  _PseudoSignedIdenityTabState createState() => _PseudoSignedIdenityTabState();
}

class _PseudoSignedIdenityTabState extends State<PseudoSignedIdenityTab> {
  bool _pseduorequestCreateIdentity = false;
  TextEditingController pseudosignednameController = TextEditingController();
  late RsGxsImage _image;

  bool _showError = false;
  void _setImage(File image) {
    Navigator.pop(context);
    setState(() {
      _image = RsGxsImage(image.readAsBytesSync());
        });
  }

  bool _validate(text) {
    return pseudosignednameController.text.length < 3 ? false : true;
  }

  Future<void> _createIdentity() async {
    await Provider.of<Identities>(context, listen: false)
        .createnewIdenity(
            Identity('', false, pseudosignednameController.text,
                _image.base64String,),
            _image,)
        .then((value) {
      widget.isFirstId
          ? Navigator.pushReplacementNamed(context, '/home')
          : Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            IntrinsicHeight(
              child: Center(
                child: SizedBox(
                  width: 300,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          imagePickerDialog(context, _setImage);
                        },
                        child: Container(
                          height: 300 * 0.7,
                          width: 300 * 0.7,
                          decoration: _image.mData == null
                              ? null
                              : BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(300 * 0.7 * 0.33),
                                  image: DecorationImage(
                                    fit: BoxFit.fitWidth,
                                    image: MemoryImage(_image.mData),
                                  ),
                                ),
                          child: Visibility(
                            visible:
                                _image != null ? _image.mData.isEmpty : true,
                            child: const Center(
                              child: Icon(
                                Icons.person,
                                size: 300 * 0.7,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: const Color(0xFFF5F5F5),
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
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              icon: Icon(
                                Icons.person_outline,
                                color: Color(0xFF9E9E9E),
                                size: 22.0,
                              ),
                              hintText: 'Name',
                            ),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: _showError,
                        child: const SizedBox(
                          width: double.infinity,
                          child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: 52,
                              ),
                              SizedBox(
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
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            Visibility(
              visible: !_pseduorequestCreateIdentity,
              child: BottomBar(
                child: Center(
                  child: SizedBox(
                    height: 2 * appBarHeight / 3,
                    child: Builder(
                      builder: (context) => TextButton(
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
                        // padding: const EdgeInsets.symmetric(
                        //     horizontal: 16.0 + personDelegateHeight * 0.04,),
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
                            padding: const EdgeInsets.all(6.0),
                            child: Center(
                              child: Text(
                                'Create Identity',
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
              ),
            ),
          ],
        ),
        Visibility(
          visible: _pseduorequestCreateIdentity,
          child: const Center(
            child: ColorLoader3(
              radius: 15.0,
              dotRadius: 6.0,
            ),
          ),
        ),
      ],
    );
  }
}
