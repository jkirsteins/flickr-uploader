//
//  MDOAuthToken.m
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 16.06.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import "MDOAuthToken.h"

@interface MDOAuthToken ()
@property(nonatomic,strong) ARCKeychainGenericPasswordWrapper *tokenValueItem;
@property(nonatomic,strong) ARCKeychainGenericPasswordWrapper *tokenSecretItem;
@end

@implementation MDOAuthToken

@synthesize value=_value;
@synthesize secret=_secret;

-(id)initWithName:(NSString *)name
{
    if (self = [super init])
    {
        self.tokenValueItem = [[ARCKeychainGenericPasswordWrapper alloc] initWithService:name andAccount:@"MDOAuthTokenValue" andAccessGroup:nil];
        _value = [self.tokenValueItem objectForKey:(__bridge NSString *)(kSecAttrGeneric)];
        self.tokenSecretItem = [[ARCKeychainGenericPasswordWrapper alloc] initWithService:name andAccount:@"MDOAuthTokenSecret" andAccessGroup:nil];
        _secret = [self.tokenSecretItem objectForKey:(__bridge NSString *)(kSecAttrGeneric)];
    }
    return self;
}

-(void)saveValue:(NSString*)value andSecret:(NSString*)secret
{
    [self.tokenValueItem setObject:value forKey:(__bridge id)(kSecAttrGeneric)];
    [self.tokenSecretItem setObject:secret forKey:(__bridge id)(kSecAttrGeneric)];
    
    _value = value;
    _secret = secret;
}

@end
