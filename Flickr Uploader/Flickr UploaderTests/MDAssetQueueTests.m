//
//  MDAssetQueueTests.m
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 03.07.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import <XCTest/XCTest.h>
//#import "CoreData+MagicalRecord.h"
#import "MDAssetQueue.h"

@interface MDAssetQueueTests : XCTestCase
@property (strong,nonatomic) MDAssetQueue *queue;
@end

@implementation MDAssetQueueTests

#pragma mark -
#pragma mark Class setup and teardown

+(void)setUp
{
    
}

+(void)tearDown
{
}

#pragma mark -
#pragma mark Instance setup and teardown

- (void)setUp
{
    [super setUp];
    self.queue = [[MDAssetQueue alloc] init];
    [MagicalRecord setupCoreDataStackWithInMemoryStore];
}

- (void)tearDown
{
    [super tearDown];
    self.queue = nil;
    [MagicalRecord cleanUp];
}

#pragma mark -
#pragma mark addAssetToQueueIfNew

- (void)testAddAssetToQueueIfNew_addNewAssetToEmptyQueue_becomesFirstAsset
{
    ALAsset *asset = [[ALAsset alloc] init];
    [self.queue addAssetToQueueIfNew:asset];
    XCTAssertEqualObjects([self.queue firstAsset], asset,
                  @"Expected -[firstAsset] to return added asset.");
}

- (void)testAddAssetToQueueIfNew_addNewAssetToNonEmptyQueue_doesNotBecomeFirstAsset
{
    ALAsset *firstAsset = [[ALAsset alloc] init];
    ALAsset *secondAsset = [[ALAsset alloc] init];
    
    [self.queue addAssetToQueueIfNew:firstAsset];
    [self.queue addAssetToQueueIfNew:secondAsset];
    
    XCTAssertTrue([self.queue firstAsset] == firstAsset,
                  @"Expected -[firstAsset] to return the first asset.");
}

- (void)testAddAssetToQueueIfNew_addSameAssetTwiceInSameCoreDataSession_addsOnlyOnce
{
    ALAsset *asset = [[ALAsset alloc] init];

    [self.queue addAssetToQueueIfNew:asset];
    [self.queue addAssetToQueueIfNew:asset];
    XCTAssertEquals([self.queue count], (NSUInteger)1,
                  @"Expected -[count] to return 1 after adding same asset twice (in the same Core Data session).");
}

