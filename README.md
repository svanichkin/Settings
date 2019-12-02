# Settings
Settings is a class that allows you to work immediately with all local storage systems in a simple and convenient wrapper.

Under the hood, work with NSUserDefaults (locally and with AppGroups), NSUbiquitousKeyValueStore, Keychain.

Keychain storage:
```
[Settings.keychain setObject:@"12345" forKey:@"Password"];
```

Sharing between applications on device, or plugins on application:
```
Settings.deviceAppGroup = @"group.com.application.test";
[Settings.device setObject:@"TestDeviceAndPluginsSharing" forKey:@"TestKey"];
```

Local storage:
```
[Settings.application setObject:@"LocalData" forKey:@"LocalTestKey"];
```

All user devices sharing:
```
[Settings.all setObject:@"AllUserDevicesData" forKey:@"AllKey"];
``` 

"all" saves keys in Key-Value Storage, which should be included in the target, you must also specify the name of the group in entitlements.

sample:
```
<key>com.apple.developer.ubiquity-kvstore-identifier</key>
<string>9T111111W8.com.project.AppName</string>
```

9T111111W8 - team id
