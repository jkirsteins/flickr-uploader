//
//  MDReorderablePhotoDataSource.m
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 02.07.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import "MDAssetQueue.h"
#import "ALAsset+MDAssetQueue.h"
#import "UploadLog.h"
@import Dispatch;

#pragma mark -
#pragma mark Private MDAssetQueue() interface

@interface MDAssetQueue()

/*!
   @property orderedAssets
   @abstract
     Contains all assets that have been inserted into the queue.
     
     These assets are ordered and expected to have not been previously 
     processed.
 */
@property (strong,nonatomic) NSMutableArray *orderedAssets;

/*!
   @property verificationsInProgress
   @abstract
     Maps ALAsset (as NSValue) to in-progress MDAssetVerificationOperation 
     instances.
 */
@property (nonatomic, strong) NSMutableDictionary *verificationsInProgress;

/*!
 @property verificationQueue
 @abstract
 Queue for MDAssetVerificationOperation instances.
 */
@property (strong,nonatomic) NSOperationQueue *verificationQueue;

/*!
   @method markAssetProcessed:
   @abstract
     Saves the asset hash identifier to the persistent store.
 */
-(void)markAssetProcessed:(ALAsset*)asset;

@end

#pragma mark -
#pragma mark MDAssetQueue implementation

@implementation MDAssetQueue

-(void)waitUntilAllOperationsAreFinished
{
    [self.verificationQueue waitUntilAllOperationsAreFinished];
}

- (id)initWithVerificationQueue:(NSOperationQueue*)verificationQueue
{
    self = [super init];
    if (self) {
        self.orderedAssets = [[NSMutableArray alloc] init];
        self.verificationsInProgress = [[NSMutableDictionary alloc] init];
        self.verificationQueue = verificationQueue;
    }
    return self;
}

- (id)init
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"Asset Verification Queue";
    queue.maxConcurrentOperationCount = 1;
    
    return [self initWithVerificationQueue:queue];
}

#pragma mark -
#pragma mark MDAssetVerificationOperationDelegate

-(void)didVerifyAsset:(ALAsset*)asset canAddToQueue:(BOOL)canAdd
{
    NSValue *key = [NSValue valueWithPointer:&asset];
    [self.verificationsInProgress removeObjectForKey:key];
    
    if (canAdd)
    {
        [self.orderedAssets addObject:asset];
        [self.delegate didFinishAddingAsset:asset withIndex:self.orderedAssets.count-1];
    }
}

#pragma mark -
#pragma mark Internal instance methods

-(void)markAssetProcessed:(ALAsset *)asset
{
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    UploadLog *logEntry = [UploadLog MR_createInContext:localContext];
    logEntry.byteHashString = [asset MD_hashedIdentifier];
    [localContext MR_saveToPersistentStoreAndWait];
}

#pragma mark -
#pragma mark Public methods

-(NSUInteger)count
{
    return [self.orderedAssets count];
}

-(void)beginAddingAsset:(ALAsset *)asset
{
    if (asset == nil)
    {
        if ([(id)self.delegate respondsToSelector:@selector(didNotAddAsset:)])
            [self.delegate didNotAddAsset:asset];
        return;
    }
    
    MDAssetVerificationOperation *op = nil;
    NSValue *key = [NSValue value:&asset withObjCType:@encode(ALAsset)];
    op = [self.verificationsInProgress objectForKey:key];
    
    if (op == nil)
    {
        op = [[MDAssetVerificationOperation alloc] initWithAsset:asset andDelegate:self];
        self.verificationsInProgress[key] = op;
        [self.verificationQueue addOperation:op];
    }
}

-(void)shiftAssetAndMarkProcessed
{
    if ([self.orderedAssets count] < 1)
        return;
    
    ALAsset *asset = (ALAsset*)self.orderedAssets[0];
    [self markAssetProcessed:asset];
    [self.orderedAssets removeObjectAtIndex:0];
}

-(ALAsset*)assetWithIndexOrNil:(NSUInteger)ix
{
    if (self.orderedAssets.count < 1) return nil;
    if (ix >= self.orderedAssets.count) return nil;
    id obj = [self.orderedAssets objectAtIndex:ix];
    return (ALAsset*)obj;
}

-(NSUInteger)indexForAsset:(ALAsset *)asset
{
    return [self.orderedAssets indexOfObject:asset];
}

-(BOOL)moveAssetFromIndex:(NSUInteger)indexFrom toIndex:(NSUInteger)indexTo
{
    if (indexFrom >= [self.orderedAssets count])
        return NO;
    
    if (indexTo >= [self.orderedAssets count])
        return NO;
    
    ALAsset *item = [self.orderedAssets objectAtIndex:indexFrom];
    [self.orderedAssets removeObjectAtIndex:indexFrom];
    
    if (indexTo == self.orderedAssets.count)
        [self.orderedAssets addObject:item];
    else
        [self.orderedAssets insertObject:item atIndex:indexTo];

    return YES;
}

@end
