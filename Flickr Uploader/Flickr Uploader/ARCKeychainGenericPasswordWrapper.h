//
//  MDFlickrApiToken.h
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 16.06.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARCKeychainGenericPasswordWrapper : NSObject

// Designated initializer.
- (id)initWithService: (NSString *)service andAccount:(NSString*)account andAccessGroup:(NSString *) accessGroup;
- (void)setObject:(id)inObject forKey:(id)key;
- (id)objectForKey:(id)key;

// Initializes and resets the default generic keychain item data.
- (void)resetKeychainItem;

@end
