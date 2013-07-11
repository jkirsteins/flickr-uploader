//
//  MDUploadQueueViewController.m
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 27.06.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import "MDUploadQueueViewController.h"
#import "MDUploadQueueCell.h"

@interface MDUploadQueueViewController ()
@property (nonatomic,strong) ALAssetsLibrary *library;
@end

@implementation MDUploadQueueViewController

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // TODO link the delegate via interface builder?
    self.uploadQueue.delegate = self;
    
    [self loadPhotos];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.hidesBackButton = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark MDAssetQueueDelegate

static NSMutableArray *tttPaths;
static int cellCount = 0;

-(void)didFinishAddingAsset:(ALAsset*)asset withIndex:(NSUInteger)index;
{
    if (tttPaths == nil) tttPaths = [[NSMutableArray alloc] init];
    
    // TODO: put uint->NSIndexPath in one place
    // TODO: fix this counting?

    uint section = (index < 1 ? 0 : 1);
    uint row = index - section;
    NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
    [tttPaths addObject:path];
    cellCount += 1;
 
    if (([tttPaths count] % 15 == 0 || cellCount <= 15) && [tttPaths count] > 0)
    {
        [self.collectionView insertItemsAtIndexPaths:tttPaths];
        [tttPaths removeAllObjects];
    }
}

#pragma mark -
#pragma mark Asset access

-(void)addPhoto:(ALAsset *)asset
{
    [self.uploadQueue beginAddingAsset:asset];
}

-(void)loadPhotos
{
    self.library = [[ALAssetsLibrary alloc] init];

    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [self.library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
         
                                    usingBlock:^(ALAssetsGroup *group, BOOL *stop)
         {
             [group setAssetsFilter:[ALAssetsFilter allPhotos]];
             [group enumerateAssetsUsingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop)
              {
                  // The end of the enumeration is signaled by asset == nil.
                  if (alAsset)
                  {
                      //                      ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                      [self addPhoto:alAsset];
                  }
                  else
                  {
                      NSLog(@"Loaded all assets. Done");
                      [self.collectionView reloadData];
                  }
              }];
         }
         
                                  failureBlock: ^(NSError *error) {
                                      // Typically you should handle an error more gracefully than this.
                                      NSLog(@"No groups");
                                  }];
    }
}

#pragma mark - LXReorderableCollectionViewDataSource methods

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath willMoveToIndexPath:(NSIndexPath *)toIndexPath {

    [self.uploadQueue moveAssetFromIndex:fromIndexPath.section+fromIndexPath.row toIndex:toIndexPath.section+toIndexPath.row];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: implement self.uploadQueue canMoveAssetFromIndex:toIndex:
    return indexPath.section == 1;
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath {
    return fromIndexPath.section == toIndexPath.section;
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    if (section == 0) return [self.uploadQueue count] > 0 ? 1 : 0;

    NSInteger count = (NSInteger)[self.uploadQueue count];
    NSInteger res = MAX(0, count-1);
    return res;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MDUploadQueueCell *cell = (MDUploadQueueCell*)[cv dequeueReusableCellWithReuseIdentifier:@"small" forIndexPath:indexPath];
    
    cell.imageView.image = nil;
    cell.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.1f];

    uint ix = indexPath.section + indexPath.row;
    
    ALAsset *asset = [self.uploadQueue assetWithIndexOrNil:ix];
    
    if (indexPath.section == 0)
        cell.imageView.image = [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
    else
        cell.imageView.image = [UIImage imageWithCGImage:asset.thumbnail];
    
    cell.imageView.frame = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
    cell.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    return cell;
}


#pragma mark – UICollectionViewDelegateFlowLayout

// 1
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0)
    {
        return CGSizeMake(collectionView.bounds.size.width, collectionView.bounds.size.width*0.75f);
    }
    
    int squareSize = floor(collectionView.bounds.size.width/4.0f);
    CGSize retval = CGSizeMake(squareSize - (12.0f/8.0f), squareSize - (12.0f/8.0f));
    return retval;
}

// 3
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0.f, 0.f, 2.f, 0.f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 2.0f;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 2.0f;
}

@end
