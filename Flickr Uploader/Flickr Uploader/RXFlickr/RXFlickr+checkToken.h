//
//  RXFlickr+checkToken.h
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 16.06.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RXFlickr.h"

@interface RXFlickr (checkToken)
-(void)checkTokenWithValue:(NSString*)value andSecret:(NSString*)secret;
@end

@protocol RXFlickrCheckTokenDelegate<NSObject>

@required

- (void)flickrDidVerifyToken:(RXFlickr*)flickr;
- (void)flickrDidNotVerifyToken:(RXFlickr*)flickr;

@end