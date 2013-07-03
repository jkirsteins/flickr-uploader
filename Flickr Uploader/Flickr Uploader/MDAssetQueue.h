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

-(void)addAssetToQueueIfNew:(ALAsset*)asset;
-(void)shiftAssetFromQueue;
-(ALAsset*)peekAsset;
-(void)moveAssetFromIndex:(int)indexFrom toIndex:(int)indexTo;

@end
