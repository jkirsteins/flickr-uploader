//
//  ALAssetCategoryMDAssetQueueTests.m
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 03.07.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ALAsset+MDAssetQueue.h"
@import AssetsLibrary;

@interface ALAssetCategoryMDAssetQueueTests : XCTestCase

@end

@implementation ALAssetCategoryMDAssetQueueTests

- (void)testMD_createOrReturnHashedIdentifier_callOnNewAsset_updatesMD_hashedIdentifierAndReturns
{
    ALAsset *asset = [[ALAsset alloc] init];
    XCTAssertNil(asset.MD_hashedIdentifier, @"Expected MD_hashedIdentifier to initially be nil.");

    NSString *hashedId = [asset MD_createOrReturnHashedIdentifier];
    XCTAssertNotNil(asset, @"Expected a non-nil hashed identifier.");
    
    XCTAssertEquals(hashedId, asset.MD_hashedIdentifier, @"Expected MD_hashedIdentifier to be set, after a previous call to -[MD_createOrReturnHashedIdentifier].");
}

- (void)testMD_createOrReturnHashedIdentifier_callOnAssetWithCreatedIdentifier_doesNotChangeExistingIdentifierAndReturns
{
    ALAsset *asset = [[ALAsset alloc] init];
    
    NSString *firstId = [asset MD_createOrReturnHashedIdentifier];
    NSString *secondId = [asset MD_createOrReturnHashedIdentifier];
    
    XCTAssertEquals(firstId, secondId, @"Expected subsequent -[MD_createOrReturnHashedIdentifier] calls to return the same value.");
}

@end
