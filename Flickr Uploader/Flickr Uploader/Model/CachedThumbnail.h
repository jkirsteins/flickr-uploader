//
//  CachedThumbnail.h
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 04.07.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CachedThumbnail : NSManagedObject

@property (nonatomic, retain) NSString * assetByteHashString;
@property (nonatomic, retain) NSNumber * thumbnailWidth;
@property (nonatomic, retain) NSNumber * thumbnailHeight;
@property (nonatomic, retain) NSData * thumbnailBytes;

@end
