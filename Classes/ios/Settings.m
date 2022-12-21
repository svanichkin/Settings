//
//  Settings.m
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

#import "Settings.h"
#import <Security/Security.h>
#import <TargetConditionals.h>
#import <Availability.h>

@class Settings;

typedef enum
{
    NSKeychainAccessibleWhenUnlocked = 0,
    NSKeychainAccessibleAfterFirstUnlock,
    NSKeychainAccessibleWhenUnlockedThisDeviceOnly,
    NSKeychainAccessibleAfterFirstUnlockThisDeviceOnly
} NSKeychainAccess;

@interface Keychain ()

-(BOOL)removeObjectForKey:(id)key;
-(id)objectForKey:(id)key;
-(BOOL)setObject:(id)object
          forKey:(id)key;

+(nonnull instancetype)defaultLocalKeychain;
+(nonnull instancetype)defaultKeychain;
+(nonnull instancetype)defaultKeychainShare;

@property (nonatomic, assign) BOOL isLocal;
@property (nonatomic, assign) BOOL isShare;
@property (nonatomic, strong) NSString *keychainGroupId;

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
    [NSKeyedArchiver archivedDataWithRootObject:object];
}

+(id)objectWithData:(NSData *)data
{
    return
    [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

@end

@implementation Keychain

+(instancetype)defaultLocalKeychain
{
    static Keychain *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^
    {
        sharedInstance =
        Keychain.new;
        
        sharedInstance.isLocal = YES;
    });

    return
    sharedInstance;
}

+(instancetype)defaultKeychain
{
    static Keychain *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^
    {
        sharedInstance =
        Keychain.new;
    });

    return
    sharedInstance;
}

+(instancetype)defaultKeychainShare
{
    static Keychain *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^
    {
        sharedInstance =
        Keychain.new;
        
        sharedInstance.isShare = YES;
    });

    return
    sharedInstance;
}

-(NSMutableDictionary *)query
{
    //generate query
    NSMutableDictionary *query =
    NSMutableDictionary.new;
    
    if (self.isShare == NO)
        query[(__bridge NSString *)kSecAttrService] =
        NSBundle.mainBundle.bundleIdentifier;
    
    query[(__bridge NSString *)kSecClass] =
    (__bridge id)kSecClassGenericPassword;
    
    query[(__bridge NSString *)kSecMatchLimit] =
    (__bridge id)kSecMatchLimitOne;
    
    query[(__bridge NSString *)kSecReturnData] =
    (__bridge id)kCFBooleanTrue;
    
    query[(__bridge NSString *)kSecAttrSynchronizable] =
    (__bridge id _Nullable)(self.isLocal == YES ? kCFBooleanFalse : kCFBooleanTrue);
    
    if (self.isShare)
        query[(__bridge NSString *)kSecAttrAccessGroup] = self.keychainGroupId;
    
    return query;
}

-(NSData *)dataForKey:(id)key
{
    NSMutableDictionary *query =
    self.query;
    
    query[(__bridge NSString *)kSecAttrAccount] =
    [key description];
    
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

-(BOOL)setObject:(id)object
          forKey:(id)key
{
    NSMutableDictionary *query =
    self.query;
    
    query[(__bridge NSString *)kSecAttrAccount] =
    [key description];
        
    //encode object
    NSData *data = nil;
    NSError *error = nil;
    
    data =
    [NSKeyedArchiver archivedDataWithRootObject:object];

    //fail if object is invalid
    NSAssert(!object || (object && data),
             @"NSKeychain failed to encode object for key '%@', error: %@",
             key,
             error);

    if (data)
    {
        //update values
        NSMutableDictionary *update =
        [@{(__bridge NSString *)kSecValueData: data} mutableCopy];
        
#if TARGET_OS_IPHONE || __MAC_OS_X_VERSION_MIN_REQUIRED >= __MAC_10_9
        
        update[(__bridge NSString *)kSecAttrAccessible] =
        @[(__bridge id)kSecAttrAccessibleWhenUnlocked,
          (__bridge id)kSecAttrAccessibleAfterFirstUnlock,
          (__bridge id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
          (__bridge id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly]
        [NSKeychainAccessibleWhenUnlocked];
#endif
        
        //write data
        OSStatus status = errSecSuccess;
        if ([self dataForKey:key])
        {
            //there's already existing data for this key, update it
            status =
            SecItemUpdate((__bridge CFDictionaryRef)query,
                          (__bridge CFDictionaryRef)update);
        }
        
        else
        {
            //no existing data, add a new item
            [query addEntriesFromDictionary:update];
            status =
            SecItemAdd ((__bridge CFDictionaryRef)query, NULL);
        }
        
        if (status != errSecSuccess)
        {
            NSLog(@"NSKeychain failed to store data for key '%@', error: %ld",
                  key,
                  (long)status);
            
            return NO;
        }
    }
    
    else if (self[key])
    {
        //delete existing data
        
        OSStatus status =
        SecItemDelete((__bridge CFDictionaryRef)query);

        if (status != errSecSuccess)
        {
            NSLog(@"NSKeychain failed to delete data for key '%@', error: %ld",
                  key,
                  (long)status);
            
            return NO;
        }
    }
    
    return YES;
}

-(BOOL)removeObjectForKey:(id)key
{
    return
    [self setObject:nil forKey:key];
}

-(id)objectForKey:(id)key
{
    NSData *data =
    [self dataForKey:key];
    
    if (data)
    {
        id object = nil;
        NSError *error = nil;
        
        object =
        [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        if (!object)
             NSLog(@"NSKeychain failed to decode data for key '%@', error: %@",
                   key,
                   error);
        
        return
        object;
    }
    
    else
        //no value found
        return nil;
}

-(BOOL)setObject:(id)object
forKeyedSubscript:(id)key
{
    return
    [self setObject:object
             forKey:key];
}

-(id)objectForKeyedSubscript:(id)key
{
    return
    [self objectForKey:key];
}

@end



