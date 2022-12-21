//
//  Settings.m
//  v.4.2
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

#import "Settings.h"
#import <Security/Security.h>
#import <TargetConditionals.h>
#import <Availability.h>

@class Settings;

typedef enum
{
    SettingsTypeApplication,   // NSUserDefaults
    SettingsTypeDevice,        // NSUserDefault with group id
    SettingsTypeAll,           // NSUbiquitousKeyValueStore (need enable iCloud Key-Value)
    SettingsTypeKeychainLocal, // Keychain without iCloud sync
    SettingsTypeKeychain,      // Keychain with iCloud sync (need enable Keychain Share)
    SettingsTypeKeychainShare  // Keychain with iCloud sync and share group
} SettingsType;

@interface Settings ()

@property (nonatomic, strong) SettingsProxy *application;
@property (nonatomic, strong) SettingsProxy *device;
@property (nonatomic, strong) SettingsProxy *all;
@property (nonatomic, strong) SettingsProxy *keychainLocal;
@property (nonatomic, strong) SettingsProxy *keychain;
@property (nonatomic, strong) SettingsProxy *keychainShare;
@property (nonatomic, strong) NSString      *deviceGroupId;
@property (nonatomic, strong) NSString      *keychainGroupId;

@end

@interface Keychain : NSObject
@end

@interface Keychain ()

@property (nonatomic, assign) BOOL isLocal;
@property (nonatomic, assign) BOOL isShare;

@property (nonatomic, strong) NSString *keychainGroupId;

+(nonnull instancetype)defaultLocalKeychain;
+(nonnull instancetype)defaultKeychain;
+(nonnull instancetype)defaultKeychainShare;

-(void)removeObjectForKey:(id)key;
-(id)objectForKey:(id)key;
-(void)setObject:(id)object
          forKey:(id)key;

@end

@interface SettingsProxy ()

@property (nonatomic, strong) NSUserDefaults            *application;
@property (nonatomic, strong) NSUserDefaults            *device;
@property (nonatomic, strong) NSUbiquitousKeyValueStore *all;
@property (nonatomic, strong) Keychain                  *keychainLocal;
@property (nonatomic, strong) Keychain                  *keychain;
@property (nonatomic, strong) Keychain                  *keychainShare;

@property (nonatomic, strong) id applicationObserver;
@property (nonatomic, strong) id deviceObserver;
@property (nonatomic, strong) id allObserver;

@property (nonatomic, assign, readonly) SettingsType type;

@end

@implementation SettingsProxy

