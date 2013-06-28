//
//  MDQueuedPictureCell4.m
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 27.06.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import "MDQueuedPictureCell4.h"
#import "MDCurrentlyProcessingCell.h"

@interface MDQueuedPictureCell4 ()
+(NSMutableDictionary*)thumbnailCache;
@end

static NSMutableDictionary *_thumbnailCache = nil;

@implementation MDQueuedPictureCell4

+(NSMutableDictionary*)thumbnailCache
{
    if (_thumbnailCache == nil)
    {
        _thumbnailCache = [[NSMutableDictionary alloc] init];
    }
    return _thumbnailCache;
}

+(void)removeAllExceptVisible:(NSArray*)visibleCells
{
    return;
    NSMutableDictionary *tempCache = [[NSMutableDictionary alloc] init];
    for (MDQueuedPictureCell4 *cell in visibleCells)
    {
        for (int i = 0; i < 4; ++i)
        {
            ALAssetRepresentation *ar = (ALAssetRepresentation*)cell.assetRepresentations[i];
            if ([[MDQueuedPictureCell4 thumbnailCache] objectForKey:ar.filename] != nil)
            {
                tempCache[ar.filename] = [[MDQueuedPictureCell4 thumbnailCache] objectForKey:ar.filename];
            }
        }
    }
    NSLog(@"Optimized cache from %d entries to %d", _thumbnailCache.count, tempCache.count);
    _thumbnailCache = tempCache;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.generation = 1;
        self.assetRepresentations = [[NSMutableArray alloc] initWithCapacity:4];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setThumbnail:(ALAsset*)asset atIndex:(int)imageViewIx andGeneration:(int)reqGeneration fromCacheOnly:(bool)onlyUseCache
{
    ALAssetRepresentation *repr = [asset defaultRepresentation];
//    representation.hash
    if (reqGeneration == self.generation)
    {
        if ([[MDQueuedPictureCell4 thumbnailCache] objectForKey:repr.filename] != nil)
        {
            UIImageView *imgView = (UIImageView*)[self.thumbnails objectAtIndex:imageViewIx];
            imgView.image = (UIImage*)[[MDQueuedPictureCell4 thumbnailCache] objectForKey:repr.filename];
            NSLog(@"Loaded from cache");
            return;
        }
    }
    
    if (onlyUseCache) return;
    
    imageViewIx = 3 - imageViewIx;
    
    dispatch_async([MDCurrentlyProcessingCell backgroundQueue], ^(void) {
        @autoreleasepool {
            if (reqGeneration != self.generation)
            {
                NSLog(@"Generation mismatch. Fast drop");
                return;
            }
            
            float scale = self.bounds.size.width/CGImageGetWidth([asset aspectRatioThumbnail]);
            UIImage *img = [UIImage imageWithCGImage:[asset aspectRatioThumbnail] scale:scale orientation:(UIImageOrientation)UIImageOrientationUp];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                if (reqGeneration == self.generation)
                {
                    UIImageView *imgView = (UIImageView*)[self.thumbnails objectAtIndex:imageViewIx];
                    imgView.image = img;
                    [[MDQueuedPictureCell4 thumbnailCache] setObject:img forKey:[asset defaultRepresentation].filename];
//                    [self.assetRepresentations setObject:(__bridge id)(representation) atIndexedSubscript:imageViewIx];
                }
                else
                {
                    NSLog(@"Generation mismatch. Dropping img");
                }
            });
        }
    });
}

@end
