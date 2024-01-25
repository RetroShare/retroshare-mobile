import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:retroshare/common/button.dart';

Future imagePickerDialog(BuildContext context, Function callback,
    {double maxWidth = 1200.0, double maxHeight = 1200.0,}) async {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: const Text('From where do you want to take the photo?'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Button(
                      name: 'Gallery',
                      buttonIcon: Icons.photo_library,
                      onPressed: () async =>
                          callback(await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                            maxHeight: 250,
                            imageQuality: 10,
                            maxWidth: 250,
                          ),),),
                  const Padding(padding: EdgeInsets.all(8.0)),
                  GestureDetector(
                    child: Button(
                        name: 'Camera',
                        buttonIcon: Icons.camera_alt,
                        onPressed: () async => callback(
                              await ImagePicker().pickImage(
                                  source: ImageSource.camera,
                                  maxWidth: 250,
                                  imageQuality: 10,
                                  maxHeight: 250,),
                            ),),
                  ),
                ],
              ),
            ),);
      },);
}