-(void)setType:(SettingsType)type
{
    _type = type;
    
    if (_type == SettingsTypeApplication)
    {
        _application =
        NSUserDefaults.standardUserDefaults;
        
        if (self.applicationObserver == nil)
            self.applicationObserver =
            [NSNotificationCenter.defaultCenter
             addObserverForName:NSUserDefaultsDidChangeNotification
             object:nil
             queue:nil
             usingBlock:^(NSNotification *note)
             {
                if (note.object != self.application)
                    return;
                
                [self.application synchronize];
                
                [NSNotificationCenter.defaultCenter
                 postNotificationName:APP_DATA_CHANGED
                 object:nil];
            }];
    }
    
    else if (_type == SettingsTypeDevice)
    {
        // Declare the private SecTask functions in your header file
#if TARGET_OS_IPHONE
        void *(SecTaskCopyValueForEntitlement)(void *task, CFStringRef entitlement, CFErrorRef _Nullable *error);
        void *(SecTaskCreateFromSelf)(CFAllocatorRef allocator);
#endif
        
        // Auto get group id if need
        if (Settings.deviceGroupId.length == 0)
        {
            NSArray *groups = (__bridge NSArray *)(SecTaskCopyValueForEntitlement(SecTaskCreateFromSelf(NULL), CFSTR("com.apple.security.application-groups"), NULL));
            
            Settings.deviceGroupId =
            groups.firstObject;
        
            if (Settings.deviceGroupId.length == 0)
            {
                [NSException
                 raise:@"appGrpoups not found"
                 format:@"Add appGroups in target Capability. Capability -> App Groups"];
                
                return;
            }
        }
        
        _device =
        [NSUserDefaults.alloc
         initWithSuiteName:Settings.deviceGroupId];
            
        if (self.deviceObserver)
            self.deviceObserver =
            [NSNotificationCenter.defaultCenter
             addObserverForName:NSUserDefaultsDidChangeNotification
             object:nil
             queue:nil
             usingBlock:^(NSNotification *note)
             {
                if (note.object != self.device)
                    return;
                
                [self.device synchronize];
                
                [NSNotificationCenter.defaultCenter
                 postNotificationName:DEV_DATA_CHANGED
                 object:nil];
            }];
    }
    
    else if (_type == SettingsTypeAll)
    {
        _all =
        NSUbiquitousKeyValueStore.defaultStore;
        
        if (self.allObserver == nil)
            self.allObserver =
            [NSNotificationCenter.defaultCenter
             addObserverForName:NSUbiquitousKeyValueStoreDidChangeExternallyNotification
             object:NSUbiquitousKeyValueStore.defaultStore
             queue:nil
             usingBlock:^(NSNotification *notification)
            {
                [NSNotificationCenter.defaultCenter
                 postNotificationName:ALL_DATA_CHANGED
                 object:nil];
            }];
        
        [_all synchronize];
    }
    
    else if (_type == SettingsTypeKeychainLocal)
    {
        _keychainLocal =
        Keychain.defaultLocalKeychain;
    }
    
    else if (_type == SettingsTypeKeychain)
    {
        _keychain =
        Keychain.defaultKeychain;
    }
        
    else if (_type == SettingsTypeKeychainShare)
    {
#if TARGET_OS_IPHONE
        // Declare the private SecTask functions in your header file
        void *(SecTaskCopyValueForEntitlement)(void *task, CFStringRef entitlement, CFErrorRef _Nullable *error);
        void *(SecTaskCreateFromSelf)(CFAllocatorRef allocator);
#endif
        
        // Auto get group id if need
        if (Settings.keychainGroupId.length == 0)
        {
            NSArray *groups = (__bridge NSArray *)(SecTaskCopyValueForEntitlement(SecTaskCreateFromSelf(NULL), CFSTR("keychain-access-groups"), NULL));
            
            Settings.keychainGroupId =
            groups.firstObject;
        
            if (Settings.keychainGroupId.length == 0)
            {
                [NSException
                 raise:@"keychainGrpoups not found"
                 format:@"Add Keychain Sharing Groups in target Capability. Capability -> Keychain Sharing"];
                
                return;
            }
        }
        
        _keychainShare =
        Keychain.defaultKeychainShare;
        
        _keychainShare.keychainGroupId =
        Settings.keychainGroupId;
    }
}

-(void)removeObjectForKey:(id)key
{
    if (_type == SettingsTypeApplication)
    {
        [self.application removeObjectForKey:key];
        [self.application synchronize];
    }
    
    else if (_type == SettingsTypeDevice)
    {
        [self.device removeObjectForKey:key];
        [self.device synchronize];
    }
    
    else if (_type == SettingsTypeAll)
    {
        [self.all removeObjectForKey:key];
        [self.all synchronize];
    }
    
    else if (_type == SettingsTypeKeychainLocal)
        [self.keychainLocal removeObjectForKey:key];
    
    else if (_type == SettingsTypeKeychain)
        [self.keychain removeObjectForKey:key];
    
    else if (_type == SettingsTypeKeychainShare)
        [self.keychainShare removeObjectForKey:key];
}

-(id)objectForKey:(id)key
{
    if (_type == SettingsTypeApplication)
    {
        [self.application synchronize];
        
        return
        [self.application objectForKey:key];
    }
    
    else if (_type == SettingsTypeDevice)
    {
        [self.device synchronize];
        
        return
        [self.device objectForKey:key];
    }
    
    else if (_type == SettingsTypeAll)
    {
        [self.all synchronize];
        
        return
        [self.all objectForKey:key];
    }
    
    else if (_type == SettingsTypeKeychainLocal)
        return
        [self.keychainLocal objectForKey:key];
    
    else if (_type == SettingsTypeKeychain)
        return
        [self.keychain objectForKey:key];
    
    else if (_type == SettingsTypeKeychainShare)
        return
        [self.keychainShare objectForKey:key];
    
    return nil;
}

-(void)setObject:(id)object
          forKey:(id)key
{
    if (_type == SettingsTypeApplication)
        [self.application
         setObject:object
         forKey:key];
    
    else if (_type == SettingsTypeDevice)
        [self.device
         setObject:object
         forKey:key];

    else if (_type == SettingsTypeAll)
    {
        [self.all
         setObject:object
         forKey:key];
        
        [self.all synchronize];
    }
    
    else if (_type == SettingsTypeKeychainLocal)
        [self.keychainLocal
         setObject:object
         forKey:key];
    
    else if (_type == SettingsTypeKeychain)
        [self.keychain
         setObject:object
         forKey:key];
    
    else if (_type == SettingsTypeKeychainShare)
        [self.keychainShare
         setObject:object
         forKey:key];
}