- (void)testAddAssetToQueueIfNew_addSameAssetTwiceInTwoCoreDataSessions_addsOnlyOnce
{
    const NSString *storeName = @"storeName";
    
    [MagicalRecord cleanUp];    // stop using the in-memory store
    [MagicalRecord setupCoreDataStackWithStoreNamed:(NSString*)storeName];

    ALAsset *asset = [[ALAsset alloc] init];
    [self.queue addAssetToQueueIfNew:asset];

    [MagicalRecord cleanUp];    // simulate a new session
    [MagicalRecord setupCoreDataStackWithStoreNamed:@"diff name on purpose to see if test works"/*(NSString*)storeName*/];
    
    [self.queue addAssetToQueueIfNew:asset];

    XCTAssertEquals([self.queue count], (NSUInteger)1, @"Expected -[count] to return 1 after adding same asset twice (in two Core Data sessions).");
    
    // cleanup and delete the store
    [MagicalRecord cleanUp];
    NSURL *url = [NSPersistentStore MR_urlForStoreName:(NSString*)storeName];
    [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
}

#pragma mark -
#pragma mark count

-(void)testCount_callOnEmptyQueue_returnsZero
{
    XCTAssertTrue([self.queue count] == 0,
                  @"Expected -[count] to return 0 in a newly initialized queue.");
}

-(void)testCount_callOnNonEmptyQueue_returnsAssetCount
{
    [self.queue addAssetToQueueIfNew:[[ALAsset alloc]init]];
    XCTAssertTrue([self.queue count] == 1,
                  @"Expected -[count] to return 1 after adding an item.");
}

#pragma mark -
#pragma mark shiftAssetFromQueue

-(void)testShiftAssetFromQueue_callOnEmptyQueue_doesNothing
{
    [self.queue shiftAssetFromQueue];
    XCTAssertEquals([self.queue count], (NSUInteger)0, @"Expected -[count] to return 0.");
}

-(void)testShiftAssetFromQueue_callOnNonEmptyQueue_removesItem
{
    ALAsset *asset = [[ALAsset alloc] init];
    [self.queue addAssetToQueueIfNew:asset];
    [self.queue shiftAssetFromQueue];
    XCTAssertEquals([self.queue count], (NSUInteger)0, @"Expected -[count] to return 0.");
}

#pragma mark -
#pragma mark firstAsset

-(void)testFirstAsset_callOnEmptyQueue_returnsNil
{
    XCTAssertNil([self.queue firstAsset], @"Expected -[firstAsset] to return nil on an empty queue.");
}

-(void)testFirstAsset_callOnQueueWithTwoItems_returnsFirstItem
{
    ALAsset *firstItem = [[ALAsset alloc] init];
    ALAsset *secondItem = [[ALAsset alloc] init];
    
    [self.queue addAssetToQueueIfNew:firstItem];
    [self.queue addAssetToQueueIfNew:secondItem];
    
    XCTAssertEqualObjects([self.queue firstAsset], firstItem,
                          @"Expected -[firstAsset] to return firstItem.");
}

#pragma mark -
#pragma mark moveAssetFromIndex

-(void)testMoveAssetFromIndex_moveFrom0To1InTwoItemQueue_swapsItemsReturnsYES
{
    ALAsset *firstItem = [[ALAsset alloc] init];
    ALAsset *secondItem = [[ALAsset alloc] init];
    
    [self.queue addAssetToQueueIfNew:firstItem];
    [self.queue addAssetToQueueIfNew:secondItem];
    
    XCTAssertTrue([self.queue moveAssetFromIndex:0 toIndex:1],
                  @"Expected -[moveAssetFromIndex:toIndex:] to return true.");
    
    XCTAssertEqualObjects([self.queue firstAsset], secondItem, @"Expected -[firstAsset] to return secondItem.");
}

-(void)testMoveAssetFromIndex_moveFrom1To0InTwoItemQueue_swapsItemsReturnsYES
{
    ALAsset *firstItem = [[ALAsset alloc] init];
    ALAsset *secondItem = [[ALAsset alloc] init];
    
    [self.queue addAssetToQueueIfNew:firstItem];
    [self.queue addAssetToQueueIfNew:secondItem];
    
    XCTAssertTrue([self.queue moveAssetFromIndex:1 toIndex:0],
                  @"Expected -[moveAssetFromIndex:toIndex:] to return true.");
    
    XCTAssertEqualObjects([self.queue firstAsset], secondItem, @"Expected -[firstAsset] to return secondItem.");
}

-(void)testMoveAssetFromIndex_moveFrom0To2InTwoItemQueue_returnsNO
{
    ALAsset *firstItem = [[ALAsset alloc] init];
    ALAsset *secondItem = [[ALAsset alloc] init];
    
    [self.queue addAssetToQueueIfNew:firstItem];
    [self.queue addAssetToQueueIfNew:secondItem];
    
    XCTAssertFalse([self.queue moveAssetFromIndex:0 toIndex:2],
                  @"Expected -[moveAssetFromIndex:toIndex:] to return false.");
    
    XCTAssertEqualObjects([self.queue firstAsset], firstItem, @"Expected -[firstAsset] to return firstItem.");
}

-(void)testMoveAssetFromIndex_moveFrom2To0InTwoItemQueue_returnsNO
{
    ALAsset *firstItem = [[ALAsset alloc] init];
    ALAsset *secondItem = [[ALAsset alloc] init];
    
    [self.queue addAssetToQueueIfNew:firstItem];
    [self.queue addAssetToQueueIfNew:secondItem];
    
    XCTAssertFalse([self.queue moveAssetFromIndex:2 toIndex:0],
                   @"Expected -[moveAssetFromIndex:toIndex:] to return false.");
    
    XCTAssertEqualObjects([self.queue firstAsset], firstItem, @"Expected -[firstAsset] to return firstItem.");
}

-(void)testMoveAssetFromIndex_moveFrom0To0InTwoItemQueue_doesNothingReturnsYES
{
    ALAsset *firstItem = [[ALAsset alloc] init];
    ALAsset *secondItem = [[ALAsset alloc] init];
    
    [self.queue addAssetToQueueIfNew:firstItem];
    [self.queue addAssetToQueueIfNew:secondItem];
    
    XCTAssertTrue([self.queue moveAssetFromIndex:0 toIndex:0],
                   @"Expected -[moveAssetFromIndex:toIndex:] to return false.");
    
    XCTAssertEqualObjects([self.queue firstAsset], firstItem, @"Expected -[firstAsset] to return firstItem.");
}


@end
