//
//  MDUploadQueueViewController.h
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 27.06.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXReorderableCollectionViewFlowLayout.h"
#import "MDAssetQueue.h"

@interface MDUploadQueueViewController : UICollectionViewController<UICollectionViewDelegate, LXReorderableCollectionViewDelegateFlowLayout,LXReorderableCollectionViewDataSource,MDAssetQueueDelegate>

@property (strong, nonatomic) IBOutlet MDAssetQueue *uploadQueue;

@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;

@end
