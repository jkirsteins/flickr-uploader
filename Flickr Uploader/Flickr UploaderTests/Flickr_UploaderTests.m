//
//  Flickr_UploaderTests.m
//  Flickr UploaderTests
//
//  Created by Jānis Kiršteins on 11.06.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

@interface Flickr_UploaderTests : XCTestCase

@end

@protocol AuthenticationServiceProtocol

- (void)loginWithEmail:(NSString *)email andPassword:(NSString *)password;

@end

@interface Foo : NSObject
{
    id<AuthenticationServiceProtocol> authService;
}

- (id)initWithAuthenticationService:(id<AuthenticationServiceProtocol>)anAuthService;
- (void)doStuff;

@end

@implementation Foo

- (id)initWithAuthenticationService:(id<AuthenticationServiceProtocol>)anAuthService
{
    self = [super init];
    authService = anAuthService;
    return self;
}

- (void)doStuff
{
    [authService loginWithEmail:@"y" andPassword:@"y"];
}

@end 

@implementation Flickr_UploaderTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    id authService = [OCMockObject mockForProtocol:@protocol(AuthenticationServiceProtocol)];
    id foo = [[Foo alloc] initWithAuthenticationService:authService];
    
    [[authService expect] loginWithEmail:@"y" andPassword:[OCMArg any]];
    //XCTAssertTrue(false, @"false should be true");
    
    [foo doStuff];
    
    [authService verify];
}

@end
