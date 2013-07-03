//
//  UploadLog.h
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 25.06.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UploadLog : NSManagedObject

@property (nonatomic, retain) NSString * byteHashString;

@end
