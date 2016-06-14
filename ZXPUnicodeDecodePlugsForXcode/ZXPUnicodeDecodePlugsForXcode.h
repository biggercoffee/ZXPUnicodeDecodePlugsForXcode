//
//  ZXPUnicodeDecodePlugsForXcode.h
//  ZXPUnicodeDecodePlugsForXcode
//
//  Created by xiaoping on 16/6/4.
//  Copyright © 2016年 coffee. All rights reserved.
//

#import <AppKit/AppKit.h>

@class ZXPUnicodeDecodePlugsForXcode;

static ZXPUnicodeDecodePlugsForXcode *sharedPlugin;

@interface ZXPUnicodeDecodePlugsForXcode : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;

+ (NSString*)convertUnicode:(NSString*)aString;

@end