//
//  KMSwizzleton.h
//  KMSwizzleton
//
//  Created by Kasper Munck on 5/20/13.
//  Copyright (c) 2013 Kasper Munck. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KMSwizzleton : NSObject

+ (void)stubSingleton:(Class)singletonClass andReturnFakeInstance:(id)fakeInstance;
+ (void)revert;

@end
