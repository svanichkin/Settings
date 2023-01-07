//
//  Settings.swift
//  v.5.1.1
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
/*

 Sample 1:

 Save and load "Test" string to key with "TestKey" name
 this sample for local settings on current application

 In app1 on user iphone
 Settings.application["TestKey"] = "Test"

 In app1 on user iphone
 let s = Settings.application["TestKey"]

 Sample 2:

 Save and load "Test" string to key with "TestKey" name
 this sample for local settings between one or more applications

 Go to Capability -> App Groups and Add new (group.com.application.test)

 In app1 on user iphone
 Settings.device["TestKey"] = "Test"

 In app2 OR app1 extention user iphone
 Settings.deviceAppGroup = "group.com.application.test"
 let s = Settings.device["TestKey"]

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
 Settings.all["TestKey"] = "Test"

 In app1 on user ipad
 let s = Settings.all["TestKey"]

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
 let myIdInApp1 = Settings.deviceGroupId
 Settings.all["TestKey"] = "Test"

 In app2 on user ipad
 Add Capability -> iCloud -> Enable Key-Value storage
 Replace in entitlements id to (9T111111W8.myOrganization.myProducName)
 let myIdInApp2SameApp1 = Settings.deviceGroupId
 let s = Settings.all["TestKey"]

 Sample 5:

 Save and load "Test" string to key with "TestKey" name
 this sample for local keychain without iCloud sync

 In app1 on user iphone
 Settings.keychainLocal["TestKey"] = "Test"

 In app1 on user ipad
 let s = Settings.keychainLocal["TestKey"]

 Sample 6:

 Save and load "Test" string to key with "TestKey" name
 this sample for global keychain on all user devices with iCloud sync

 Capability -> Keychain Sharing

 In app1 on user iphone
 Settings.keychain["TestKey"] = "Test"

 In app1 on user ipad
 let s = Settings.keychain["TestKey"]

 Sample 7:

 Save and load "Test" string to key with "TestKey" name
 this sample for global keychain on all user devices between applications with iCloud sync

 Capability -> Keychain Sharing -> Add new group (my.testingKeychain)

 In app1 on user iphone
 Settings.keychainShare["TestKey"] = "Test"

 In app2 on user ipad
 Add Capability -> Keychain Sharing -> Add new group (my.testingKeychain)
 or
 Add Capability -> Keychain Sharing and add new group over code
 Settings.keychainGroupId = "my.testingKeychain"

 Then read value
 let s = Settings.keychainShare["TestKey"]
 */

//@_exported
import Objective_C

import Foundation

@objc public final class Settings : NSObject {
    enum NotifyName {
        static let appDataChanged = "AppDataChanged"
        static let devDataChanged = "DevDataChanged"
        static let allDataChanged = "AllDataChanged"
    }

    // Capability -> App Groups
    // Sharing between applications on one device OR
    // Sharing between app and extention with one app group id
    @objc public static var deviceGroupId: String? {
        set { Settings.storage.deviceGroupId = newValue }
        get { Settings.storage.deviceGroupId }
    }

    // Capability -> iCloud -> Key-Value storage and Enable
    @objc public static var allGroupId: String? {
        SettingsProxy.valueForEntitlement(key: "com.apple.developer.ubiquity-kvstore-identifier")
    }

    // Capability -> Keychain Sharing
    // Sharing between applications with one group id
    @objc public static var keychainGroupId: String? {
        set { Settings.storage.keychainGroupId = newValue }
        get { Settings.storage.keychainGroupId }
    }

    // Local for this application
    @objc public static var application: SettingsProxy {
        let proxy = Settings.storage.application
        proxy.addNotificationsListener()
        return proxy
    }

    // Local on device for several applications by app group id
    @objc public static var device: SettingsProxy {
        let proxy = Settings.storage.device
        proxy.addNotificationsListener()
        return proxy
    }

    // Global for all user devices, for this application (sync by iCloud)
    @objc public static var all: SettingsProxy {
        let proxy = Settings.storage.all
        proxy.addNotificationsListener()
        return proxy
    }

    // Local keychain for this application
    @objc public static var keychainLocal: SettingsProxy {
        Settings.storage.keychainLocal
    }

    // Global keychain for all user devices, for this application
    @objc public static var keychain: SettingsProxy {
        Settings.storage.keychain
    }

    // Global keychain for all user devices, for keychain group
    @objc public static var keychainShare: SettingsProxy {
        Settings.storage.keychainShare
    }

    // Singletone for internal use
    private static let storage = Settings()

