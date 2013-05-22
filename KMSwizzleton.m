//
//  KMSwizzleton.m
//  KMSwizzleton
//
//  Created by Kasper Munck on 5/20/13.
//  Copyright (c) 2013 Kasper Munck. All rights reserved.
//

#import <objc/runtime.h>
#import <objc/objc-runtime.h>
#import "KMSwizzleton.h"

@implementation KMSwizzleton

static id _fakeInstance = nil;
static id _realInstance = nil;
static Class _realClass = nil;

+ (void)stubSingleton:(Class)singletonClass andReturnFakeInstance:(id)fakeInstance {
    // respondsToSelector sent to a Class fails if sharedInstance is an instance method and not a class method.
    // see: http://stackoverflow.com/questions/16678141/why-do-class-respondstoselector-and-respondstoselector-behave-different-when-sen
    NSAssert([singletonClass respondsToSelector:@selector(sharedInstance)], nil);
    
    _realClass = singletonClass;
    _realInstance = objc_msgSend(_realClass, @selector(sharedInstance));
    _fakeInstance = fakeInstance;
    
    [self swizzleClassMethod:@selector(sharedInstance)
                     inRealClass:singletonClass
             withClassMethod:@selector(fakeSharedInstance)
                     inFakeClass:[self class]];
}

+ (id)fakeSharedInstance {
    [KMSwizzleton revert];
    return _fakeInstance;
}

+ (void)revert {
    [self swizzleClassMethod:@selector(sharedInstance)
                 inRealClass:_realClass
             withClassMethod:@selector(fakeSharedInstance)
                 inFakeClass:[self class]];

//    _fakeInstance = nil;
    _realInstance = nil;
    _realClass = nil;
}

+ (void)swizzleClassMethod:(SEL)orig inRealClass:(Class)origClass withClassMethod:(SEL)new inFakeClass:(Class)newClass {
    Method origMethod = class_getClassMethod(origClass, orig);
    Method newMethod = class_getClassMethod(newClass, new);
    if(class_addMethod(origClass, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(origClass, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}

@end
