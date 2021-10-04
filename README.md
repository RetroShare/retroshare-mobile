<div align="center">
<p align="center"><img src="assets/rs-logo.png" width="400"></p> 
</div> 


# RetroShare Mobile App.

[![style: lint](https://img.shields.io/badge/style-lint-4BC0F5.svg)](https://pub.dev/packages/lint)

RetroShare mobile client written in Flutter.

This is a Flutter frontend for the retroshare-service backend. You need to have **both working**: this frontend, and the 
retroshare-service backend.

## Features

* Create one or more Retroshare profiles.
* Create and delete one or more  both Pseudo and Signed Identities, and switch between them.
* Add friend locations using classic and Short  Retroshare invites.
* Add Friend through QR scanner/QR code.
* Create lobby chats (public and private).
* Search public chat lobbies.
* Start distant chats with identities.
* Send Image and Emoji in chat.
* Get Notification of Chat Lobby Invites.
* Flexibility to accept and deny the chat lobby invites.

## Future Plans 

* Converting retroshare service (a.k.a backend of retroshare Mobile) from  background to foreground service.
* Adding Forum support.
* Support of CI/CD.

## Installing on Local Machine:

* Download [Qt 5.12.5](https://www.qt.io/blog/qt-5.12.5-released).
* Add the Android  dependencies `Android x86` , `Android ARM64-v8a` and `Android ARMv7` using QT maintainer tool.
* Add the `Qt 5.12.5` location in `retroshare-service.properties.example` file in `qt.installdir`.
* Run below command:
```bash
  cd android
  cp retroshare-service.properties.example retroshare-service.properties
  cd ..
  flutter run
```
* Follow these [steps](https://github.com/RetroShare/retroshare-mobile/blob/master/AndroidStudio-Flutter-setup.md)  for more Info.

## Code linting and formatting
Don't forget to format the code before creating a PR. Run the below command to check your code is formatted or not.
``` bash
flutter format .
```


## Contributing
Please read [Contributing.md](https://github.com/RetroShare/retroshare-mobile/blob/master/Contribution.md) for details on our code of conduct and the process for submitting pull requests to us.
 
## Support
Join our [Retroshare](https://github.com/RetroShare/RetroShare/releases) to talk to dev/tester of this project.
