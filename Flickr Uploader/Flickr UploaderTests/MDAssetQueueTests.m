//
//  MDAssetQueueTests.m
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 03.07.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MDAssetQueue.h"
#import <OCMock/OCMock.h>

@interface MDAssetQueueTests : XCTestCase
@property (strong,nonatomic) NSOperationQueue *operationQueue;
@property (strong,nonatomic) MDAssetQueue *queue;
@property (strong,nonatomic) MDAssetVerificationOperation *lastOperation;
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

- (void)addOperation:(MDAssetVerificationOperation*)operation
{
    self.lastOperation = operation;
}

- (void)setUp
{
    [super setUp];
    
    id verificationQueue = [OCMockObject mockForClass:[NSOperationQueue class]];
    [[[verificationQueue stub] andCall:@selector(addOperation:) onObject:self] addOperation:[OCMArg any]];
    self.operationQueue = verificationQueue;
    
    // Without the following line, the very first
    // test seems to fail often (but not 100%), because
    // an entity already (supposedly) exists in the in-memory store.
    //
    // Not sure what causes the bug. Leaving this here for time being.
    //
    // TODO: Get to the bottom of why this method is required
//    [MagicalRecord cleanUp];
    
    [MagicalRecord setupCoreDataStackWithInMemoryStore];
    
    self.queue = [[MDAssetQueue alloc] initWithVerificationQueue:verificationQueue];
}

- (void)tearDown
{
    [super tearDown];
    self.queue = nil;
    [MagicalRecord cleanUp];
}

#pragma mark -
#pragma mark beginAddingAsset:

-(void)testBeginAddingAsset_addNewAsset_startsVerificationOperation
{
    ALAsset *asset = [[ALAsset alloc] init];
    [self.queue beginAddingAsset:asset];
  
    MDAssetVerificationOperation *op = self.lastOperation;
    
    XCTAssertEqualObjects(op.asset, asset, @"Expected the op asset to be the same object as added asset.");
}

-(void)testBeginAddingAsset_addNilAsset_callsDelegateFailureInCurrentThread
{
    id delegate = [OCMockObject mockForProtocol:@protocol(MDAssetQueueDelegate)];
    [[delegate expect] didNotAddAsset:nil];
    
    self.queue.delegate = delegate;
    
    [self.queue beginAddingAsset:nil];
    
    [delegate verify];
    XCTAssertNil(self.lastOperation, @"Did not expect an operation to be created.");
}

-(void)testBeginAddingAsset_addAssetWhenDelegateMissingOptional_optionalDelegateFailureNotInvoked
{
    id delegate = [OCMockObject mockForClass:[NSObject class]];
    self.queue.delegate = delegate;
    [self.queue beginAddingAsset:nil];
    
    [delegate verify];
    XCTAssertNil(self.lastOperation, @"Did not expect an operation to be created.");
}

#pragma mark -
#pragma mark waitUntilAllOperationsAreFinished

-(void)testWaitUntilAllOperationsAreFinished_invoke_forwardsToOperationQueue
{
    [[(id)self.operationQueue expect] waitUntilAllOperationsAreFinished];
    [self.queue waitUntilAllOperationsAreFinished];
    [(id)self.operationQueue verify];
}

#pragma mark -
#pragma mark didVerifyAsset:canAddToQueue:

-(void)testDidVerifyAsset_canAddToQueue_addsToQueue
{
    ALAsset *asset = [[ALAsset alloc] init];
    [self.queue didVerifyAsset:asset canAddToQueue:YES];
    XCTAssertEqualObjects(asset,
                          [self.queue assetWithIndexOrNil:0],
                          @"Expected added asset to be the first queue asset.");
}

-(void)testDidVerifyAsset_canAddToQueue_invokesDelegate
{
    ALAsset *asset = [[ALAsset alloc] init];
    id delegate = [OCMockObject mockForProtocol:@protocol(MDAssetQueueDelegate)];
    [[delegate expect] didFinishAddingAsset:asset withIndex:0];
    self.queue.delegate = delegate;
    [self.queue didVerifyAsset:asset canAddToQueue:YES];
    
    [delegate verify];
}

-(void)testDidVerifyAsset_canNotAddToQueue_doesNotAddToQueue
{
    ALAsset *asset = [[ALAsset alloc] init];
    id delegate = [OCMockObject mockForProtocol:@protocol(MDAssetQueueDelegate)];
    self.queue.delegate = delegate;
    [self.queue didVerifyAsset:asset canAddToQueue:NO];
    
    [delegate verify];
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
    ALAsset *asset = [[ALAsset alloc] init];
    [self.queue didVerifyAsset:asset canAddToQueue:YES];
    [self.queue didVerifyAsset:asset canAddToQueue:YES];
    
    XCTAssertEquals(self.queue.count, (uint)2, @"Expected -[count] to return 2.");
}

#pragma mark -
#pragma mark shiftAssetAndMarkProcessed

-(void)testShiftAssetAndMarkProcessed_callOnEmptyQueue_doesNothing
{
    [self.queue shiftAssetAndMarkProcessed];
    XCTAssertEquals([self.queue count], (NSUInteger)0, @"Expected -[count] to return 0.");
}

