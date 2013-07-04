//
//  MDAssetImageCacheTests.m
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 03.07.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "OCMockRecorder+ExtraMethods.h"
#import "MDAssetImageCache.h"
@import AssetsLibrary;

#define MOCK_ASSET_WIDTH 128
#define MOCK_ASSET_HEIGHT 128

/*!
   @var mockAssetWithImage
   @abstract
     A mock ALAsset* instance with stubbed method -[defaultRepresentation], 
     which in turn has a stubbed method -[fullResolutionImage].
 */
static ALAsset *mockAssetWithImage;

/*!
   @class MDAssetImageCacheTests
   @abstract
     Tests for MDAssetImageCache class.
 */
@interface MDAssetImageCacheTests : XCTestCase

/*!
   @property cache
   @abstract
     An instance of MDAssetImageCache, for use in tests. It is instantiated
     anew for every test.
 */
@property (strong,nonatomic) MDAssetImageCache *cache;
@end

@implementation MDAssetImageCacheTests

#pragma mark -
#pragma mark Class setup and teardown

/*!
   @method generateTestImage
   @abstract Generates a blank CGImageRef object that is returned from a mock
   ALAssetRepresentation object.
 */
+(CGImageRef)generateTestImage
{
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef _composedImageContext = CGBitmapContextCreate(NULL,
                                                               MOCK_ASSET_WIDTH,
                                                               MOCK_ASSET_HEIGHT,
                                                               8,
                                                               MOCK_ASSET_WIDTH*4,
                                                               rgbColorSpace,
                                                               (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease( rgbColorSpace );
    
    
    // ...
    
    CGImageRef cgImage = CGBitmapContextCreateImage(_composedImageContext);
    return cgImage;
}

/*!
   @method setUp
   @abstract
     Class setup method that sets up the mock ALAsset* object.
 */
+ (void)setUp
{
    CGImageRef testImage = [MDAssetImageCacheTests generateTestImage];    
    id mockedAssetRepresentation = [OCMockObject mockForClass:[ALAssetRepresentation class]];
    
    [[[mockedAssetRepresentation stub] andReturnStruct:testImage objCType:"CGImageRef"] fullResolutionImage];

    id mockedAsset = [OCMockObject mockForClass:[ALAsset class]];
    [[[mockedAsset stub] andReturn:mockedAssetRepresentation] defaultRepresentation];
    
    mockAssetWithImage = mockedAsset;
}

/*!
   @method tearDown
   @abstract
     Class teardown method that releases a reference to the mock ALAsset* object.
 */
+(void)tearDown
{
    mockAssetWithImage = nil;
}

#pragma mark -
#pragma mark Instance setup and teardown

/*!
   @method setUp
   @abstract
     Instance setup method that sets up the Core Data stack with an in-memory store,
     and initializes the self.cache property.
 */
- (void)setUp
{
    [MagicalRecord cleanUp];
    [MagicalRecord setupCoreDataStackWithInMemoryStore];
    
    self.cache = [[MDAssetImageCache alloc] init];
}

/*!
   @method tearDown
   @abstract
     Instance teardown method that cleans up after MagicalRecord and releases
     the reference to self.cache.
 */
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
    [self.cache thumbnailForAsset:mockAssetWithImage withWidth:MOCK_ASSET_WIDTH andHeight:MOCK_ASSET_HEIGHT];
    
    XCTAssertTrue([self.cache thumbnailExistsForAsset:mockAssetWithImage withWidth:MOCK_ASSET_WIDTH andHeight:MOCK_ASSET_HEIGHT inMemory:YES andPersistentCache:YES],
                  @"Expected the mock asset to be cached in both memory and the persistent store.");
    [self.cache purgeThumbnailsForAsset:mockAssetWithImage];
    
    XCTAssertTrue([self.cache thumbnailExistsForAsset:mockAssetWithImage withWidth:MOCK_ASSET_WIDTH andHeight:MOCK_ASSET_HEIGHT inMemory:NO andPersistentCache:NO],
                  @"Expected the mock asset to be absent from both memory and the persistent store.");
}

- (void)testPurgeThumbnailsForAsset_assetInPersistentCacheOnly_removesFromPersistentCache
{
    [self.cache thumbnailForAsset:mockAssetWithImage withWidth:MOCK_ASSET_WIDTH andHeight:MOCK_ASSET_HEIGHT];
    [self.cache clearMemoryCache];
    
    XCTAssertTrue([self.cache thumbnailExistsForAsset:mockAssetWithImage withWidth:MOCK_ASSET_WIDTH andHeight:MOCK_ASSET_HEIGHT inMemory:NO andPersistentCache:YES],
                  @"Expected the mock asset to be cached only in the persistent store.");
    [self.cache purgeThumbnailsForAsset:mockAssetWithImage];
    
    XCTAssertTrue([self.cache thumbnailExistsForAsset:mockAssetWithImage withWidth:MOCK_ASSET_WIDTH andHeight:MOCK_ASSET_HEIGHT inMemory:NO andPersistentCache:NO],
                  @"Expected the mock asset to be absent from both memory and the persistent store.");
}

#pragma mark -
#pragma mark clearMemoryCache:

- (void)testClearMemoryCache_emptyCache_doesNothing
{
    XCTAssertNoThrow([self.cache clearMemoryCache], @"Expected -[clearMemoryCache] to not throw anything.");
}

- (void)testClearMemoryCache_containsCachedAsset_clearsMemoryCache
{
    [self.cache thumbnailForAsset:mockAssetWithImage withWidth:MOCK_ASSET_WIDTH andHeight:MOCK_ASSET_HEIGHT];
    XCTAssertTrue([self.cache thumbnailExistsForAsset:mockAssetWithImage withWidth:MOCK_ASSET_WIDTH andHeight:MOCK_ASSET_HEIGHT inMemory:YES andPersistentCache:YES],
                  @"Expected the mock asset to be cached in both memory and the persistent store.");

    [self.cache clearMemoryCache];
    
    XCTAssertTrue([self.cache thumbnailExistsForAsset:mockAssetWithImage withWidth:MOCK_ASSET_WIDTH andHeight:MOCK_ASSET_HEIGHT inMemory:NO andPersistentCache:YES],
                  @"Expected the mock asset to be cached only in the persistent store.");

}

#pragma mark -
#pragma mark thumbnailForAsset:withWidth:andHeight:

- (void)testThumbnailForAssetWithWidthAndHeight_nilAsset_returnsNil
{
    XCTAssertNil([self.cache thumbnailForAsset:nil
                                     withWidth:MOCK_ASSET_WIDTH
                                     andHeight:MOCK_ASSET_HEIGHT],
                 @"Expected -[thumbnailForAsset:withWidth:andHeight:] to return nil, when given a nil asset.");
}

- (void)testThumbnailForAssetWithWidthAndHeight_zeroSize_returnsNil
{
    XCTAssertNil([self.cache thumbnailForAsset:mockAssetWithImage
                                     withWidth:0
                                     andHeight:0],
                 @"Expected -[thumbnailForAsset:withWidth:andHeight:] to return nil, when given 0 size.");
}

- (void)testThumbnailForAssetWithWidthAndHeight_largerSizeThanOriginal_returnsNil
{
    // TODO: decide if this method shouldn't return a scaled-up version?
    XCTAssertNil([self.cache thumbnailForAsset:mockAssetWithImage
                                     withWidth:MOCK_ASSET_WIDTH*2
                                     andHeight:MOCK_ASSET_HEIGHT*2],
                 @"Expected -[thumbnailForAsset:withWidth:andHeight:] to return nil, when given larger size than the original.");
}

- (void)testThumbnailForAssetWithWidthAndHeight_validAssetHalfSize_returnsCorrectSizeImage
{
    UIImage *img = [self.cache thumbnailForAsset:mockAssetWithImage
                                       withWidth:MOCK_ASSET_WIDTH/2
                                       andHeight:MOCK_ASSET_HEIGHT/2];
    XCTAssertNotNil(img, @"Expected result to not be nil.");
    XCTAssertEquals(img.size.width, MOCK_ASSET_WIDTH/2, @"Expected resulting image width to equal MOCK_ASSET_WIDTH/2");
    XCTAssertEquals(img.size.height, MOCK_ASSET_HEIGHT/2, @"Expected resulting image height to equal MOCK_ASSET_HEIGHT/2");
}

#pragma mark -
#pragma mark thumbnailExistsForAsset:withWidth:andHeight:inMemory:andPersistentCache:

-(void)testThumbnailExistsForAssetWithWidthAndHeightInMemoryAndPersistentCache_sameAssetInTwoCacheInstances_returnsBothCachesInFirstInstanceAndOnlyPersistentInSecondInstance
{
    [self.cache thumbnailForAsset:mockAssetWithImage
                        withWidth:MOCK_ASSET_WIDTH
                        andHeight:MOCK_ASSET_HEIGHT];
    
    XCTAssertTrue([self.cache thumbnailExistsForAsset:mockAssetWithImage
                                            withWidth:MOCK_ASSET_WIDTH
                                            andHeight:MOCK_ASSET_HEIGHT
                                             inMemory:YES
                                   andPersistentCache:YES],
                  @"Expected the asset thumbnail to be cached in both memory and the persistent store of the first cache instance.");
    
    MDAssetImageCache *cache2 = [[MDAssetImageCache alloc] init];
    XCTAssertTrue([self.cache2 thumbnailExistsForAsset:mockAssetWithImage
                                            withWidth:MOCK_ASSET_WIDTH
                                            andHeight:MOCK_ASSET_HEIGHT
                                             inMemory:NO
                                   andPersistentCache:YES],
                  @"Expected the asset thumbnail to be cached in only the persistent store of the second cache instance.");
}

-(void)testThumbnailExistsForAssetWithWidthAndHeightInMemoryAndPersistentCache_nilAsset_returnsNO
{
    XCTAssertFalse([self.cache thumbnailExistsForAsset:nil
                                            withWidth:MOCK_ASSET_WIDTH
                                            andHeight:MOCK_ASSET_HEIGHT
                                             inMemory:YES
                                   andPersistentCache:YES],
                  @"Expected the function to return NO when given nil asset.");
}

-(void)testThumbnailExistsForAssetWithWidthAndHeightInMemoryAndPersistentCache_uninsertedAsset_returnsNO
{
    XCTAssertFalse([self.cache thumbnailExistsForAsset:mockAssetWithImage
                                             withWidth:MOCK_ASSET_WIDTH
                                             andHeight:MOCK_ASSET_HEIGHT
                                              inMemory:YES
                                    andPersistentCache:YES],
                   @"Expected the function to return NO when given uncached asset.");
}

@end
