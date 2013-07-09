//
//  UIColor+Flickr.m
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 09.07.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import "UIColor+Flickr.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation UIColor (Flickr)

+(UIColor*)flickrBlueColor
{
    // 0x0063dc
    return UIColorFromRGB(0x0063dc);
}

+(UIColor*)flickrPinkColor
{
    // 0xff0084
    return UIColorFromRGB(0xff0084);
}
@end
