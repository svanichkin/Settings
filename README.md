[![SPM supported](https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat)](https://swift.org/package-manager)
[![Version](https://img.shields.io/cocoapods/v/KeychainAccess.svg)](http://cocoadocs.org/docsets/KeychainAccess)
[![Platform](https://img.shields.io/cocoapods/p/KeychainAccess.svg)](http://cocoadocs.org/docsets/KeychainAccess)
# Settings
Settings is a class that allows you to work immediately with all local storage systems in a simple and convenient wrapper.

This library works on many projects such as Mubert, Morse, etc. Top of App Store.

Under the hood, work with NSUserDefaults (locally and with AppGroups), NSUbiquitousKeyValueStore, NSKeychain with Share.

Sample 1:

Save and load "Test" string to key with "TestKey" name
this sample for local settings on current application

Objective-C

In app1 on user iphone
```
Settings.application[@"TestKey"] = @"Test";
```

In app1 on user iphone
```
NSString *s = Settings.application[@"TestKey"];
```

Swift

In app1 on user iphone
```
Settings.application["TestKey"] = "Test"
```

In app1 on user iphone
```
let s = Settings.application["TestKey"]
```

Sample 2:

Save and load "Test" string to key with "TestKey" name
this sample for local settings between one or more applications

Go to Capability -> App Groups and Add new (group.com.application.test)

Objective-C

In app1 on user iphone
```
Settings.device[@"TestKey"] = @"Test";
```

In app2 OR app1 extention user iphone
```
Settings.deviceAppGroup = @"group.com.application.test";
NSString *s = Settings.device[@"TestKey"];
```

Swift

In app1 on user iphone
```
Settings.device["TestKey"] = "Test"
```

In app2 OR app1 extention user iphone
```
Settings.deviceAppGroup = "group.com.application.test"
let s = Settings.device["TestKey"]
```


Sample 3:

Save and load "Test" string to key with "TestKey" name
this sample for global settings between one or more user devices
and current application (sync with iCloud)

Capability -> iCloud -> Enable Key-Value storage

This action add string
"<key>com.apple.developer.ubiquity-kvstore-identifier</key>" to
entitlements project file "iCloud Key-Value Store"
value for this key is "$(TeamIdentifierPrefix)$(CFBundleIdentifier)"
sample somthing this: "9T111111W8.myOrganization.myProducName"

Objective-C

In app1 on user iphone
```
Settings.all[@"TestKey"] = @"Test";
```

In app1 on user ipad
```
NSString *s = Settings.all[@"TestKey"];
```

Swift

In app1 on user iphone
```
Settings.all["TestKey"] = "Test"
```

In app1 on user ipad
```
let s = Settings.all["TestKey"]
```


Sample 4:

Save and load "Test" string to key with "TestKey" name
this sample for global settings between one or more user devices and
between one or more application (sync with iCloud)

Capability -> iCloud -> Enable Key-Value storage

This action add string
"<key>com.apple.developer.ubiquity-kvstore-identifier</key>" to
entitlements project file "iCloud Key-Value Store"
value for this key is "$(TeamIdentifierPrefix)$(CFBundleIdentifier)"
sample somthing this id: "9T111111W8.myOrganization.myProducName"

Objective-C

In app1 on user iphone
```
NSString *idApp1 = Settings.deviceGroupId;
Settings.all[@"TestKey"] = @"Test";
```

In app2 on user ipad
Add Capability -> iCloud -> Enable Key-Value storage
Replace in entitlements id to (9T111111W8.myOrganization.myProducName)
```
NSString *idApp2 = Settings.deviceGroupId; // idApp1 == idApp2
NSString *s = Settings.all[@"TestKey"];
```

Swift

In app1 on user iphone
```
let idApp1 = Settings.deviceGroupId;
Settings.all["TestKey"] = "Test"
```

In app2 on user ipad
Add Capability -> iCloud -> Enable Key-Value storage
Replace in entitlements id to (9T111111W8.myOrganization.myProducName)
```
let idApp2 = Settings.deviceGroupId // idApp1 == idApp2
let s = Settings.all["TestKey"]
```


Sample 5:

Save and load "Test" string to key with "TestKey" name
this sample for local keychain without iCloud sync

Objective-C

In app1 on user iphone
```
Settings.keychainLocal[@"TestKey"] = @"Test";
```

In app1 on user ipad
```
NSString *s = Settings.keychainLocal[@"TestKey"];
```

Swift

In app1 on user iphone
```
Settings.keychainLocal["TestKey"] = "Test"
```

In app1 on user ipad
```
let s = Settings.keychainLocal["TestKey"]
```


Sample 6:

Save and load "Test" string to key with "TestKey" name
this sample for global keychain on all user devices with iCloud sync

Capability -> Keychain Sharing

Objective-C

In app1 on user iphone
```
Settings.keychain[@"TestKey"] = @"Test";
```

In app1 on user ipad
```
NSString *s = Settings.keychain[@"TestKey"];
```

Swift

In app1 on user iphone
```
Settings.keychain["TestKey"] = "Test"
```

In app1 on user ipad
```
let s = Settings.keychain["TestKey"]
```


Sample 7:

Save and load "Test" string to key with "TestKey" name
this sample for global keychain on all user devices between applications with iCloud sync

Capability -> Keychain Sharing -> Add new group (my.testingKeychain)

Objective-C

In app1 on user iphone
```
Settings.keychainShare[@"TestKey"] = @"Test";
```

In app2 on user ipad
Add Capability -> Keychain Sharing -> Add new group (my.testingKeychain)
or
Add Capability -> Keychain Sharing and add new group over code
```
Settings.keychainGroupId = @"my.testingKeychain";
```
Then read value
```
NSString *s = Settings.keychainShare[@"TestKey"];
```

Swift

In app1 on user iphone
```
Settings.keychainShare["TestKey"] = "Test"
```

In app2 on user ipad
Add Capability -> Keychain Sharing -> Add new group (my.testingKeychain)
or
Add Capability -> Keychain Sharing and add new group over code
```
Settings.keychainGroupId = "my.testingKeychain"
```
Then read value
```
let s = Settings.keychainShare["TestKey"]
```