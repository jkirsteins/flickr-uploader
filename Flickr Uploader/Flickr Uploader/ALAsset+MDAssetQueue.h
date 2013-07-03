//
//  ALAsset+MDAssetQueue.h
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 03.07.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAsset(MDAssetQueue)
@property (nonatomic,strong) NSString *MD_hashedIdentifier;

-(NSString*)MD_createOrReturnHashedIdentifier;

@end

