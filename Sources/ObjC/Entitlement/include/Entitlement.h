//
//  Entitlement.h
//
//  Created by Сергей Ваничкин on 19.12.2022.
//

#import <Foundation/Foundation.h>
#import "Settings.h"

@interface Entitlement : NSObject

+(NSString *)groupIdWithKey:(NSString *)key;

@end
