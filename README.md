# LolaDrivesIOS
This is the iOS version of LolaDrives, an app for conducting RDE tests and live monitoring to measure car emissions. 

# How to use
Plug an OBD-II adapter into the car's OBD-II port, and connect your iPhone with the adapter via Bluetooth, 
then follow the instructions in the App.

# More info
For more information on background, scientific paper, how to use, please visit https://www.loladrives.app/

# Frameworks

LolaDrives for iOS uses the following frameworks:

- LTSupportAutomotive (Objective-C) https://github.com/mickeyl/LTSupportAutomotive

  It handles bluetooth, sending OBD commands and receiving OBD responses.
  
  Import to LolaDrives: See instructions of the README page in LTSupportAutomotive.

- PCDFCore (Kotlin) https://github.com/udsdepend/pcdf-core
  
  It handles serialization and deserialization between ppcdf file in json format and PCDFCore objects, eg. PCDFEvent
  
  Import to LolaDrives: 
  
    - Specify the correct target architecture in *build.gradle* of the PCDFCore project, eg. to generate the pcdfcore framework for apple M1:
  
      ```
      iosArm64("native") {
          binaries {
              framework {
                  baseName = "pcdfcore"
              }
          }
      }
      ```
    - Then run
      ```
      .\gradlew linkNative
      ```
      to generate the framework.
    
    - Finally import the framework *build/bin/native/releaseFramework/pcdfcore.framework* to XCode: TARGETS, General tab, Frameworks, Libraries, and Embedded Content.
  
- RTLola (Rust) https://www.react.uni-saarland.de/tools/rtlola/
  
  It defines input streams and how to calculate output streams in the lola specification file (*.lola). 
  Given the inputs this project, such as speed, temperature, altitude, NOx, etc, which are collected from the OBD-II adapter,
  RTLola can output whether the test drive performs a valid RDE test, NOx amount in different sections (urban, rural, motorway), etc.
  Developers can customize the input and output in the lola specification file to get more insight.
  
  Import to LolaDrives: 
  - Write a Foreign Function Interface (https://github.com/mailein/LolaDrivesIOS/blob/main/cargo/src/lib.rs) for the RTLola bridge (https://github.com/mailein/LolaDrivesIOS/blob/main/cargo/src/bridge.rs)
  
  - Then run 
    ```
    cargo lipo --release
    ```
    to generate the RTLola framework.
  
  - Finally import the framework *cargo/target/universal/release/libLolaDrives.a* to XCode: TARGETS, General tab, Frameworks, Libraries, and Embedded Content.
  
- Charts (Swift) https://github.com/danielgindi/Charts

  It can draw charts. (Apple hasn't released the stable version of Swift Charts by the time of the LolaDrives for iOS project)
  
  Import to LolaDrives: See instructions of the README page in Charts.
  
