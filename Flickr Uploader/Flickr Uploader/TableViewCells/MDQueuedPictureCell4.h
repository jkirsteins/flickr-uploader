//
//  MDQueuedPictureCell4.h
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 27.06.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AssetsLibrary;

@interface MDQueuedPictureCell4 : UITableViewCell

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *thumbnails;
@property (nonatomic) int generation;
@property (strong, nonatomic) NSMutableArray *assetRepresentations;

-(void)setThumbnail:(ALAsset*)asset atIndex:(int)imageViewIx andGeneration:(int)reqGeneration fromCacheOnly:(bool)onlyUseCache;
+(void)removeAllExceptVisible:(NSArray*)visibleCells;
@end
