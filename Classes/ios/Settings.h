//
//  Settings.h
//  v.4.0
//
//  Created by Sergey Vanichkin on 19.08.16.
//  Copyright © 2016 Sergey Vanichkin. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//
//  Sample 1
//  Save and load "Test" string to key with "TestKey" name
//  this sample for local settings on current application
//
//  in app1 on user iphone
//  [Settings.application setObject:@"Test" forKey:@"TestKey"];
//
//  in app1 on user iphone
//  NSString *s = [Settings.application objectForKey:@"TestKey"];
//
//
//  Sample 2
//  Save and load "Test" string to key with "TestKey" name
//  this sample for local settings between one or more applications
//
//  Go to Capability -> App Groups and Add new
//
//  in app1 on user iphone
//  [Settings.device setObject:@"Test" forKey:@"TestKey"];
//
//  in app2 OR app1 extention user iphone
//  NSString *s = [Settings.device objectForKey:@"TestKey"];
//
//
//  Sample 3
//  Save and load "Test" string to key with "TestKey" name
//  this sample for global settings between one or more user devices
//  and current application (sync with iCloud)
//
//  Capability -> iCloud -> Key-Value storage and Enable
//
//  in app1 on user iphone
//  [Settings.all setObject:@"Test" forKey:@"TestKey"];
//
//  in app1 on user ipad
//  NSString *s = [Settings.all objectForKey:@"TestKey"];
//
//
//  Sample 4
//  Save and load "Test" string to key with "TestKey" name
//  this sample for global settings between one or more user devices and
//  between one or more application (sync with iCloud)
//
//  Capability -> iCloud -> Enable Key-Value storage
//
//  This action add string
//  "<key>com.apple.developer.ubiquity-kvstore-identifier</key>" to
//  entitlements project file "iCloud Key-Value Store"
//  value for this key is "$(TeamIdentifierPrefix)$(CFBundleIdentifier)"
//  sample somthing this: "9T111111W8.myOrganization.myProducName"
//  add this key to entitlements in other your app for sharing
//
//  in app1 on user iphone
//  [Settings.all setObject:@"Test" forKey:@"TestKey"];
//
//  in app2 on user ipad
//  NSString *s = [Settings.all objectForKey:@"TestKey"];
//
//
//  Sample 5
//  Save and load "Test" string to key with "TestKey" name
//  this sample for global keychain on all user devices with iCloud sync
//
//  Capability -> Keychain Sharing
//
//  in app1 on user iphone
//  [Settings.keychain setObject:@"Test" forKey:@"TestKey"];
//
//  in app1 on user ipad
//  NSString *s = [Settings.keychain objectForKey:@"TestKey"];
//
//
//  Sample 6
//  Save and load "Test" string to key with "TestKey" name
//  this sample for global keychain on all user devices between applications with iCloud sync
//
//  Capability -> Keychain Sharing -> Add new group
//
//  in app1 on user iphone
//  [Settings.keychainShare setObject:@"Test" forKey:@"TestKey"];
//
//  in app2 on user ipad
//  NSString *s = [Settings.keychainShare objectForKey:@"TestKey"];


#import <Foundation/Foundation.h>

#define APP_DATA_CHANGED @"AppDataChanged"
#define DEV_DATA_CHANGED @"DevDataChanged"
#define ALL_DATA_CHANGED @"AllDataChanged"

typedef enum
{
    SettingsTypeApplication,   // NSUserDefaults
    SettingsTypeDevice,        // NSUserDefault with group id
    SettingsTypeAll,           // NSUbiquitousKeyValueStore (need enable iCloud Key-Value)
    SettingsTypeKeychainLocal, // Keychain without iCloud sync
    SettingsTypeKeychain,      // Keychain with iCloud sync (need enable Keychain Share)
    SettingsTypeKeychainShare  // Keychain with iCloud sync and share group
} SettingsType;

@class SettingsProxy;

@interface Settings : NSObject

// Capability -> App Groups
// Sharing between applications on one device OR
// Sharing between app and extention with one app group id
+(NSString *)deviceGroupId;
+(void)setDeviceGroupId:(NSString *)appGroup;
                                    
// Capability -> iCloud -> Key-Value storage and Enable it then
// add to entitlement key
// "<key>com.apple.developer.ubiquity-kvstore-identifier</key>"
// "$(TeamIdentifierPrefix)$(CFBundleIdentifier)"
//  sample somthing this: "9T111111W8.myOrganization.myProducName"
//  add this key to entitlements in other your app for sharing
+(NSString *)allGroupId;
                       
// Capability -> Keychain Sharing
// Sharing between applications with one group id
+(NSString *)keychainGroupId;
+(void)setKeychainGroupId:(NSString *)group;
                                        

+(SettingsProxy *)application;   // Local for this application
+(SettingsProxy *)device;        // Local on device for several applications by app group id
+(SettingsProxy *)all;           // Global for all user devices, for this application (sync by iCloud)
+(SettingsProxy *)keychainLocal; // Local keychain for this application
+(SettingsProxy *)keychain;      // Global keychain for all user devices, for this application
+(SettingsProxy *)keychainShare; // Global keychain for all user devices, for keychain share group

// Helpers
+(NSData *)dataWithObject:(id)object;
+(id)objectWithData:(NSData *)data;

@end

@interface Keychain : NSObject
@end

@interface SettingsProxy : NSObject

@property (nonatomic, assign, readonly) SettingsType type;

-(id)objectForKeyedSubscript:(NSString *)key;
-(void) setObject:(id        )object
forKeyedSubscript:(NSString *)key;

@end
