//
//  MDReorderablePhotoDataSource.h
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 02.07.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

@import Foundation;
@import AssetsLibrary;

#import "LXReorderableCollectionViewFlowLayout.h"

@interface MDAssetQueue : NSObject

-(void)addAssetToQueueIfNotProcessed:(ALAsset*)asset;
-(void)shiftAssetAndMarkProcessed;
-(ALAsset*)assetWithIndexOrNil:(NSUInteger)ix;
-(BOOL)moveAssetFromIndex:(NSUInteger)indexFrom toIndex:(NSUInteger)indexTo;
-(NSUInteger)count;

@end
