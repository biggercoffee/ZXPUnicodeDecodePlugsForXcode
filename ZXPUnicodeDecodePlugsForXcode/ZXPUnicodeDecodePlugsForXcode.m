//
//  ZXPUnicodeDecodePlugsForXcode.m
//  ZXPUnicodeDecodePlugsForXcode
//
//  Created by xiaoping on 16/6/4.
//  Copyright © 2016年 coffee. All rights reserved.
//

#import "ZXPUnicodeDecodePlugsForXcode.h"

#import <objc/runtime.h>

static NSString *kZXPUnicodeDecodeInConsoleItemEnableKey = @"kZXPUnicodeDecodeInConsoleItemEnableKey";

static BOOL kZXPIsDecodeInConsole;

static ZXPUnicodeDecodePlugsForXcode *sharedPlugin;

@interface P_ZXP_IDEConsoleItem : NSObject

- (id)initWithAdaptorType:(id)arg1 content:(id)arg2 kind:(int)arg3;

@end

static IMP IMP_IDEConsoleItem_initWithAdaptorType = nil;

@implementation P_ZXP_IDEConsoleItem

- (id)initWithAdaptorType:(id)arg1 content:(id)arg2 kind:(int)arg3
{
    id (*execIMP)(id,SEL,id,id,int) = (void *)IMP_IDEConsoleItem_initWithAdaptorType;
    id item = execIMP(self, _cmd, arg1, arg2, arg3);
    if (kZXPIsDecodeInConsole) {
        NSString *logText = [item valueForKey:@"content"];
        
        NSString *resultText = [ZXPUnicodeDecodePlugsForXcode convertUnicode:logText];
        [item setValue:resultText forKey:@"content"];
    }
    
    return item;
}

@end


@interface ZXPUnicodeDecodePlugsForXcode()

@property (nonatomic, strong) NSBundle *bundle;

@property (nonatomic, strong) NSMenuItem *unicodeDecodeInConsoleItem;

@end

@implementation ZXPUnicodeDecodePlugsForXcode

+ (instancetype)sharedPlugin {
    return sharedPlugin;
}

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(menuDidChange)
                                                         name:NSMenuDidChangeItemNotification
                                                       object:nil];
        });
    }
}

+ (void)menuDidChange
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSMenuDidChangeItemNotification
                                                  object:nil];
    
    [sharedPlugin createMenu];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuDidChange)
                                                 name:NSMenuDidChangeItemNotification
                                               object:nil];
}

- (void)createMenu
{
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (menuItem && !self.unicodeDecodeInConsoleItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        self.unicodeDecodeInConsoleItem = [[NSMenuItem alloc] initWithTitle:@"ZXPUnicodeDecodeInConsole"
                                                               action:@selector(unicodeDecodeItemAction)
                                                        keyEquivalent:@""];
        [self.unicodeDecodeInConsoleItem setTarget:self];
        [[menuItem submenu] addItem:self.unicodeDecodeInConsoleItem];
        
        kZXPIsDecodeInConsole = [[NSUserDefaults standardUserDefaults] boolForKey:kZXPUnicodeDecodeInConsoleItemEnableKey];
        if (kZXPIsDecodeInConsole) {
            self.unicodeDecodeInConsoleItem.state = NSOnState;
        }
        else {
            self.unicodeDecodeInConsoleItem.state = NSOffState;
        }
    }
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource acccess
        self.bundle = plugin;
        
        // Create menu items, initialize UI, etc.
        
        // Sample Menu Item:
        [self createMenu];

        IMP_IDEConsoleItem_initWithAdaptorType = method_getImplementation(class_getInstanceMethod(NSClassFromString(@"IDEConsoleItem"), @selector(initWithAdaptorType:content:kind:)));
        method_setImplementation(class_getInstanceMethod(NSClassFromString(@"IDEConsoleItem"), @selector(initWithAdaptorType:content:kind:)), class_getMethodImplementation([P_ZXP_IDEConsoleItem class], @selector(initWithAdaptorType:content:kind:)));
    }
    
    return self;
}

- (void)unicodeDecodeItemAction
{
    BOOL convertInConsoleEnable = [[NSUserDefaults standardUserDefaults] boolForKey:kZXPUnicodeDecodeInConsoleItemEnableKey];
    [[NSUserDefaults standardUserDefaults] setBool:!convertInConsoleEnable forKey:kZXPUnicodeDecodeInConsoleItemEnableKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    kZXPIsDecodeInConsole = !convertInConsoleEnable;
    if (kZXPIsDecodeInConsole) {
        self.unicodeDecodeInConsoleItem.state = NSOnState;
    } else {
        self.unicodeDecodeInConsoleItem.state = NSOffState;
    }
}

+ (NSString*)convertUnicode:(NSString *)aString
{
    NSMutableString *convertedString = [aString mutableCopy];
    [convertedString replaceOccurrencesOfString:@"\\U" withString:@"\\u" options:0 range:NSMakeRange(0, convertedString.length)];
    CFStringRef transform = CFSTR("Any-Hex/Java");
    CFStringTransform((__bridge CFMutableStringRef)convertedString, NULL, transform, YES);
    return convertedString;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
