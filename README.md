# Settings
Settings is a class that allows you to work immediately with all local storage systems in a simple and convenient wrapper.

This library works on many projects such as Mubert, Morse, etc. Top of App Store.

Under the hood, work with NSUserDefaults (locally and with AppGroups), NSUbiquitousKeyValueStore, Keychain.

Sample 1:

Save and load "Test" string to key with "TestKey" name
this sample for local settings on current application

In app1 on user iphone
```
[Settings.application setObject:@"Test" forKey:@"TestKey"];
```

In app1 on user iphone
```
NSString *s = [Settings.application objectForKey:@"TestKey"];
```


Sample 2:

Save and load "Test" string to key with "TestKey" name
this sample for local settings between one or more applications

Go to Capability -> App Groups and Add new (group.com.application.test)

In app1 on user iphone
```
[Settings.device setObject:@"Test" forKey:@"TestKey"];
```

In app2 OR app1 extention user iphone
```
Settings.deviceAppGroup = @"group.com.application.test";
NSString *s = [Settings.device objectForKey:@"TestKey"];
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

In app1 on user iphone
```
[Settings.all setObject:@"Test" forKey:@"TestKey"];
```

In app1 on user ipad
```
NSString *s = [Settings.all objectForKey:@"TestKey"];
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

In app1 on user iphone
```
NSString *myIdInApp1 = Settings.deviceGroupId;
[Settings.all setObject:@"Test" forKey:@"TestKey"];
```

In app2 on user ipad
Add Capability -> iCloud -> Enable Key-Value storage
Replace in entitlements id to (9T111111W8.myOrganization.myProducName)
```
NSString *myIdInApp2SameApp1 = Settings.deviceGroupId;
NSString *s = [Settings.all objectForKey:@"TestKey"];
```


Sample 5:

Save and load "Test" string to key with "TestKey" name
this sample for local keychain without iCloud sync

In app1 on user iphone
```
[Settings.keychainLocal setObject:@"Test" forKey:@"TestKey"];
```

In app1 on user ipad
```
NSString *s = [Settings.keychainLocal objectForKey:@"TestKey"];
```


Sample 6:

Save and load "Test" string to key with "TestKey" name
this sample for global keychain on all user devices with iCloud sync

Capability -> Keychain Sharing

In app1 on user iphone
```
[Settings.keychain setObject:@"Test" forKey:@"TestKey"];
```

In app1 on user ipad
```
NSString *s = [Settings.keychain objectForKey:@"TestKey"];
```


Sample 7:

Save and load "Test" string to key with "TestKey" name
this sample for global keychain on all user devices between applications with iCloud sync

Capability -> Keychain Sharing -> Add new group (my.testingKeychain)

In app1 on user iphone
```
[Settings.keychainShare setObject:@"Test" forKey:@"TestKey"];
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
NSString *s = [Settings.keychainShare objectForKey:@"TestKey"];
```