-(void)testShiftAssetAndMarkProcessed_callOnNonEmptyQueue_removesItem
{
    ALAsset *asset = [[ALAsset alloc] init];
    [self.queue didVerifyAsset:asset canAddToQueue:YES];
    [self.queue shiftAssetAndMarkProcessed];
    XCTAssertEquals([self.queue count], (NSUInteger)0, @"Expected -[count] to return 0 after shifting the only asset in queue.");
}

#pragma mark -
#pragma mark assetWithIndexOrNil:

-(void)testAssetWithIndexOrNil_callOnEmptyQueue_returnsNil
{
    XCTAssertNil([self.queue assetWithIndexOrNil:0], @"Expected -[assetWithIndexOrNil:0] to return nil on an empty queue.");
}

-(void)testAssetWithIndexOrNil_callWithTooGreatIndex_returnsNil
{
    ALAsset *asset =[[ALAsset alloc] init];
    [self.queue didVerifyAsset:asset canAddToQueue:YES];
    XCTAssertNil([self.queue assetWithIndexOrNil:1], @"Expected -[firstAsset] to return nil when index is too high.");
}

-(void)testAssetWithIndexOrNil_callIndex1When2Assets_returnsSecondAsset
{
    ALAsset *firstItem = [[ALAsset alloc] init];
    ALAsset *secondItem = [[ALAsset alloc] init];
    
    [self.queue didVerifyAsset:firstItem canAddToQueue:YES];
    [self.queue didVerifyAsset:secondItem canAddToQueue:YES];
    
    XCTAssertEqualObjects([self.queue assetWithIndexOrNil:1], secondItem,
                          @"Expected -[assetWithIndexOrNil:1] to return secondItem.");
    
}

#pragma mark -
#pragma mark moveAssetFromIndex:toIndex:

-(void)testMoveAsset_moveFrom0To1InTwoItemQueue_swapsItemsReturnsYES
{
    ALAsset *firstItem = [[ALAsset alloc] init];
    ALAsset *secondItem = [[ALAsset alloc] init];
    
    [self.queue didVerifyAsset:firstItem canAddToQueue:YES];
    [self.queue didVerifyAsset:secondItem canAddToQueue:YES];
    
    XCTAssertTrue([self.queue moveAssetFromIndex:0 toIndex:1],
                  @"Expected -[moveAssetFromIndex:toIndex:] to return true.");
    
    XCTAssertEqualObjects([self.queue assetWithIndexOrNil:0], secondItem, @"Expected -[firstAsset] to return secondItem.");
}

-(void)testMoveAsset_moveFrom1To0InTwoItemQueue_swapsItemsReturnsYES
{
    ALAsset *firstItem = [[ALAsset alloc] init];
    ALAsset *secondItem = [[ALAsset alloc] init];
    
    [self.queue didVerifyAsset:firstItem canAddToQueue:YES];
    [self.queue didVerifyAsset:secondItem canAddToQueue:YES];
    
    XCTAssertTrue([self.queue moveAssetFromIndex:1 toIndex:0],
                  @"Expected -[moveAssetFromIndex:toIndex:] to return true.");
    
    XCTAssertEqualObjects([self.queue assetWithIndexOrNil:0], secondItem, @"Expected -[firstAsset] to return secondItem.");
}

-(void)testMoveAsset_moveFrom0To2InTwoItemQueue_returnsNO
{
    ALAsset *firstItem = [[ALAsset alloc] init];
    ALAsset *secondItem = [[ALAsset alloc] init];
    
    [self.queue didVerifyAsset:firstItem canAddToQueue:YES];
    [self.queue didVerifyAsset:secondItem canAddToQueue:YES];
    
    XCTAssertFalse([self.queue moveAssetFromIndex:0 toIndex:2],
                  @"Expected -[moveAssetFromIndex:toIndex:] to return false.");
    
    XCTAssertEqualObjects([self.queue assetWithIndexOrNil:0], firstItem, @"Expected -[firstAsset] to return firstItem.");
}

-(void)testMoveAsset_moveFrom2To0InTwoItemQueue_returnsNO
{
    ALAsset *firstItem = [[ALAsset alloc] init];
    ALAsset *secondItem = [[ALAsset alloc] init];
    
    [self.queue didVerifyAsset:firstItem canAddToQueue:YES];
    [self.queue didVerifyAsset:secondItem canAddToQueue:YES];
    
    XCTAssertFalse([self.queue moveAssetFromIndex:2 toIndex:0],
                   @"Expected -[moveAssetFromIndex:toIndex:] to return false.");
    
    XCTAssertEqualObjects([self.queue assetWithIndexOrNil:0], firstItem, @"Expected -[firstAsset] to return firstItem.");
}

-(void)testMoveAsset_moveFrom0To0InTwoItemQueue_doesNothingReturnsYES
{
    ALAsset *firstItem = [[ALAsset alloc] init];
    ALAsset *secondItem = [[ALAsset alloc] init];
    
    [self.queue didVerifyAsset:firstItem canAddToQueue:YES];
    [self.queue didVerifyAsset:secondItem canAddToQueue:YES];
    
    XCTAssertTrue([self.queue moveAssetFromIndex:0 toIndex:0],
                   @"Expected -[moveAssetFromIndex:toIndex:] to return false.");
    
    XCTAssertEqualObjects([self.queue assetWithIndexOrNil:0], firstItem, @"Expected -[firstAsset] to return firstItem.");
}


@end