    private(set) lazy var application = SettingsProxy.init(withType: .application)
    private(set) lazy var device = SettingsProxy(withType: .device)
    private(set) lazy var all = SettingsProxy(withType: .all)
    private(set) lazy var keychainLocal = SettingsProxy(withType: .keychainLocal)
    private(set) lazy var keychain = SettingsProxy(withType: .keychain)
    private(set) lazy var keychainShare = SettingsProxy(withType: .keychainShare)

    private(set) lazy var deviceGroupId = SettingsProxy.valueForEntitlement(key: "com.apple.security.application-groups")
    private(set) lazy var keychainGroupId = SettingsProxy.valueForEntitlement(key: "keychain-access-groups")

    // Helpers
    public static func data(withObject object: Any) -> Data? {
        try? NSKeyedArchiver.archivedData(withRootObject: object,
                                          requiringSecureCoding: true)
    }

    public static func object(withData data: Data) -> Any? {
        NSKeyedUnarchiver.unarchiveObject(with: data)
    }
}

// private final class SettingsProxy {
// Хотелось бы сделать этот класс приватным, но если нет, то норм и так
@objc public final class SettingsProxy:NSObject {
    
    private let lock = NSRecursiveLock()
    
    enum SettingsType {
        case application,   // NSUserDefaults
             device,        // NSUserDefault with group id
             all,           // NSUbiquitousKeyValueStore
             keychainLocal, // Keychain without iCloud sync
             keychain,      // Keychain with iCloud sync
             keychainShare  // Keychain with iCloud sync and share group
    }

    var type: SettingsType

    var application: UserDefaults?
    var device: UserDefaults?
    var all: NSUbiquitousKeyValueStore?
    var keychainLocal: Keychain?
    var keychain: Keychain?
    var keychainShare: Keychain?

    var applicationObserver: NSObject?
    var deviceObserver: NSObject?
    var allObserver: NSObject?

    // Initializer access level change now
    init(withType t: SettingsType) {
        type = t
        switch type {
        case .application: application = UserDefaults.standard
        case .device: if Settings.deviceGroupId == nil { fatalError("АppGrpoupId not found. Add appGroups in target Capability. Capability -> App Groups") }; device = UserDefaults(suiteName: Settings.deviceGroupId)
        case .all: all = NSUbiquitousKeyValueStore.default
        case .keychainLocal: keychainLocal = Keychain.defaultKeychainLocal
        case .keychain: keychain = Keychain.defaultKeychain
        case .keychainShare: if Settings.keychainGroupId == nil { fatalError("KeychainGroupId not found. Add Keychain Sharing Groups in target Capability. Capability -> Keychain Sharing") }; keychainShare = Keychain.defaultKeychainShare; keychainShare!.keychainGroupId = Settings.keychainGroupId
        }
    }
    
    func addNotificationsListener() {
        switch type {
        case .application:
            applicationObserver = NotificationCenter.default.addObserver(
                forName: UserDefaults.didChangeNotification,
                object: nil,
                queue: nil
            ) { note in
                if note.object as? UserDefaults != UserDefaults.standard { return }
                NotificationCenter.default.post(
                    name: Notification.Name(Settings.NotifyName.appDataChanged),
                    object: UserDefaults.standard
                )
            } as? NSObject
            
        case .device:
            deviceObserver = NotificationCenter.default.addObserver(
                forName: UserDefaults.didChangeNotification,
                object: nil,
                queue: nil
            ) { note in
                if note.object as? UserDefaults != self.device { return }
                NotificationCenter.default.post(
                    name: Notification.Name(Settings.NotifyName.devDataChanged),
                    object: self.device
                )
            } as? NSObject
            
        case .all:
            allObserver = NotificationCenter.default.addObserver(
                forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                object: nil,
                queue: nil
            ) { _ in
                NotificationCenter.default.post(
                    name: Notification.Name(Settings.NotifyName.allDataChanged),
                    object: NSUbiquitousKeyValueStore.default
                )
            } as? NSObject
            all?.synchronize()
            
        default: return
        }
    }

    static func valueForEntitlement(key: String) -> String? {
#if os(OSX) || (os(iOS) && targetEnvironment(macCatalyst))
        var unmanagedError: Unmanaged<CFError>?
        defer { unmanagedError?.release() }
        let value = SecTaskCopyValueForEntitlement(self, key as CFString, &unmanagedError)
        // It's not an error for the value to be nil, it just means the entitlement isn't present
        if let unmanagedError {
            print(unmanagedError)
        }
        return cfTypeRefAsSwiftType(value as String)
#else
        // This case for iOS (if SecTaskCopyValueForEntitlement
        // add to iOS, need delete this case)
        return Entitlement.groupId(withKey: key)
#endif
    }

