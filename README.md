# RetroShare Flutter App

RetroShare mobile client written in Flutter.

This is a Flutter frontend for the retroshare-service backend. You need to have **both working**: this frontend, and the 
retroshare-service backend.

## Features

* Create one or more Retroshare profiles.
* Create and delete one or more Identities, and switch between them.
* Add friend locations using classic Retroshare invites.
* Create lobby chats (public and private).
* Search public chat lobbies.
* Start distant chats with identities.
* Native notifications for new messages.

On the future we plan to give support to Retroshare forums. 

Check https://gitlab.com/b1rdG/retroshare-android-flutter-app/-/issues to see missing and planned features or improvements. 
Write there if you find a bug or you think a feature is missing.

## Install the frontend

* Just clone this repo and do a `pub get` and then `flutter run`. 
* Or else download debug apk [here](https://gitlab.com/b1rdG/retroshare-android-apks).

## Get the backend

* From Retroshare Channel: [RetroShare Android builds by G10h4ck][rschannel].
* Download release [here](https://gitlab.com/b1rdG/retroshare-android-apks).
* Debug: using adb to use a retroshare-service installed on your computer:

```bash
adb reverse tcp:9092 tcp:9092
```

## Bundle front end and backend in the same apk

You can bundle both apk on the same apk. Check https://gitlab.com/b1rdG/retroshare-android-flutter-app/-/issues/13 for 
more info.

# Acknowledgements

This program is developed from [GSoC2019][GSoC2019] code, thanks to [@kdebiec][kdebiec] for it. 

Thanks to the [API wrapper][openapi] generated automatically using the [API wrapper generator][wrappergenerator].

Obviously thanks to RetroShare community to make this possible.

PS: just a little warning. You will find some code inconsistencies: [flutter redux][redux] is partially implemented, sometimes you will see 
API calls on `redux_middleware` and sometimes on `services/` folder. Also, sometimes the API is called using the 
[API wrapper][openapi] and others using dart `http` calls. This is because new technologies were implemented after some
part of the code was already written, which is not yet adapted to those... 

What a mess, right? We hope to have more contributors soon to fix this disorder. 


[GSoC2019]: https://github.com/kdebiec/GSoC_2019

[openapi]: https://gitlab.com/jpascualsana/openapi-dart-retroshare-api-wrapper

[wrappergenerator]: https://gitlab.com/jpascualsana/retroshare-api-wrapper-generator

[rschannel]: retroshare://channel?name=RetroShare%20Android%20builds%20by%20G10h4ck%20_repo&id=e78125439fff723b3b15bb77b8f25dba

[kdebiec]: https://github.com/kdebiec

[redux]: https://pub.dev/packages/flutter_redux
