//
//  MDReorderablePhotoDataSource.m
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 02.07.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import "MDAssetQueue.h"

@interface MDAssetQueue()

@property (strong,nonatomic) NSMutableArray *orderedAssets;

-(BOOL)isAssetNew:(ALAsset*)asset;
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
#pragma mark Internal methods

-(BOOL)isAssetNew:(ALAsset*)asset
{
    return YES;
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

-(void)addAssetToQueueIfNew:(ALAsset *)asset
{
    if (![self isAssetNew:asset]) return;
    [self addAssetToQueue:asset];
}

-(void)shiftAssetFromQueue
{
    if ([self.orderedAssets count] < 1)
        return;
    
    [self.orderedAssets removeObjectAtIndex:0];
}

-(ALAsset*)firstAsset
{
    if (self.count < 1) return nil;
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
