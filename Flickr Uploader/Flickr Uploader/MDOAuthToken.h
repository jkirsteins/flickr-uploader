//
//  MDOAuthToken.h
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 16.06.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARCKeychainGenericPasswordWrapper.h"

@interface MDOAuthToken : NSObject

@property (readonly,nonatomic) NSString *value;
@property (readonly,nonatomic) NSString *secret;

-(id)initWithName:(NSString *)name;
-(void)saveValue:(NSString*)value andSecret:(NSString*)secret;

@end
