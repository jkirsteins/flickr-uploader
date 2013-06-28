//
//  MDCurrentlyProcessingCell.h
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 27.06.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import <UIKit/UIKit.h>
@import AssetsLibrary;
@import Dispatch;

@interface MDCurrentlyProcessingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;

+(dispatch_queue_t)backgroundQueue;
-(void)setThumbnail:(CGImageRef)thumbnail;
@end
