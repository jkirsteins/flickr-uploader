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

@interface MDAssetQueue()

@property (strong,nonatomic) NSMutableArray *orderedAssets;

-(BOOL)hasAssetBeenProcessed:(ALAsset*)asset;
-(void)markAssetProcessed:(ALAsset*)asset;
-(void)addAssetToQueue:(ALAsset*)asset;

@end

@implementation MDAssetQueue

- (id)init
{
    self = [super init];
    if (self) {
        self.orderedAssets = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark -
#pragma mark Internal instance methods

-(void)markAssetProcessed:(ALAsset *)asset
{
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    UploadLog *logEntry = [UploadLog MR_createInContext:localContext];
    logEntry.byteHashString = [asset MD_createOrReturnHashedIdentifier];
    [localContext MR_saveToPersistentStoreAndWait];
}

-(BOOL)hasAssetBeenProcessed:(ALAsset*)asset
{
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"byteHashString = %@", [asset MD_createOrReturnHashedIdentifier]];
    uint count = [UploadLog MR_countOfEntitiesWithPredicate:predicate inContext:localContext];
    
    return count != 0;
}

-(void)addAssetToQueue:(ALAsset *)asset
{
    [self.orderedAssets addObject:asset];
}

#pragma mark -
#pragma mark Public methods

-(NSUInteger)count
{
    return [self.orderedAssets count];
}

-(void)addAssetToQueueIfNotProcessed:(ALAsset *)asset
{
    if ([self hasAssetBeenProcessed:asset]) return;
    [self addAssetToQueue:asset];
}

-(void)shiftAssetAndMarkProcessed
{
    if ([self.orderedAssets count] < 1)
        return;
    
    ALAsset *asset = (ALAsset*)self.orderedAssets[0];
    [self markAssetProcessed:asset];
    [self.orderedAssets removeObjectAtIndex:0];
}

-(ALAsset*)firstAsset
{
    if (self.orderedAssets.count < 1) return nil;
    return (ALAsset*)[self.orderedAssets objectAtIndex:0];
}

-(BOOL)moveAssetFromIndex:(int)indexFrom toIndex:(int)indexTo
{
    if (indexFrom < 0 || indexFrom >= [self.orderedAssets count])
        return NO;
    
    if (indexTo < 0 || indexTo >= [self.orderedAssets count])
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