    func cfTypeRefAsSwiftType(_ ref: AnyObject) -> AnyHashable? {
        switch CFGetTypeID(ref as CFTypeRef) {
        case CFNullGetTypeID():
            return nil
        case CFStringGetTypeID():
            return ref as! String
        case CFArrayGetTypeID():
            return (ref as! NSArray).map { cfTypeRefAsSwiftType($0 as AnyObject) }
        // Failed to convert, leave as-is
        default:
            return ref as? AnyHashable
        }
    }

    func removeObject(forKey key: String) {
        switch type {
        case .application: application?.removeObject(forKey: key)
        case .device: device?.removeObject(forKey: key)
        case .all: all?.removeObject(forKey: key); all?.synchronize()
        case .keychainLocal: keychainLocal?.removeObject(forKey: key)
        case .keychain: keychain?.removeObject(forKey: key)
        case .keychainShare: keychainShare?.removeObject(forKey: key)
        }
    }

    @objc public func object(forKey key: String) -> Any? {
        switch type {
        case .application: return application?.object(forKey: key)
        case .device: return device?.object(forKey: key)
        case .all: all?.synchronize(); return all?.object(forKey: key)
        case .keychainLocal: return keychainLocal?.object(forKey: key)
        case .keychain: return keychain?.object(forKey: key)
        case .keychainShare: return keychainShare?.object(forKey: key)
        }
    }

    @objc public func set(_ object: Any?, forKey key: String) {
        lock.lock()
        defer { lock.unlock() }
        
        switch type {
        case .application: application?.set(object, forKey: key)
        case .device: device?.set(object, forKey: key)
        case .all: all?.synchronize(); all?.set(object, forKey: key)
        case .keychainLocal: keychainLocal?.set(object, forKey: key)
        case .keychain: keychain?.set(object, forKey: key)
        case .keychainShare: keychainShare?.set(object, forKey: key)
        }
    }

    @objc public subscript(key: String) -> Any? {
        get { object(forKey: key) }
        set { set(newValue, forKey: key) }
    }
}

final class Keychain {
    
    var isLocal: Bool = false
    var isShare: Bool = false
    var keychainGroupId: String?

    init(isLocal: Bool, isShare: Bool) {
        self.isLocal = isLocal
        self.isShare = isShare
    }

    static var defaultKeychainLocal: Keychain {
        Keychain(isLocal: true, isShare: false)
    }

    static var defaultKeychain: Keychain {
        Keychain(isLocal: false, isShare: false)
    }

    static var defaultKeychainShare: Keychain {
        Keychain(isLocal: false, isShare: true)
    }

    func query(withKey key: String) -> [CFString: Any] {
        var query: [CFString: Any] = [
            kSecAttrAccount: key,
            kSecClass: kSecClassGenericPassword,
            kSecAttrSynchronizable: (isLocal ? kCFBooleanFalse : kCFBooleanTrue) as CFBoolean]
        if isShare { query[kSecAttrAccessGroup] = keychainGroupId }
        else { query[kSecAttrService] = Bundle.main.bundleIdentifier }
        return query
    }

    func data(forKey key: String) -> Data? {
        var query = query(withKey: key)
        query[kSecMatchLimit] = kSecMatchLimitOne
        query[kSecReturnData] = kCFBooleanTrue
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status != errSecSuccess && status != errSecItemNotFound {
            print("Keychain failed to retrieve data for key \(key), error: \(status)")
        }
        return result as? Data
    }

    func removeObject(forKey key: String) {
        set(nil, forKey: key)
    }

    func object(forKey key: String) -> Any? {
        let data = data(forKey: key)
        var object: Any?
        if data != nil { object = Settings.object(withData: data!) }
        return object
    }

    func set(_ object: Any?, forKey key: String) {
        var query = query(withKey: key)
        // check for delete if obj nil
        if object == nil {
            // if key data is nil, delete complete )
            if data(forKey: key) == nil { return }
            let status = SecItemDelete(query as CFDictionary)
            if status != errSecSuccess {
                print("Keychain failed to delete data for key \(key), error: \(status)")
            }
            return
        }
        // add or update
        guard let d = Settings.data(withObject: object as Any) else {
            print("Keychain failed to encode object for key \(key)")
            return
        }
        // update values query
        var update: [CFString: Any] = [
            kSecValueData: d as Any,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock]
        // there's already existing data for this key, update it
        if data(forKey: key) != nil {
            let status = SecItemUpdate(query as CFDictionary, update as CFDictionary)
            if status != errSecSuccess {
                print("Keychain failed to update data for key \(key), error: \(status)")
            }
            return
        }
        // no existing data, add a new item
        query = query.merging(update) { $1 }
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Keychain failed to store data for key \(key), error: \(status)")
        }
    }
}
