//
//  MDAssetImageCacheTests.m
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 03.07.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MDAssetImageCache.h"
@import AssetsLibrary;

@interface MDAssetImageCacheTests : XCTestCase
@property (strong,nonatomic) MDAssetImageCache *cache;
@end

@implementation MDAssetImageCacheTests

#pragma mark -
#pragma mark Instance setup and teardown

- (void)setUp
{
    [MagicalRecord cleanUp];
    [MagicalRecord setupCoreDataStackWithInMemoryStore];
    
    self.cache = [[MDAssetImageCache alloc] init];
}

- (void)tearDown
{
    self.cache = nil;
    
    [MagicalRecord cleanUp];
}

#pragma mark -
#pragma mark purgeThumbnailsForAsset:

- (void)testPurgeThumbnailsForAsset_nonCachedAsset_doesNothing
{
    ALAsset *asset = [[ALAsset alloc] init];
    XCTAssertNoThrow([self.cache purgeThumbnailsForAsset:asset],
                     @"Expected -[purgeThumbnailsForAsset] to not throw an exception when given an un-cached asset.");
}

- (void)testPurgeThumbnailsForAsset_fullyCachedAsset_removesFromMemoryAndPersistentCache
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testPurgeThumbnailsForAsset_assetInMemoryCacheOnly_removesFromMemoryCache
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testPurgeThumbnailsForAsset_assetInPersistentCacheOnly_removesFromPersistentCache
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

#pragma mark -
#pragma mark clearMemoryCache:

- (void)testClearMemoryCache_emptyCache_doesNothing
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testClearMemoryCache_containsCachedAsset_clearsMemoryCache
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

#pragma mark -
#pragma mark thumbnailForAsset:withWidth:andHeight:

- (void)testThumbnailForAssetWithWidthAndHeight_nilAsset_returnsNil
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testThumbnailForAssetWithWidthAndHeight_zeroWidth_returnsNil
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testThumbnailForAssetWithWidthAndHeight_zeroHeight_returnsNil
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testThumbnailForAssetWithWidthAndHeight_largerWidthThanOriginal_returnsNil
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testThumbnailForAssetWithWidthAndHeight_largerHeightThanOriginal_returnsNil
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testThumbnailForAssetWithWidthAndHeight_validAssetHalfSize_returnsCorrectSizeImage
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

#pragma mark -
#pragma mark thumbnailExistsForAsset:withWidth:andHeight:inMemory:andPersistentCache:

-(void)testThumbnailExistsForAssetWithWidthAndHeightInMemoryAndPersistentCache_sameAssetInTwoCacheInstances_returnsBothCachesInFirstInstanceAndOnlyPersistentInSecondInstance
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

-(void)testThumbnailExistsForAssetWithWidthAndHeightInMemoryAndPersistentCache_nilAsset_returnsNO
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

-(void)testThumbnailExistsForAssetWithWidthAndHeightInMemoryAndPersistentCache_uninsertedAsset_returnsNO
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

-(void)testThumbnailExistsForAssetWithWidthAndHeightInMemoryAndPersistentCache_newAssetInBothCaches_returnsYES
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

-(void)testThumbnailExistsForAssetWithWidthAndHeightInMemoryAndPersistentCache_newAssetInPersistentCacheOnlyAfterClearMemoryCache_returnsYES
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
