//
//  Settings.h
//  v.2.1
//
//  Created by Сергей Ваничкин on 19.08.16.
//  Copyright © 2016 👽 Technology. All rights reserved.
//
//  Пример использования
//
//  [Settings.application setObject:@"Test" forKey:@"TestKey"];
//
//  [Settings.application objectForKey:@"TestKey"];
//
//  Аналогично:
//  device сохраняет ключи для AppGroup указанной в Capability в таргете. Вызывает эксепшен, если группа не указана.
//  keychain сохраняет ключи в цепочке ключей.
//  all сохраняет ключи в Key-Value Storage, который должен быть включен в таргете, также нужно указать в entitlements название группы
//
//  например:
//  <key>com.apple.developer.ubiquity-kvstore-identifier</key>
//  <string>9T111111W8.ru.project.AppName</string>
//

#import <Foundation/Foundation.h>

#define ALL_DATA_CHANGED @"AllDataChanged"
#define DEV_DATA_CHANGED @"DevDataChanged"
#define APP_DATA_CHANGED @"AppDataChanged"

typedef enum
{
    SettingsTypeCurrentApplication,
    SettingsTypeCurrentDeviceWithAppGroups,
    SettingsTypeAllDevicesWithKeyValueStorage,
    SettingsTypeKeychain
} SettingsType;

@class SettingsProxy;

@interface Settings : NSObject

+(NSString *)deviceAppGroup;
+(void)setDeviceAppGroup:(NSString *)appGroup; // Для iOS требуется установка вручную, для macCatalyst,
                                               // или mac версий значение устанавливается автоматически
                                               // и берется из entitlements
                                               // Значение требуется для device.

+(SettingsProxy *)application; // Только для этого приложения
+(SettingsProxy *)device;      // Для appGroups на этом устройстве
+(SettingsProxy *)all;         // Для Key-Value Storage на устройствах
+(SettingsProxy *)keychain;    // Для связки ключей

@end

@interface Keychain : NSObject
@end

@interface SettingsProxy : NSObject

@property (nonatomic, assign, readonly) SettingsType type;

-(void)removeObjectForKey:(id)key;
-(id)objectForKey:(id)key;
-(void)setObject:(id)object
          forKey:(id)key;

@end
