# KMSwizzleton

An attempt to make unit testing of singleton classes easier.

## Testing Singletons

The Singleton Design Pattern is a great one when applied following a few [best practices](http://jason.agostoni.net/2012/01/22/ios-best-practices-singletons/). However, unit testing singleton classes is a pain in the ass. I have seen a few decent approaches, such as [property injection](http://twobitlabs.com/2013/01/objective-c-singleton-pattern-unit-testing/) and [overriding using a category](http://stackoverflow.com/questions/5508088/objective-c-category-to-modify-a-singleton-object), but I still find it a hassle to test singletons.

## A New Approach

KMSwizzleton is an attempt to make testing of singletons easier. But beware! It is not thoroughly tested and lacks a few things (see TODO). Here's a sample:

````
// singleton class to test
@interface MySingleton : NSObject
+ (MySingleton *)sharedInstance;
@end

// a classes that uses the singleton
@implementation SomeClassTotest 
- (void)someMethod {
	[[MySingleton sharedInstance] somethingAwesome];
}
...

// test class
- (void)testSingletonSomething {
	id fakeSingleton = … // use favorite mock lib here
	[fakeSingleton expect:somethingAwesome] // behavior that before was very difficult to verify
	
	[KMSwizzleton stubSingleton:[MySingleton class] andReturnFakeInstance:fakeSingleton];
	
	SomeClassToTest *cut = [[SomeClassToTest alloc] init];
	[cut someMethod];
	
	// we can now verify whether cut called somethingAwesome on MySingleton or not
	[fakeSingleton verify];
}

````

NB: It is assumed that singleton classes follow the [sharedInstance pattern](http://www.daveoncode.com/2011/12/19/fundamental-ios-design-patterns-sharedinstance-singleton-objective-c/).

## TODO
- Automatically revert swizzling after `+sharedInstance` has been invoked.
- Ability to specify the name of the singleton's instance method when it doesn't follow the sharedInstance-pattern, such as `[NSNotificationCenter defaultcenter]`.
- Support for inheritance.
