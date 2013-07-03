//
//  MDAssetQueueTests.m
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 03.07.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CoreData+MagicalRecord.h"

@interface MDAssetQueueTests : XCTestCase

@end

@implementation MDAssetQueueTests

+(void)tearDown
{
    NSURL *url = [NSPersistentStore MR_urlForStoreName:@"assetQueueTestStore"];
    [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
}

- (void)setUp
{
    [super setUp];
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"assetQueueTestStore"];

    NSURL *url =     [NSPersistentStore MR_urlForStoreName:@"assetQueueTestStore"];;
    NSLog(@"%@", url);
}

- (void)tearDown
{
    [super tearDown];
    [MagicalRecord cleanUp];
}

- (void)testFirstRun
{
    XCTAssertTrue(true, @"true should be true");
}

@end
