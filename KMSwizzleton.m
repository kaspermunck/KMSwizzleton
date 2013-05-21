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
    NSAssert([singletonClass respondsToSelector:@selector(sharedInstance)], nil);
    
    _realClass = singletonClass;
    _realInstance = objc_msgSend(_realClass, @selector(sharedInstance));
    _fakeInstance = fakeInstance;
    
    [self swizzleClassMethod:@selector(sharedInstance)
                     inClass:singletonClass
             withClassMethod:@selector(fakeSharedInstance)
                     inClass:[self class]];
}

+ (id)fakeSharedInstance {
//    [KMSwizzleton revert];
    return _fakeInstance;
}

+ (void)revert {
    [self swizzleClassMethod:@selector(sharedInstance)
                     inClass:_realClass
             withClassMethod:@selector(fakeSharedInstance)
                     inClass:[self class]];
    
    _fakeInstance = nil;
    _realInstance = nil;
    _realClass = nil;
}

+ (void)swizzleClassMethod:(SEL)orig inClass:(Class)origClass withClassMethod:(SEL)new inClass:(Class)newClass {
    Method origMethod = class_getClassMethod(origClass, orig);
    Method newMethod = class_getClassMethod(newClass, new);
    if(class_addMethod(origClass, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(origClass, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}

@end
