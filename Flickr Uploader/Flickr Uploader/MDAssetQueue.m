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

-(void)addAssetToQueueIfNew:(ALAsset *)asset
{
    if (![self isAssetNew:asset]) return;
    [self addAssetToQueue:asset];
}

-(void)shiftAssetFromQueue
{
    [self.orderedAssets removeObjectAtIndex:0];
}

-(ALAsset*)peekAsset
{
    return (ALAsset*)[self.orderedAssets objectAtIndex:0];
}

-(void)moveAssetFromIndex:(int)indexFrom toIndex:(int)indexTo
{
    ALAsset *item = [self.orderedAssets objectAtIndex:indexFrom];
    [self.orderedAssets removeObjectAtIndex:indexFrom];
    [self.orderedAssets insertObject:item atIndex:indexTo];

}

@end
