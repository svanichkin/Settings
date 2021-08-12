<<<<<<< HEAD
# Alert
Alert - this is a simple class for displaying an alert from anywhere in your application (iOS and macOS)

This library works on many projects such as Mubert, Morse, etc. Top of App Store.

Easy to use:
```
[Alert
 showWithTitle:@"Title"
 message:@"Text"
 buttons:@[@"Delete".destructiveStyle],
           @"OK",
           @"Cancel".cancelStyle]
 handler:^(NSInteger buttonIndex)
 {
     if (buttonIndex == 0)
     {
        // Delete
     }
 }];
 
 NSError *error = nil;
 ...
 if (error)
     [error show];
```  

All button names indicated in English are automatically translated from the system. Or they are looking for a translation in the application localization files. For example, “Cancel” will be translated automatically, and “MyButtonName” will search for a translation in the application localization file.

For an AppKit application, translation will always be in the application localization file.

The class itself defines the top controller for display. Enjoy.
=======
# Settings
Settings is a class that allows you to work immediately with all local storage systems in a simple and convenient wrapper.

This library works on many projects such as Mubert, Morse, etc. Top of App Store.

Under the hood, work with NSUserDefaults (locally and with AppGroups), NSUbiquitousKeyValueStore, Keychain.

Keychain storage:
```
Settings.keychain[@"MyLogin"] = @"MyPassword";

NSString *myPassword = Settings.keychain[@"MyLogin"]
```

Sharing between applications on device, or plugins on application:
```
Settings.deviceAppGroup = @"group.com.application.test";
Settings.device[@"TestKey"] = @"TestDeviceAndPluginsSharing";
```

Local storage:
```
Settings.application[@"LocalTestKey"] = @"LocalData";
```

All user devices sharing:
```
Settings.all[@"AllKey"] = @"AllUserDevicesData";
``` 

"all" saves keys in Key-Value Storage, which should be included in the target, you must also specify the name of the group in entitlements.

sample:
```
<key>com.apple.developer.ubiquity-kvstore-identifier</key>
<string>9T111111W8.com.project.AppName</string>
```

9T111111W8 - team id
>>>>>>> 95b1f1f2a9679ae2e0d5eaa8d39daea1334a9c9a
