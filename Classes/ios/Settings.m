//
//  Settings.m
//  v.3.0
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

+(nonnull instancetype)defaultKeychain;

@property (nonatomic, readonly, nullable) NSString *service;
@property (nonatomic, readonly, nullable) NSString *accessGroup;
@property (nonatomic, assign) NSKeychainAccess accessibility;

-(nonnull id)initWithService:(nullable NSString *)service
                 accessGroup:(nullable NSString *)accessGroup
               accessibility:(NSKeychainAccess)accessibility;

-(nonnull id)initWithService:(nullable NSString *)service
                 accessGroup:(nullable NSString *)accessGroup;

@end

@interface SettingsProxy ()

@property (nonatomic, strong) NSUserDefaults            *application;
@property (nonatomic, strong) NSUserDefaults            *device;
@property (nonatomic, strong) NSUbiquitousKeyValueStore *all;
@property (nonatomic, strong) Keychain                  *keychain;

@property (nonatomic, strong) id applicationObserver;
@property (nonatomic, strong) id deviceObserver;
@property (nonatomic, strong) id allObserver;

@end

@implementation SettingsProxy

-(void)setType:(SettingsType)type
{
    _type = type;
    
    if (_type == SettingsTypeCurrentApplication)
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
    
    else if (_type == SettingsTypeCurrentDeviceWithAppGroups)
    {
        // Declare the private SecTask functions in your header file
        void* (SecTaskCopyValueForEntitlement)(void* task, CFStringRef entitlement, CFErrorRef  _Nullable *error);
        void* (SecTaskCreateFromSelf)(CFAllocatorRef allocator);
                
        #if !TARGET_OS_IPHONE
        CFErrorRef err = nil;
        NSArray *groups = (__bridge NSArray *)(SecTaskCopyValueForEntitlement(SecTaskCreateFromSelf(NULL), CFSTR("com.apple.security.application-groups"), &err));
        
        if (groups.count == 0)
        {
            [NSException
             raise:@"appGrpoups not found"
             format:@"Add appGroups in target Capability."];
            
            return;
        }
        
        Settings.deviceAppGroup =
        groups.firstObject;
        
        _device =
        [NSUserDefaults.alloc
         initWithSuiteName:groups.firstObject];
        #else
        if (Settings.deviceAppGroup.length == 0)
        {
            [NSException
             raise:@"appGrpoups not found"
             format:@"Add appGroups in target Capability."];
            
            return;
        }
        _device =
        [NSUserDefaults.alloc
         initWithSuiteName:Settings.deviceAppGroup];
        #endif
            
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
    
    else if (_type == SettingsTypeAllDevicesWithKeyValueStorage)
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
    
    else if (_type == SettingsTypeKeychain)
    {
        _keychain =
        Keychain.defaultKeychain;
    }
}

-(void)removeObjectForKey:(id)key
{
    if (_type == SettingsTypeCurrentApplication)
    {
        [self.application removeObjectForKey:key];
        [self.application synchronize];
    }
    
    else if (_type == SettingsTypeCurrentDeviceWithAppGroups)
    {
        [self.device removeObjectForKey:key];
        [self.device synchronize];
    }
    
    else if (_type == SettingsTypeAllDevicesWithKeyValueStorage)
    {
        [self.all removeObjectForKey:key];
        [self.all synchronize];
    }
    
    else if (_type == SettingsTypeKeychain)
        [self.keychain removeObjectForKey:key];
}

-(id)objectForKey:(id)key
{
    if (_type == SettingsTypeCurrentApplication)
    {
        [self.application synchronize];
        
        return
        [self.application objectForKey:key];
    }
    
    else if (_type == SettingsTypeCurrentDeviceWithAppGroups)
    {
        [self.device synchronize];
        
        return
        [self.device objectForKey:key];
    }
    
    else if (_type == SettingsTypeAllDevicesWithKeyValueStorage)
    {
        [self.all synchronize];
        
        return
        [self.all objectForKey:key];
    }
    
    else if (_type == SettingsTypeKeychain)
        return
        [self.keychain objectForKey:key];
    
    return nil;
}

-(void)setObject:(id)object
          forKey:(id)key
{
    if (_type == SettingsTypeCurrentApplication)
        [self.application
         setObject:object
         forKey:key];
    
    else if (_type == SettingsTypeCurrentDeviceWithAppGroups)
        [self.device
         setObject:object
         forKey:key];

    else if (_type == SettingsTypeAllDevicesWithKeyValueStorage)
    {
        [self.all
         setObject:object
         forKey:key];
        
        [self.all synchronize];
    }
    
    else if (_type == SettingsTypeKeychain)
        [self.keychain
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
@property (nonatomic, strong) SettingsProxy *keychain;
@property (nonatomic, strong) NSString      *appGroup;

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

+(void)setDeviceAppGroup:(NSString *)appGroup
{
    Settings.storage.appGroup = appGroup;
}

+(NSString *)deviceAppGroup
{
    return
    Settings.storage.appGroup;
}

+(SettingsProxy *)application
{
    if (Settings.storage.application == nil)
    {
        SettingsProxy *proxy = SettingsProxy.new;
        
        proxy.type = SettingsTypeCurrentApplication;
        
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
        
        proxy.type = SettingsTypeCurrentDeviceWithAppGroups;
        
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
        
        proxy.type = SettingsTypeAllDevicesWithKeyValueStorage;
        
        Settings.storage.all = proxy;
    }
    
    return
    Settings.storage.all;
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

@implementation NSObject (NSKeychainPropertyListCoding)

-(id)NSKeychain_propertyListRepresentation
{
    return
    self;
}

@end

#ifndef NSKEYCHAIN_USE_NSCODING
#if TARGET_OS_IPHONE
#define NSKEYCHAIN_USE_NSCODING 1
#else
#define NSKEYCHAIN_USE_NSCODING 0
#endif
#endif

#if !NSKEYCHAIN_USE_NSCODING

@implementation NSNull (NSKeychainPropertyListCoding)

-(id)NSKeychain_propertyListRepresentation
{
    return
    nil;
}

@end

@implementation NSArray (BMPropertyListCoding)

-(id)NSKeychain_propertyListRepresentation
{
    NSMutableArray *copy =
    [NSMutableArray arrayWithCapacity:[self count]];
    
    for (id obj in self)
    {
        id value =
        [obj NSKeychain_propertyListRepresentation];
        
        if (value)
            [copy addObject:value];
    }
    
    return
    copy;
}

@end

@implementation NSDictionary (BMPropertyListCoding)

-(id)NSKeychain_propertyListRepresentation
{
    NSMutableDictionary *copy =
    [NSMutableDictionary
     dictionaryWithCapacity:[self count]];
    
    [self
     enumerateKeysAndObjectsUsingBlock:^(__unsafe_unretained id key,
                                         __unsafe_unretained id obj,
                                         __unused         BOOL *stop)
    {
        id value =
        [obj NSKeychain_propertyListRepresentation];
        
        if (value)
            copy[key] =
            value;
    }];
    
    return
    copy;
}

@end
#endif

@implementation Keychain

+(instancetype)defaultKeychain
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^
    {
        NSString *bundleID =
        [NSBundle.mainBundle
         objectForInfoDictionaryKey:(NSString *)kCFBundleIdentifierKey];
        
        sharedInstance =
        [Keychain.alloc
         initWithService:bundleID
         accessGroup:nil];
    });

    return
    sharedInstance;
}

-(id)init
{
    return
    [self
     initWithService:nil
     accessGroup:NSBundle.mainBundle.bundleIdentifier];
}

-(id)initWithService:(NSString *)service
         accessGroup:(NSString *)accessGroup
{
    return
    [self
     initWithService:service
     accessGroup:accessGroup
     accessibility:NSKeychainAccessibleWhenUnlocked];
}

-(id)initWithService:(NSString *)service
         accessGroup:(NSString *)accessGroup
       accessibility:(NSKeychainAccess)accessibility
{
    if ((self = [super init]))
    {
        _service =
        [service copy];
        
        _accessGroup =
        [accessGroup copy];
        
        _accessibility =
        accessibility;
    }
    return self;
}

-(NSData *)dataForKey:(id)key
{
    //generate query
    NSMutableDictionary *query =
    NSMutableDictionary.new;
    
    if ([self.service length])
        query[(__bridge NSString *)kSecAttrService] =
        self.service;
    
    query[(__bridge NSString *)kSecClass] =
    (__bridge id)kSecClassGenericPassword;
    
    query[(__bridge NSString *)kSecMatchLimit] =
    (__bridge id)kSecMatchLimitOne;
    
    query[(__bridge NSString *)kSecReturnData] =
    (__bridge id)kCFBooleanTrue;
    
    query[(__bridge NSString *)kSecAttrAccount] =
    [key description];

#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
    
    if ([_accessGroup length])
        query[(__bridge NSString *)kSecAttrAccessGroup] =
        _accessGroup;
    
#endif
    
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
    //generate query
    NSMutableDictionary *query =
    NSMutableDictionary.new;
    
    if ([self.service length])
        query[(__bridge NSString *)kSecAttrService] =
        self.service;
    
    query[(__bridge NSString *)kSecClass] =
    (__bridge id)kSecClassGenericPassword;
    
    query[(__bridge NSString *)kSecAttrAccount] =
    [key description];
    
#if TARGET_OS_IPHONE && !TARGET_IPHONE_SIMULATOR
    if ([_accessGroup length])
        query[(__bridge NSString *)kSecAttrAccessGroup] =
        _accessGroup;
#endif
    
    //encode object
    NSData *data = nil;
    NSError *error = nil;
    
    if ([(id)object isKindOfClass:[NSString class]])
    {
        //check that string data does not represent a binary plist
        NSPropertyListFormat format = NSPropertyListBinaryFormat_v1_0;
        
        if (![object hasPrefix:@"bplist"] ||
            ![NSPropertyListSerialization
              propertyListWithData:[object dataUsingEncoding:NSUTF8StringEncoding]
              options:NSPropertyListImmutable
              format:&format
              error:NULL])
            //safe to encode as a string
            data = [object dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    //if not encoded as a string, encode as plist
    if (object && !data)
    {
        data =
        [NSPropertyListSerialization
         dataWithPropertyList:[object NSKeychain_propertyListRepresentation]
         format:NSPropertyListBinaryFormat_v1_0
         options:0
         error:&error];
#if NSKEYCHAIN_USE_NSCODING
        //property list encoding failed. try NSCoding
        if (!data)
            data =
            [NSKeyedArchiver archivedDataWithRootObject:object];
#endif
    }

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
        [self.accessibility];
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
        
#if TARGET_OS_IPHONE
        
        OSStatus status =
        SecItemDelete((__bridge CFDictionaryRef)query);
#else
        CFTypeRef result = NULL;
        
        query[(__bridge id)kSecReturnRef] =
        (__bridge id)kCFBooleanTrue;
        
        OSStatus status =
        SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
        
        if (status == errSecSuccess)
        {
            status =
            SecKeychainItemDelete((SecKeychainItemRef) result);
            
            CFRelease(result);
        }
#endif
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
        
        NSPropertyListFormat format =
        NSPropertyListBinaryFormat_v1_0;
        
        //check if data is a binary plist
        if ([data length] >= 6 &&
            !strncmp("bplist", data.bytes, 6))
        {
            //attempt to decode as a plist
            object =
            [NSPropertyListSerialization
             propertyListWithData:data
             options:NSPropertyListImmutable
             format:&format
             error:&error];
            
            if ([object respondsToSelector:@selector(objectForKey:)] &&
                [(NSDictionary *)object objectForKey:@"$archiver"])
            {
                //data represents an NSCoded archive
                
    #if NSKEYCHAIN_USE_NSCODING
                
                //parse as archive
                object =
                [NSKeyedUnarchiver unarchiveObjectWithData:data];
    #else
                //don't trust it
                object = nil;
    #endif
                
            }
        }
        
        if (!object || format != NSPropertyListBinaryFormat_v1_0)
            //may be a string
            object =
            [NSString.alloc
             initWithData:data
             encoding:NSUTF8StringEncoding];
        
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



