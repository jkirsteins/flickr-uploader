//
//  MDReorderablePhotoDataSource.h
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 02.07.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

@import Foundation;
@import AssetsLibrary;

#import "MDAssetVerificationOperation.h"
#import "LXReorderableCollectionViewFlowLayout.h"

#pragma mark -
#pragma mark MDAssetQueueDelegate

/*!
   @protocol MDAssetQueueDelegate
   @abstract
     Protocol for asset queue delegates. The asset queue notifies
     its delegate whenever an object is added to the queue.
 */
@protocol MDAssetQueueDelegate

/*!
   @method didFinishAddingAsset:
   @abstract
     This method gets called, when an asset has been added to the
     asset queue.
 */
-(void)didFinishAddingAsset:(ALAsset*)asset withIndex:(NSUInteger)index;

@optional

-(void)didNotAddAsset:(ALAsset*)asset;

@end

#pragma mark -
#pragma mark MDAssetQueue

/*!
   @class MDAssetQueue
   @abstract
     Handles asset verification (if it was previously processed or not)
     in the background, and asset ordering.
 */
@interface MDAssetQueue : NSObject<MDAssetVerificationOperationDelegate>

/*!
   @property delegate
   @abstract The delegate object.
 */
@property (weak,nonatomic) id<MDAssetQueueDelegate> delegate;

/*!
   @method initWithVerificationQueue:
   @abstract
     Initializes the class and injects the background operation queue.
 
     Use this initializer in tests.
 */
- (id)initWithVerificationQueue:(NSOperationQueue*)verificationQueue;

/*!
   @method waitUntilAllOperationsAreFinished
   @abstract
     Halt thread execution until all background operations have finished.
 */
-(void)waitUntilAllOperationsAreFinished;

/*!
   @method beginAddingAsset:
   @abstract 
     Begin verifying if the given asset has already been processed. This can be expensive, so it happens
     as a background operation.
 
     Once the asset has been verified and can be added to the queue,
     it is added, and the delegate is notified.
 */
-(void)beginAddingAsset:(ALAsset*)asset;

/*!
   @method indexForAsset:
   @abstract
     Returns the index of a given asset.
 */
-(NSUInteger)indexForAsset:(ALAsset*)asset;

/*!
   @method shiftAssetAndMarkProcessed:
 */
-(void)shiftAssetAndMarkProcessed;

/*!
 @method assetWithIndexOrNil:
 */
-(ALAsset*)assetWithIndexOrNil:(NSUInteger)ix;

/*!
   @method moveAssetFromIndex:toIndex:
   @abstract
     Changes asset order in the queue.
 */
-(BOOL)moveAssetFromIndex:(NSUInteger)indexFrom toIndex:(NSUInteger)indexTo;

/*!
   @method count
   @abstract
     Returns number of items added to queue.
 */
-(NSUInteger)count;

@end
