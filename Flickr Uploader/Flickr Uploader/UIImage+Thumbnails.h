//
//  UIImage+Thumbnails.h
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 04.07.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
   @category Thumbnails (UIImage)
   @abstract
     Adds support for creating thumbnails from UIImage* instances.
 */
@interface UIImage (Thumbnails)

-(UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize;

@end
