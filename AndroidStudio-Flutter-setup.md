# RS mobile: Setup Flutter|Android Studio build environment
## Windows
### Assumptions 
(These may be adapted to your needs.)

- Clean environment yet without any dart, flutter or android studio
- FlutterRoot: c:\
- FlutterDir:    $(FlutterRoot)\flutter
- AndroidStudioRoot: c:\
- AndroidStudioDir: $(AndroidStudioRoot)\AndroidStudio 
- RSMobileDir: c:\RS-Mobile

### Steps
#### Flutter installation
1. Download and install any flafour of git for windows.
   (see: https://flutter.dev/docs/get-started/install/windows#system-requirements)
1. Download Flutte stabler: https://flutter.dev/docs/get-started/install/windows#get-the-flutter-sdk
2. Open the zip-package and copy the contained flutter-Dir to FlutterRoot.
This results in the FlutterDir.
3. Add in environment variables for your account to the PATH-variable of USER context separated by ';' the explicit full path to flutter\bin: $(FlutterDir)\bin
   1. Test:   
     Start a cmd console  (in START/RUN type: cmd)
   1. type: flutter -h <return>'   
      fluuter should show you its help text if all is well until now.
1. in cmd type:  flutter doctor <return>
   - flutter chechs its environment and will most likely tell you, that
     - Android SDK is missing
     - Android Studio is missing
     - it may also query for chrome but this is not needed
#### Android Studio installation
1. install Android Studio for windows: https://developer.android.com/studio
   - follow the default setting and ensure the installation is done to  AndroidStudioDir
1. After installation start Android Studio and let it update if it queries for some
2. press NEXT-buttons until it is no longer shown
3. press FINISH and folloow until finish
4. On Wellcome-Page go into plugins and
  - install dart and flutter and let AS restart
1. On Welcome page select projects: More Action/SDK Manager and than Tab SDK-Tools.
   - Ensure alls "Android SDK"* Entries are installed and especially
   - ensure "Android SDK command line tools" to be installed
1. Close the SDK Dialog
2. If you wish to use simulated mobiles you may later select in "more actions" AVD Manager and create emulated devices as you need.
#### Associate Flutter and Android Studio
3. tell Flutter wher to find AS:    
   in cmd console type:  
   flutter config --android-studio-dir "$(AndroidStudioDir)".  
   The quotes are mandatory if the path conataisn for exc. BLANKs
1. now you need to acceps the sdk licenses:  
   in md type:  
   flutter doctor --android-licenses  
   and accept all.
#### final check of flutter installation
1. In new cmd-console type:  
flutter doctor   
it should now tell all (but maybe chrome) is OK.
# RS mobile: Prepare project
2. Git: clone RS mobile locally as RSMobileDir  
(https://github.com/RetroShare/retroshare-mobile)
3. Open a cmd window (type cmd in START)
4. change directory into RS mobile dir
5. type:  
flutter pub get<return>
to update the flutter package dependancies as need in the project.
6. maybe: open the RSMobileDir  in Android Studio
# Activate USB Debug Mode of the mobile
7. in settings type usb in search
8. select usb-debugging
9. activate it
10. plug the mobile with usb to the pc
11. if this is the frist time a dialog appears to accepts the key
12. check in cmd console if the device is available
    1. cmd: flutter devices<return> should no list your mobile as availabel 
# Run the apk on mobile
1. load the service apk to the mobile and start it
2. cmd: flutter run [[--release]]<return>  
without release it gets run in debug mode