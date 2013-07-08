//
//  MDAddAssetToUploadQueueOperation.m
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 07.07.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import "MDAssetVerificationOperation.h"
#import "UploadLog.h"
#import "ALAsset+MDAssetQueue.h"
#import <CommonCrypto/CommonCrypto.h>

@interface MDAssetVerificationOperation()
@property (strong,nonatomic) ALAsset* asset;

/*!
   @method createAssetHash
   @abstract
     Hashes the associated asset's default representation bytes, and returns
     a hexadecimal representation of the hash.
 */
-(NSString*)createAssetHash;

/*!
   @method canAddAssetToQueue
   @abstract ...
 */
-(BOOL)canAddAssetToQueue;
@end

@implementation MDAssetVerificationOperation

#pragma mark -
#pragma mark Internal methods

-(BOOL)canAddAssetToQueue
{
    if (self.asset.MD_hashedIdentifier == nil)
        return YES; // do not allow unhashed assets to get any further.
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"byteHashString = %@", self.asset.MD_hashedIdentifier];
    
    uint count = [UploadLog MR_countOfEntitiesWithPredicate:predicate];
    
    return count == 0;
}

-(NSString*)createAssetHash
{
    NSString *result = nil;
    
    @autoreleasepool {
        unsigned char hash[CC_SHA1_DIGEST_LENGTH];
        
        ALAssetRepresentation *rep = [self.asset defaultRepresentation];
        Byte *buffer = (Byte*)malloc(rep.size);
        NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
        
        if ( CC_SHA1(buffer, buffered, hash) ) {
            NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
            for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
            {
                [output appendFormat:@"%02x", hash[i]];
            }
            result = output;
        }
        free(buffer);
    }
    
    return result;
}

#pragma mark -
#pragma mark Public methods

-(id)initWithAsset:(ALAsset *)asset andDelegate:(id<MDAssetVerificationOperationDelegate>)delegate
{
    if (self = [super init])
    {
        self.delegate = delegate;
        self.asset = asset;
    }
    return self;
}

- (void)main {
    @autoreleasepool {
        if (self.isCancelled)
            return;
        
        if (self.asset.MD_hashedIdentifier == nil)
        {
            NSString *hash = [self createAssetHash];
            self.asset.MD_hashedIdentifier = hash;
        }
        
        if (self.isCancelled)
            return;
        
        BOOL canAdd = [self canAddAssetToQueue];

        if (self.isCancelled)
            return;
        
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [[self delegate] didVerifyAsset:self.asset canAddToQueue:canAdd];
                       });
    }
    
}


@end
