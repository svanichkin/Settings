//
//  Settings.h
//  v.3.0
//
//  Created by Сергей Ваничкин on 19.08.16.
//  Copyright © 2016 👽 Technology. All rights reserved.
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
