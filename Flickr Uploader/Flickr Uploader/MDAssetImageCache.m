//
//  MDAssetImageCache.m
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 03.07.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import "MDAssetImageCache.h"
#import "ALAsset+MDAssetQueue.h"

@interface MDAssetImageCache()
@property (strong,nonatomic) NSMutableDictionary *assetThumbnailMap;

-(UIImage*)createThumbnailForAsset:(ALAsset*)asset withWidth:(NSUInteger)w andHeight:(NSUInteger)h;
-(NSString*)thumbnailKeyForAsset:(ALAsset*)asset withWidth:(NSUInteger)w andHeight:(NSUInteger)h;

-(UIImage*)thumbnailFromMemoryForAsset:(ALAsset*)asset withWidth:(NSUInteger)w andHeight:(NSUInteger)h;
-(UIImage*)thumbnailFromPersistentStoreForAsset:(ALAsset*)asset withWidth:(NSUInteger)w andHeight:(NSUInteger)h;

@end

@implementation MDAssetImageCache

#pragma mark -
#pragma mark Internal methods

// TODO: implement createThumbnailForAsset
-(UIImage*)createThumbnailForAsset:(ALAsset*)asset withWidth:(NSUInteger)w andHeight:(NSUInteger)h
{
    return [[UIImage alloc] init];
}

-(NSString*)thumbnailKeyForAsset:(ALAsset *)asset withWidth :(NSUInteger)w andHeight:(NSUInteger)h
{
    return [NSString stringWithFormat:@"%@_%d_%d", [asset MD_createOrReturnHashedIdentifier],
            w,
            h];
}

#pragma mark -
#pragma mark Public methods

-(id)init
{
    if (self = [super init])
    {
        self.assetThumbnailMap = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(UIImage*)thumbnailForAsset:(ALAsset*)asset withWidth:(NSUInteger)width andHeight:(NSUInteger)height
{
    UIImage *result = [self thumbnailFromMemoryForAsset:asset withWidth:width andHeight:height];
    if (result == nil)
    {
        
    }
    return result;
}

-(void)clearMemoryCache
{
    
}

-(void)purgeThumbnailsForAsset:(ALAsset*)asset
{
    
}

-(BOOL)thumbnailExistsForAsset:(ALAsset*)asset
                     withWidth:(NSUInteger)width
                     andHeight:(NSUInteger)height
                      inMemory:(BOOL)queryMemoryCache
            andPersistentCache:(BOOL)queryPersistentCache
{
    return NO;
}

@end
