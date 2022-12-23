//
//  Entitlement.h
//
//  Created by Сергей Ваничкин on 19.12.2022.
//

#import <Foundation/Foundation.h>

#define APP_DATA_CHANGED @"AppDataChanged"
#define DEV_DATA_CHANGED @"DevDataChanged"
#define ALL_DATA_CHANGED @"AllDataChanged"

@interface Entitlement : NSObject

+(NSString *)groupIdWithKey:(NSString *)key;

@end
