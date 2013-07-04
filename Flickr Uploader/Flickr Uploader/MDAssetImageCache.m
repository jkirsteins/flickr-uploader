//
//  MDAssetImageCache.m
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 03.07.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import "MDAssetImageCache.h"
#import "ALAsset+MDAssetQueue.h"
#import "CachedThumbnail.h"
#import "UIImage+Thumbnails.h"

@interface MDAssetImageCache()

@property (strong,nonatomic) NSMutableDictionary *assetThumbnailMap;

/*!
   @method createAndPersistThumbnailForAsset:withWidth:andHeight:
   @abstract
     Creates and returns a thumbnail for a given asset, with given dimensions.
     This method also saves the thumbnail to both memory and the persistent
     store.
 */
-(UIImage*)createAndPersistThumbnailForAsset:(ALAsset*)asset
                                   withWidth:(NSUInteger)w
                                   andHeight:(NSUInteger)h;

/*!
   @method thumbnailKeyForAsset:withWidth:andHeight:
   @abstract
     Creates and returns a key that should be used to identify a given asset
     thumbnail in the memory map.
 */
-(NSString*)thumbnailKeyForAsset:(ALAsset*)asset withWidth:(NSUInteger)w andHeight:(NSUInteger)h;

/*!
   @method thumbnailFromMemoryForAsset:withWidth:andHeight:
   @abstract
     Loads and returns an UIImage* representation of a given thumbnail from the 
     memory cache. Returns nil, if the thumbnail is not loaded in the memory
     map (it may be available in the persistent store).
 */
-(UIImage*)thumbnailFromMemoryForAsset:(ALAsset*)asset withWidth:(NSUInteger)w andHeight:(NSUInteger)h;

/*!
   @method loadThumbnailFromPersistentStoreToMemoryForAsset:withWidth:andHeight:
   @abstract
     Attempts to load a thumbnail from the persistent store to memory cache.
   @return 
     YES if the thumbnail was found in the persistent store and loaded into
     the memory cache. Otherwise returns NO.
 */
-(BOOL)loadThumbnailForAssetFromPersistentStoreToMemory:(ALAsset*)asset
                                              withWidth:(NSUInteger)w
                                              andHeight:(NSUInteger)h;

@end

@implementation MDAssetImageCache

#pragma mark -
#pragma mark Internal methods

-(UIImage*)thumbnailFromMemoryForAsset:(ALAsset*)asset withWidth:(NSUInteger)w andHeight:(NSUInteger)h
{
    return [self.assetThumbnailMap objectForKey:[self thumbnailKeyForAsset:asset withWidth:w andHeight:h]];
}

-(BOOL)loadThumbnailForAssetFromPersistentStoreToMemory:(ALAsset*)asset
                                              withWidth:(NSUInteger)w
                                              andHeight:(NSUInteger)h
{
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"assetByteHashString=%@ AND thumbnailWidth=%d AND thumbnailHeight=%d", [asset MD_createOrReturnHashedIdentifier], w, h];

    id t = [CachedThumbnail MR_findFirstWithPredicate:predicate inContext:localContext];
    if (t == nil)
    {
        return NO;
    }
    CachedThumbnail *thumbnail = (CachedThumbnail*)t;
    UIImage *img = [[UIImage alloc] initWithData:thumbnail.thumbnailBytes];
    self.assetThumbnailMap[[self thumbnailKeyForAsset:asset withWidth:w andHeight:h]] = img;
    
    return YES;
}

-(UIImage*)createAndPersistThumbnailForAsset:(ALAsset*)asset
                                   withWidth:(NSUInteger)w
                                   andHeight:(NSUInteger)h
{
    @autoreleasepool {
        if (w * h == 0) return nil;
        
        UIImage *img = [[UIImage alloc] initWithCGImage:[[asset defaultRepresentation] fullResolutionImage]];
        img = [img imageByScalingAndCroppingForSize:CGSizeMake(w, h)];
        
        self.assetThumbnailMap[[asset MD_createOrReturnHashedIdentifier]] = img;

        NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
        CachedThumbnail *ct = [CachedThumbnail MR_createInContext:localContext];
        
        ct.assetByteHashString = [asset MD_createOrReturnHashedIdentifier];
        ct.thumbnailWidth = [[NSNumber alloc] initWithUnsignedInteger:w];
        ct.thumbnailHeight = [[NSNumber alloc] initWithUnsignedInteger:w];
        ct.thumbnailBytes = UIImagePNGRepresentation(img);
        [localContext MR_saveToPersistentStoreAndWait];
        
        return img;
    }
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
    if (asset == nil) return nil;
    if (width * height == 0) return nil;
    
    UIImage *result = [self thumbnailFromMemoryForAsset:asset withWidth:width andHeight:height];
    if (result == nil)
    {
        if ([self loadThumbnailForAssetFromPersistentStoreToMemory:asset withWidth:width andHeight:height])
        {
            result = [self thumbnailFromMemoryForAsset:asset
                                             withWidth:width
                                             andHeight:height];
        }
        else
        {
            result = [self createAndPersistThumbnailForAsset:asset
                                                   withWidth:width
                                                   andHeight:height];
        }
    }
    return result;
}

-(void)clearMemoryCache
{
    @autoreleasepool {
        self.assetThumbnailMap = [[NSMutableDictionary alloc] init];
    }
}

-(void)purgeThumbnailsForAsset:(ALAsset*)asset
{
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"assetByteHashString=%@",
                         [asset MD_createOrReturnHashedIdentifier]];
    [CachedThumbnail MR_deleteAllMatchingPredicate:pred];
    [localContext MR_saveToPersistentStoreAndWait];
    
    [self clearMemoryCache];
}

-(BOOL)thumbnailExistsForAsset:(ALAsset*)asset
                     withWidth:(NSUInteger)width
                     andHeight:(NSUInteger)height
                      inMemory:(BOOL)reqStateInMemoryCache
            andPersistentCache:(BOOL)reqStateInPersistentStore
{
    BOOL existsInMemoryCache =
        (self.assetThumbnailMap[[asset MD_createOrReturnHashedIdentifier]] != nil);
    
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"assetByteHashString=%@ AND thumbnailWidth=%d AND thumbnailHeight=%d", [asset MD_createOrReturnHashedIdentifier], width, height];
    BOOL existsInPersistentStore = [CachedThumbnail MR_countOfEntitiesWithPredicate:predicate inContext:localContext] > 0;

    return (reqStateInMemoryCache == existsInMemoryCache) && (reqStateInPersistentStore == existsInPersistentStore);
}

@end
