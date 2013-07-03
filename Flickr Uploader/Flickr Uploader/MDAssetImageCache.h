//
//  MDAssetImageCache.h
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 03.07.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AssetsLibrary;

/*!
    @class MDAssetImageCache
    @discussion 
      This class provides a way to generate UIImage* thumbnails from ALAsset* 
      objects.
 
      The thumbnails can be requested in various sizes, and will be cropped 
      automatically.
 
      The class will maintain both an in-memory cache, for speedy access, as 
      well as store the prepared thumbnail data in a Core Data store.
 */
@interface MDAssetImageCache : NSObject

/*!
    @method 
      thumbnailForAsset:withWidth:andHeight:
    @abstract
      Returns a cropped thumbnail with specific dimensions.
    @param asset 
      The original asset, from which to generate the thumbnail.
    @param width
      Required width of the thumbnail
    @param height
      Required height of the thumbnail
    @return 
      UIImage* object representing the thumbnail.
 */
-(UIImage*)thumbnailForAsset:(ALAsset*)asset withWidth:(NSUInteger)width andHeight:(NSUInteger)height;

/*!
   @method
     clearMemoryCache
   @discussion
     Clears the in-memory cache, holding UIImage* objects representing recently
     requested thumbnails.
 
     This method exists to deal with memory warnings. Since memory warnings
     do not apply to CoreData, no method exists for clearing the persistent 
     cache all at once.
 */
-(void)clearMemoryCache;

/*!
   @method
     purgeThumbnailsForAsset:
   @discussion
     Clears the in-memory cache and the backing persistent store of all
     thumbnails that have been created for a specific ALAsset* instance.
   @param asset
     ALAsset* instance whose thumbnails will be purged.
 */
-(void)purgeThumbnailsForAsset:(ALAsset*)asset;

/*!
    @method
      thumbnailExistsForAsset:withWidth:andHeight:inMemory:andPersistentCache:
    @abstract
      Checks if the in-memory and/or persistent cache contains a thumbnail for
      given asset with given dimensions.
    @param asset
      ALAsset* that contains the original image.
    @param width
      Width of the thumbnail.
    @param height
      Height of the thumbnail.
    @param queryMemoryCache
      Whether to query the in-memory cache.
    @param queryPersistentCache
      Whether to query the persistent cache.
 */
-(BOOL)thumbnailExistsForAsset:(ALAsset*)asset
                     withWidth:(NSUInteger)width
                     andHeight:(NSUInteger)height
                      inMemory:(BOOL)queryMemoryCache
            andPersistentCache:(BOOL)queryPersistentCache;

@end
