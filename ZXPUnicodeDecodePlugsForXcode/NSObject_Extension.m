//
//  NSObject_Extension.m
//  ZXPUnicodeDecodePlugsForXcode
//
//  Created by xiaoping on 16/6/4.
//  Copyright © 2016年 coffee. All rights reserved.
//


#import "NSObject_Extension.h"
#import "ZXPUnicodeDecodePlugsForXcode.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[ZXPUnicodeDecodePlugsForXcode alloc] initWithBundle:plugin];
        });
    }
}
@end
