//
//  SetupKeyboardObserverOnAppStartup.m
//  ListableUI
//
//  Created by Kyle Van Essen on 8/24/20.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#if __has_include (<ListableUI/ListableUI-Swift.h>)
    #import <ListableUI/ListableUI-Swift.h>
#elif __has_include ("ListableUI-Swift.h")
    #import "ListableUI-Swift.h"
#endif


@interface __LST_SetupKeyboardObserverOnAppStartup : NSObject
@end


@implementation __LST_SetupKeyboardObserverOnAppStartup

/// Register for `applicationDidFinishLaunching`, so we can set up
/// our keyboard observer to always know when the keyboard is visible.
/// Yes, I know, and I am sorry.
+ (void)load {
    if (self != __LST_SetupKeyboardObserverOnAppStartup.class) {
        return;
    }
    
    [self sharedInstance];
}

+ (instancetype)sharedInstance;
{
    static __LST_SetupKeyboardObserverOnAppStartup *loader = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loader = [[__LST_SetupKeyboardObserverOnAppStartup alloc] init];
    });
    
    return loader;
}

- (instancetype)init;
{
    self = [super init];
    NSParameterAssert(self);
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(applicationDidFinishLaunchingNotification)
                                               name:UIApplicationDidFinishLaunchingNotification
                                             object:nil];
    
    return self;
}

- (void)applicationDidFinishLaunchingNotification;
{
    /// Application has now finished launching, so set up the keyboard observer.
    [__LST_KeyboardObserver_ObjCAccess __setupSharedInstance];
}

@end
