//
//  Entitlement.m
//
//  Created by Сергей Ваничкин on 19.12.2022.
//

#import "Entitlement.h"

@implementation Entitlement

+(NSString *)groupIdWithKey:(NSString *)key
{
#if TARGET_OS_IPHONE && !TARGET_OS_MACCATALYST
    void *(SecTaskCopyValueForEntitlement)(void *task, CFStringRef entitlement, CFErrorRef *error);
    void *(SecTaskCreateFromSelf)(CFAllocatorRef allocator);
#endif
    
    id value = (__bridge id)(SecTaskCopyValueForEntitlement(SecTaskCreateFromSelf(NULL), (__bridge CFStringRef)key, nil));
    
    if ([value isKindOfClass:NSArray.class])
        return [value firstObject];
    
    return value;
}

@end
