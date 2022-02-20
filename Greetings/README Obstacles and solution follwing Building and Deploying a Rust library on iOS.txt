Rust: trying to follow the link (https://mozilla.github.io/firefox-browser-architecture/experiments/2017-09-06-rust-on-ios.html)

path: RustInIOS/cargo
run: cargo build
Run: cargo lipo --release
Then the lib .a file is under RustInIOS/cargo/target/universal/release/libgreetings.a

--
1| add targets, but some are no longer supported
--


rustup target add aarch64-apple-ios armv7-apple-ios armv7s-apple-ios x86_64-apple-ios i386-apple-ios
info: component 'rust-std' for target 'aarch64-apple-ios' is up to date
error: component 'rust-std' for target 'armv7-apple-ios' is unavailable for download for channel stableIf you don't need the component, you can remove it with:

    rustup target remove --toolchain stable armv7-apple-ios


-----------------------------------
Solution:
rustup target add x86_64-apple-darwin aarch64-apple-darwin aarch64-apple-ios x86_64-apple-ios
-----------------------------------




--
2|
--


➜  cargo git:(master) ✗ cargo lipo --release
[ERROR cargo_lipo] cargo_metadata failed: error during execution of `cargo metadata`: error: failed to parse manifest at `/Users/meichen/Developer/greetings/cargo/Cargo.toml`

Caused by:
  can't find library `greetings`, rename file to `src/lib.rs` or specify lib.path

➜  cargo git:(master) ✗ mv src/main.rs src/lib.rs
➜  cargo git:(master) ✗ cargo lipo --release     
[INFO  cargo_lipo::meta] Will build universal library for ["greetings"]
[INFO  cargo_lipo::lipo] Building "greetings" for "aarch64-apple-ios"
   Compiling greetings v0.1.0 (/Users/meichen/Developer/greetings/cargo)
warning: dropping unsupported crate type `cdylib` for target `aarch64-apple-ios`

warning: 1 warning emitted

    Finished release [optimized] target(s) in 0.70s
[INFO  cargo_lipo::lipo] Building "greetings" for "x86_64-apple-ios"
   Compiling greetings v0.1.0 (/Users/meichen/Developer/greetings/cargo)
warning: dropping unsupported crate type `cdylib` for target `x86_64-apple-ios`

error[E0463]: can't find crate for `std`
  |
  = note: the `x86_64-apple-ios` target may not be installed

error: aborting due to previous error; 1 warning emitted

For more information about this error, try `rustc --explain E0463`.
error: could not compile `greetings`

To learn more, run the command again with --verbose.
[ERROR cargo_lipo] Failed to build "greetings" for "x86_64-apple-ios": Executing "/Users/meichen/.rustup/toolchains/stable-aarch64-apple-darwin/bin/cargo" "--color" "auto" "build" "-p" "greetings" "--target" "x86_64-apple-ios" "--release" "--lib" finished with error status: exit code: 101


-----------------------------------
Solved by earlier fix
-----------------------------------




--
3| build in xcode failed, after adding the class RustGreetings, which calls rust_greeting() and rust_greeting_free()
--


Ld /Users/meichen/Library/Developer/Xcode/DerivedData/Greetings-diinkkesxflakucajbfdvhmowgaw/Build/Products/Debug-iphonesimulator/Greetings.app/Greetings normal (in target 'Greetings' from project 'Greetings')
    cd /Users/meichen/Developer/greetings/Greetings
    /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang -target arm64-apple-ios14.0-simulator -isysroot /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/SDKs/iPhoneSimulator14.5.sdk -L/Users/meichen/Library/Developer/Xcode/DerivedData/Greetings-diinkkesxflakucajbfdvhmowgaw/Build/Products/Debug-iphonesimulator -L/Users/meichen/Developer/greetings/Greetings/../cargo/target/universal/release -F/Users/meichen/Library/Developer/Xcode/DerivedData/Greetings-diinkkesxflakucajbfdvhmowgaw/Build/Products/Debug-iphonesimulator -filelist /Users/meichen/Library/Developer/Xcode/DerivedData/Greetings-diinkkesxflakucajbfdvhmowgaw/Build/Intermediates.noindex/Greetings.build/Debug-iphonesimulator/Greetings.build/Objects-normal/arm64/Greetings.LinkFileList -Xlinker -rpath -Xlinker @executable_path/Frameworks -dead_strip -Xlinker -object_path_lto -Xlinker /Users/meichen/Library/Developer/Xcode/DerivedData/Greetings-diinkkesxflakucajbfdvhmowgaw/Build/Intermediates.noindex/Greetings.build/Debug-iphonesimulator/Greetings.build/Objects-normal/arm64/Greetings_lto.o -Xlinker -export_dynamic -Xlinker -no_deduplicate -Xlinker -objc_abi_version -Xlinker 2 -fobjc-link-runtime -L/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/iphonesimulator -L/usr/lib/swift -Xlinker -add_ast_path -Xlinker /Users/meichen/Library/Developer/Xcode/DerivedData/Greetings-diinkkesxflakucajbfdvhmowgaw/Build/Intermediates.noindex/Greetings.build/Debug-iphonesimulator/Greetings.build/Objects-normal/arm64/Greetings.swiftmodule -Xlinker -sectcreate -Xlinker __TEXT -Xlinker __entitlements -Xlinker /Users/meichen/Library/Developer/Xcode/DerivedData/Greetings-diinkkesxflakucajbfdvhmowgaw/Build/Intermediates.noindex/Greetings.build/Debug-iphonesimulator/Greetings.build/Greetings.app-Simulated.xcent -Xlinker -no_adhoc_codesign -Xlinker -dependency_info -Xlinker /Users/meichen/Library/Developer/Xcode/DerivedData/Greetings-diinkkesxflakucajbfdvhmowgaw/Build/Intermediates.noindex/Greetings.build/Debug-iphonesimulator/Greetings.build/Objects-normal/arm64/Greetings_dependency_info.dat -o /Users/meichen/Library/Developer/Xcode/DerivedData/Greetings-diinkkesxflakucajbfdvhmowgaw/Build/Products/Debug-iphonesimulator/Greetings.app/Greetings

Undefined symbols for architecture arm64:
  "_rust_greeting", referenced from:
      Greetings.RustGreetings.sayHello(to: Swift.String) -> Swift.String in RustGreetings.o
  "_rust_greeting_free", referenced from:
      Greetings.RustGreetings.sayHello(to: Swift.String) -> Swift.String in RustGreetings.o
ld: symbol(s) not found for architecture arm64
clang: error: linker command failed with exit code 1 (use -v to see invocation)


-----------------------------------
solution:
https://stackoverflow.com/questions/53796512/undefined-symbols-for-architecture-x86-64-i386/53801401

double click on project(the one with the blue icon) to open xcodeproj file, select in left panel: TARGETS/Greetings, in tab: Build Phases/Link Binary With Libraries, add cargo/target/universal/release/libgreetings.a (the file containing folder is added earlier in tab: Build Settings/Library Search Paths)
-----------------------------------




--
4| newer version xcode doesn't have a ViewController.swift file, can't put the test code in ContentView
--


Failed to build ContentView.swift
Type '()' cannot conform to 'View'



-----------------------------------
solution:
still put the test code in ContentView's body variable,
change from 

		let rustGreetings = RustGreetings()
		print("\(rustGreetings.sayHello(to: "world"))")

to

		let rustGreetings = RustGreetings()
        let text = "\(rustGreetings.sayHello(to: "world"))"
        Text(text)
            .padding()
-----------------------------------










