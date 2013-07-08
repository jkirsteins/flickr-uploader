//
//  MDAddAssetToUploadQueueOperation.h
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 07.07.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

@import Foundation;
@import AssetsLibrary;

#pragma mark -
#pragma mark MDAssetVerificationOperationDelegate

/*!
   @protocol MDAssetVerificationOperationDelegate
   @abstract
     When MDAssetVerificationOperation finishes verifying an asset, it will
     notify its delegate with the verification results.
 */
@protocol MDAssetVerificationOperationDelegate

-(void)didVerifyAsset:(ALAsset*)asset canAddToQueue:(BOOL)canAdd;

@end

#pragma mark -
#pragma mark MDAssetVerificationOperation

/*!
   @class MDAssetVerificationOperation
   @abstract
     Performs the costly operation of hashing an asset's contents, and checking
     against the CoreData store, if the asset has been processed before.
 
     If not, the asset is added to an upload queue. Otherwise, it is discarded.
 */
@interface MDAssetVerificationOperation : NSOperation

/*!
   @property asset
   @abstract
     Returns the associated asset.
 */
@property (nonatomic, strong, readonly) ALAsset *asset;

/*!
 @property delegate
 @abstract Delegate object that will be notified about verification results.
 */
@property (nonatomic, weak) id <MDAssetVerificationOperationDelegate> delegate;

/*!
   @method initWithAsset:andDelegate:
   @abstract
     Initializes the operation with an asset, and a delegate.
 */
- (id)initWithAsset:(ALAsset*)asset andDelegate:(id<MDAssetVerificationOperationDelegate>) delegate;

@end
