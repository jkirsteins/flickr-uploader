//
//  MDCurrentlyProcessingCell.m
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 27.06.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import "MDCurrentlyProcessingCell.h"

static dispatch_queue_t _backgroundQueue = nil;

@implementation MDCurrentlyProcessingCell

+(dispatch_queue_t)backgroundQueue
{
    if (_backgroundQueue == nil)
    {
        _backgroundQueue = dispatch_queue_create("lv.openid.test.thumbnail-queue", NULL);
    }
    return _backgroundQueue;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setThumbnail:(CGImageRef)representation
{
    dispatch_async([MDCurrentlyProcessingCell backgroundQueue], ^(void) {
        @autoreleasepool {
            float scale = self.bounds.size.width/CGImageGetWidth(representation);
            UIImage *img = [UIImage imageWithCGImage:representation scale:scale orientation:(UIImageOrientation)UIImageOrientationUp];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                self.thumbnailView.image = img;
            });
        }
    });
}

@end
