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
    
    // Without the following line, the very first
    // test seems to fail often (but not 100%), because
    // an entity already (supposedly) exists in the in-memory store.
    //
    // Not sure what causes the bug. Leaving this here for time being.
    //
    // TODO: Get to the bottom of why this method is required
    [MagicalRecord cleanUp];
    
    [MagicalRecord setupCoreDataStackWithInMemoryStore];
    
    self.queue = [[MDAssetQueue alloc] init];
}

- (void)tearDown
{
    [super tearDown];
    self.queue = nil;
    [MagicalRecord cleanUp];
}

#pragma mark -
#pragma mark testAddAssetToQueueIfNotProcessed

- (void)testAddAssetToQueueIfNotProcessed_addNewAssetToEmptyQueue_becomesFirstAsset
{
    ALAsset *asset = [[ALAsset alloc] init];
    [self.queue addAssetToQueueIfNotProcessed:asset];
    XCTAssertEqualObjects([self.queue firstAsset], asset,
                  @"Expected -[firstAsset] to return added asset.");
}

- (void)testAddAssetToQueueIfNotProcessed_addNewAssetToNonEmptyQueue_doesNotBecomeFirstAsset
{
    ALAsset *firstAsset = [[ALAsset alloc] init];
    ALAsset *secondAsset = [[ALAsset alloc] init];
    
    [self.queue addAssetToQueueIfNotProcessed:firstAsset];
    [self.queue addAssetToQueueIfNotProcessed:secondAsset];
    
    XCTAssertTrue([self.queue firstAsset] == firstAsset,
                  @"Expected -[firstAsset] to return the first asset.");
}

- (void)testAddAssetToQueueIfNotProcessed_addProcessedAssetToSameQueueInstance_addsOnlyOnce
{
    ALAsset *asset = [[ALAsset alloc] init];

    [self.queue addAssetToQueueIfNotProcessed:asset];
    [self.queue shiftAssetAndMarkProcessed];
    [self.queue addAssetToQueueIfNotProcessed:asset];
    XCTAssertEquals([self.queue count], (NSUInteger)0,
                  @"Expected -[count] to return 1 after adding same asset twice (in the same Core Data session).");
}

- (void)testAddAssetToQueueIfNotProcessed_addProcessedAssetToDifferentQueueInstances_addsOnlyOnce
{
    ALAsset *asset = [[ALAsset alloc] init];
    [self.queue addAssetToQueueIfNotProcessed:asset];
    [self.queue shiftAssetAndMarkProcessed];
    
    MDAssetQueue *queue2 = [[MDAssetQueue alloc] init];
    [queue2 addAssetToQueueIfNotProcessed:asset];

    XCTAssertEquals([queue2 count], (NSUInteger)0, @"Expected -[count] to return 0 after adding an asset that was processed in a different MDAssetQueue instance.");
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
    [self.queue addAssetToQueueIfNotProcessed:[[ALAsset alloc]init]];
    XCTAssertTrue([self.queue count] == 1,
                  @"Expected -[count] to return 1 after adding an item.");
}

#pragma mark -
#pragma mark shiftAssetFromQueue

-(void)testShiftAssetFromQueue_callOnEmptyQueue_doesNothing
{
    [self.queue shiftAssetAndMarkProcessed];
    XCTAssertEquals([self.queue count], (NSUInteger)0, @"Expected -[count] to return 0.");
}

-(void)testShiftAssetFromQueue_callOnNonEmptyQueue_removesItem
{
    ALAsset *asset = [[ALAsset alloc] init];
    [self.queue addAssetToQueueIfNotProcessed:asset];
    [self.queue shiftAssetAndMarkProcessed];
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
    
    [self.queue addAssetToQueueIfNotProcessed:firstItem];
    [self.queue addAssetToQueueIfNotProcessed:secondItem];
    
    XCTAssertEqualObjects([self.queue firstAsset], firstItem,
                          @"Expected -[firstAsset] to return firstItem.");
}

#pragma mark -
#pragma mark moveAssetFromIndex

-(void)testMoveAssetFromIndex_moveFrom0To1InTwoItemQueue_swapsItemsReturnsYES
{
    ALAsset *firstItem = [[ALAsset alloc] init];
    ALAsset *secondItem = [[ALAsset alloc] init];
    
    [self.queue addAssetToQueueIfNotProcessed:firstItem];
    [self.queue addAssetToQueueIfNotProcessed:secondItem];
    
    XCTAssertTrue([self.queue moveAssetFromIndex:0 toIndex:1],
                  @"Expected -[moveAssetFromIndex:toIndex:] to return true.");
    
    XCTAssertEqualObjects([self.queue firstAsset], secondItem, @"Expected -[firstAsset] to return secondItem.");
}

-(void)testMoveAssetFromIndex_moveFrom1To0InTwoItemQueue_swapsItemsReturnsYES
{
    ALAsset *firstItem = [[ALAsset alloc] init];
    ALAsset *secondItem = [[ALAsset alloc] init];
    
    [self.queue addAssetToQueueIfNotProcessed:firstItem];
    [self.queue addAssetToQueueIfNotProcessed:secondItem];
    
    XCTAssertTrue([self.queue moveAssetFromIndex:1 toIndex:0],
                  @"Expected -[moveAssetFromIndex:toIndex:] to return true.");
    
    XCTAssertEqualObjects([self.queue firstAsset], secondItem, @"Expected -[firstAsset] to return secondItem.");
}

-(void)testMoveAssetFromIndex_moveFrom0To2InTwoItemQueue_returnsNO
{
    ALAsset *firstItem = [[ALAsset alloc] init];
    ALAsset *secondItem = [[ALAsset alloc] init];
    
    [self.queue addAssetToQueueIfNotProcessed:firstItem];
    [self.queue addAssetToQueueIfNotProcessed:secondItem];
    
    XCTAssertFalse([self.queue moveAssetFromIndex:0 toIndex:2],
                  @"Expected -[moveAssetFromIndex:toIndex:] to return false.");
    
    XCTAssertEqualObjects([self.queue firstAsset], firstItem, @"Expected -[firstAsset] to return firstItem.");
}

-(void)testMoveAssetFromIndex_moveFrom2To0InTwoItemQueue_returnsNO
{
    ALAsset *firstItem = [[ALAsset alloc] init];
    ALAsset *secondItem = [[ALAsset alloc] init];
    
    [self.queue addAssetToQueueIfNotProcessed:firstItem];
    [self.queue addAssetToQueueIfNotProcessed:secondItem];
    
    XCTAssertFalse([self.queue moveAssetFromIndex:2 toIndex:0],
                   @"Expected -[moveAssetFromIndex:toIndex:] to return false.");
    
    XCTAssertEqualObjects([self.queue firstAsset], firstItem, @"Expected -[firstAsset] to return firstItem.");
}

-(void)testMoveAssetFromIndex_moveFrom0To0InTwoItemQueue_doesNothingReturnsYES
{
    ALAsset *firstItem = [[ALAsset alloc] init];
    ALAsset *secondItem = [[ALAsset alloc] init];
    
    [self.queue addAssetToQueueIfNotProcessed:firstItem];
    [self.queue addAssetToQueueIfNotProcessed:secondItem];
    
    XCTAssertTrue([self.queue moveAssetFromIndex:0 toIndex:0],
                   @"Expected -[moveAssetFromIndex:toIndex:] to return false.");
    
    XCTAssertEqualObjects([self.queue firstAsset], firstItem, @"Expected -[firstAsset] to return firstItem.");
}


@end
