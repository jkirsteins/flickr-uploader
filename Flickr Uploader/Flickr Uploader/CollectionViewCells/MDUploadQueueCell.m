//
//  MDUploadQueueCell.m
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 04.07.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import "MDUploadQueueCell.h"
@import Dispatch;

static dispatch_queue_t _backgroundQueue = nil;

@interface MDUploadQueueCell ()
+(dispatch_queue_t)backgroundQueue;
@end

@implementation MDUploadQueueCell

#pragma mark -
#pragma mark Internal methods

+(dispatch_queue_t)backgroundQueue
{
    if (_backgroundQueue == nil)
    {
        _backgroundQueue = dispatch_queue_create("lv.openid.test.thumbnail-queue", NULL);
    }
    return _backgroundQueue;
}

#pragma mark -
#pragma mark Public methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.generation = 1;
    }
    return self;
}

-(void)setAssetAsync:(ALAsset *)asset withCache:(MDAssetImageCache *)cache forGeneration:(uint)reqGeneration
{
    dispatch_async([MDUploadQueueCell backgroundQueue], ^(void) {
        @autoreleasepool {
            if (reqGeneration != self.generation)
            {
                NSLog(@"Generation mismatch. Fast drop");
                return;
            }
            
            UIImage *img = [cache thumbnailForAsset:asset
                                          withWidth:self.bounds.size.width
                                          andHeight:self.bounds.size.height];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                if (reqGeneration == self.generation)
                {
                    self.imageView.image = img;
                    [self.imageView setBackgroundColor:[UIColor greenColor]];
                }
                else
                {
                    NSLog(@"Generation mismatch. Dropping img");
                }
            });
        }
    });}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
