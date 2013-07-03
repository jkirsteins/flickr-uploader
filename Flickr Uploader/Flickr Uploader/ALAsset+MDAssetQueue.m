//
//  ALAsset+MDAssetQueue.m
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 03.07.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import "ALAsset+MDAssetQueue.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>

@implementation ALAsset(MDAssetQueue)

@dynamic MD_hashedIdentifier;

- (NSString*)MD_hashedIdentifier {
    return (NSString*)objc_getAssociatedObject(self, @selector(MD_hashedIdentifier));
}

- (void)setMD_hashedIdentifier:(NSString*)value {
    objc_setAssociatedObject(self, @selector(MD_hashedIdentifier), (id)value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString*)MD_createOrReturnHashedIdentifier
{
    if (self.MD_hashedIdentifier == nil)
    {
        @autoreleasepool {
            unsigned char hash[CC_SHA1_DIGEST_LENGTH];
            
            ALAssetRepresentation *rep = [self defaultRepresentation];
            Byte *buffer = (Byte*)malloc(rep.size);
            NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
            
            if ( CC_SHA1(buffer, buffered, hash) ) {
                NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
                for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
                {
                    [output appendFormat:@"%02x", hash[i]];
                }
                self.MD_hashedIdentifier = output;
            }
        }
    }
    return self.MD_hashedIdentifier;
}

@end