-(void) setObject:(id)object
forKeyedSubscript:(NSString *)key
{
    return
    [self setObject:object
             forKey:key];
}

-(id)objectForKeyedSubscript:(NSString *)key
{
    return
    [self objectForKey:key];
}

@end

@implementation Settings

+(instancetype)storage
{
    static Settings *_storage = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^
    {
        _storage = Settings.new;
    });
    
    return _storage;
}

+(void)setDeviceGroupId:(NSString *)appGroupId
{
    Settings.storage.deviceGroupId = appGroupId;
}

+(NSString *)deviceGroupId
{
    return
    Settings.storage.deviceGroupId;
}

+(NSString *)allGroupId
{
#if TARGET_OS_IPHONE
    void *(SecTaskCopyValueForEntitlement)(void *task, CFStringRef entitlement, CFErrorRef _Nullable *error);
    void *(SecTaskCreateFromSelf)(CFAllocatorRef allocator);
#endif
    
    NSArray *groups = (__bridge NSArray *)(SecTaskCopyValueForEntitlement(SecTaskCreateFromSelf(NULL), CFSTR("com.apple.developer.ubiquity-kvstore-identifier"), NULL));
    
    return groups.firstObject;
}

+(void)setKeychainGroupId:(NSString *)groupId
{
    Settings.storage.keychainGroupId = groupId;
}

+(NSString *)keychainGroupId
{
    return
    Settings.storage.keychainGroupId;
}


+(SettingsProxy *)application
{
    if (Settings.storage.application == nil)
    {
        SettingsProxy *proxy = SettingsProxy.new;
        
        proxy.type = SettingsTypeApplication;
        
        Settings.storage.application = proxy;
    }
    
    return
    Settings.storage.application;
}

+(SettingsProxy *)device
{
    if (Settings.storage.device == nil)
    {
        SettingsProxy *proxy = SettingsProxy.new;
        
        proxy.type = SettingsTypeDevice;
        
        Settings.storage.device = proxy;
    }
    
    return
    Settings.storage.device;
}

+(SettingsProxy *)all
{
    if (Settings.storage.all == nil)
    {
        SettingsProxy *proxy = SettingsProxy.new;
        
        proxy.type = SettingsTypeAll;
        
        Settings.storage.all = proxy;
    }
    
    return
    Settings.storage.all;
}

+(SettingsProxy *)keychainLocal
{
    if (Settings.storage.keychainLocal == nil)
    {
        SettingsProxy *proxy = SettingsProxy.new;
        
        proxy.type = SettingsTypeKeychainLocal;
        
        Settings.storage.keychainLocal = proxy;
    }
        
    return
    Settings.storage.keychainLocal;
}

+(SettingsProxy *)keychain
{
    if (Settings.storage.keychain == nil)
    {
        SettingsProxy *proxy = SettingsProxy.new;
        
        proxy.type = SettingsTypeKeychain;
        
        Settings.storage.keychain = proxy;
    }
        
    return
    Settings.storage.keychain;
}

+(SettingsProxy *)keychainShare
{
    if (Settings.storage.keychainShare == nil)
    {
        SettingsProxy *proxy = SettingsProxy.new;
        
        proxy.type = SettingsTypeKeychainShare;
        
        Settings.storage.keychainShare = proxy;
    }
        
    return
    Settings.storage.keychainShare;
}

// Helpers
+(NSData *)dataWithObject:(id)object
{
    return
    [NSKeyedArchiver
     archivedDataWithRootObject:object
     requiringSecureCoding:YES
     error:nil];
}

+(id)objectWithData:(NSData *)data
{
//    NSSet *classes =
//    [NSSet setWithArray:@[NSArray.class, NSMutableArray.class, NSSet.class, NSMutableSet.class, NSDictionary.class, NSMutableDictionary.class, NSNumber.class, NSMutable]];
//    return
//    [NSKeyedUnarchiver
//     unarchivedObjectOfClasses:classes
//     fromData:data
//     error:nil];
    
    return
    [NSKeyedUnarchiver
     unarchiveObjectWithData:data];
}

@end

