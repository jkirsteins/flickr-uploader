//
//  MDUploadQueueCell.h
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 04.07.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AssetsLibrary;
#import "MDAssetImageCache.h"

@interface MDUploadQueueCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) int generation;

-(void)setAssetAsync:(ALAsset *)asset withCache:(MDAssetImageCache *)cache forGeneration:(uint)reqGeneration;

@end