@implementation Keychain

-(instancetype)initWithLocal:(BOOL)local
                       share:(BOOL)share
{
    if (self = [super init])
    {
        self.isLocal = local;
        self.isShare = share;
    }
    return self;
}

+(instancetype)defaultLocalKeychain
{
    return
    [Keychain.alloc
     initWithLocal:YES
     share:NO];
}

+(instancetype)defaultKeychain
{
    return
    Keychain.new;
}

+(instancetype)defaultKeychainShare
{
    return
    [Keychain.alloc
     initWithLocal:NO
     share:YES];
}

-(NSMutableDictionary *)queryWithKey:(id)key
{
    //generate query
    NSMutableDictionary *query =
    NSMutableDictionary.new;
    
    query[(__bridge NSString *)kSecAttrAccount] =
    [key description];
    
    if (self.isShare == NO)
        query[(__bridge NSString *)kSecAttrService] =
        NSBundle.mainBundle.bundleIdentifier;
    
    query[(__bridge NSString *)kSecClass] =
    (__bridge id)kSecClassGenericPassword;
        
    query[(__bridge NSString *)kSecAttrSynchronizable] =
    (__bridge id)(self.isLocal ? kCFBooleanFalse : kCFBooleanTrue);
    
    if (self.isShare)
        query[(__bridge NSString *)kSecAttrAccessGroup] =
        self.keychainGroupId;
    
    return query;
}

-(NSData *)dataForKey:(id)key
{
    NSMutableDictionary *query =
    [self queryWithKey:key];
    
    query[(__bridge NSString *)kSecMatchLimit] =
    (__bridge id)kSecMatchLimitOne;
    
    query[(__bridge NSString *)kSecReturnData] =
    (__bridge id)kCFBooleanTrue;
    
    //recover data
    CFDataRef data =
    NULL;
    
    OSStatus status =
    SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&data);
    
    if (status != errSecSuccess &&
        status != errSecItemNotFound)
        NSLog(@"NSKeychain failed to retrieve data for key '%@', error: %ld",
              key,
              (long)status);

    return
    CFBridgingRelease(data);
}

-(void)setObject:(id)object
          forKey:(id)key
{
    NSData *existedData =
    [self dataForKey:key];
    
    NSMutableDictionary *query =
    [self queryWithKey:key];
    
    // check for delete if obj nil
    if (object == nil)
    {
        // if key data is nil, delete complete )
        if (existedData == nil)
            return;
        
        OSStatus status =
        SecItemDelete((__bridge CFDictionaryRef)query);

        if (status != errSecSuccess)
            NSLog(@"NSKeychain failed to delete data for key '%@', error: %ld",
                  key,
                  (long)status);
        
        return;
    }
    
    // add or update
    NSData *data =
    [Settings dataWithObject:object];
    
    if (data == nil)
        return
        NSLog (@"NSKeychain failed to encode object for key '%@'", key);
    
    // update values query
    NSMutableDictionary *update = NSMutableDictionary.new;
    
    update[(__bridge NSString *)kSecValueData] = data;
    
    update[(__bridge NSString *)kSecAttrAccessible] =
    (__bridge id)kSecAttrAccessibleWhenUnlocked;
    
    //write data
    OSStatus status = errSecSuccess;
    
    //there's already existing data for this key, update it
    if (existedData)
    {
        status =
        SecItemUpdate((__bridge CFDictionaryRef)query,
                      (__bridge CFDictionaryRef)update);
        
        if (status != errSecSuccess)
            NSLog(@"NSKeychain failed to update data for key '%@', error: %ld",
                  key,
                  (long)status);
        
        return;
    }
    
    //no existing data, add a new item
    [query addEntriesFromDictionary:update];
    
    status =
    SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    
    if (status != errSecSuccess)
        NSLog(@"NSKeychain failed to store data for key '%@', error: %ld",
              key,
              (long)status);
        
    return;
}

-(void)removeObjectForKey:(id)key
{
    [self
     setObject:nil
     forKey:key];
}

-(id)objectForKey:(id)key
{
    NSData *data =
    [self dataForKey:key];
    
    id object = nil;
    
    if (data)
        object =
        [Settings objectWithData:data];

    return
    object;
}

-(void) setObject:(id)object
forKeyedSubscript:(id)key
{
    [self setObject:object
             forKey:key];
}

-(id)objectForKeyedSubscript:(id)key
{
    return
    [self objectForKey:key];
}

@end
