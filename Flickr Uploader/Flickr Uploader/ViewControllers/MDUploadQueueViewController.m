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
//    [self.collectionView registerClass:[MDUploadQueueCell class] forCellWithReuseIdentifier:@"small"];
    [self loadPhotos];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.hidesBackButton = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self.thumbnailCache clearMemoryCache];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSArray *visibleCells = [self.collectionView visibleCells];
    [visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MDUploadQueueCell *cell = (MDUploadQueueCell *)obj;
        
        NSIndexPath *indexPath = [(UICollectionView*)scrollView indexPathForCell:cell];
        ALAsset *asset = [self.uploadQueue assetWithIndexOrNil:indexPath.section+indexPath.row];
        
        NSLog(@"didEndDecelerating: setting asset for IP %d.%d, G: %d", indexPath.section, indexPath.row, cell.generation);
        [cell setAssetAsync:asset withCache:self.thumbnailCache forGeneration:cell.generation];
    }];
}

#pragma mark -
#pragma mark Asset access
static int sup = 0;
-(void)addPhoto:(ALAsset *)asset
{
    UICollectionView *view = self.collectionView;
    sup++;
    [self.uploadQueue addAssetToQueueIfNotProcessedAsync:asset withCallback:^() {
        sup--;
        if (sup % 5 == 0)
        {
            [view reloadData];
        }
    }];
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
    //    PlayingCard *playingCard = [self.deck objectAtIndex:fromIndexPath.item];
    
    //    [self.deck removeObjectAtIndex:fromIndexPath.item];
    //    [self.deck insertObject:playingCard atIndex:toIndexPath.item];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 1;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)fromIndexPath canMoveToIndexPath:(NSIndexPath *)toIndexPath {
    return NO;// fromIndexPath.section == toIndexPath.section;
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    if (section == 0) return [self.uploadQueue count] > 0 ? 1 : 0;

    return MAX(0, [self.uploadQueue count]-1);
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MDUploadQueueCell *cell = (MDUploadQueueCell*)[cv dequeueReusableCellWithReuseIdentifier:@"small" forIndexPath:indexPath];
    cell.generation+=1;
    
    cell.imageView.image = nil;
    cell.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.1f];

    ALAsset *asset = nil;
    asset = [self.uploadQueue assetWithIndexOrNil:indexPath.section+indexPath.row];
    
    if (!cv.decelerating)
    {
        [cell setAssetAsync:asset withCache:self.thumbnailCache forGeneration:cell.generation];
    }
    else
    {
        UIImage *img = [self.thumbnailCache thumbnailForAsset:asset
                                      withWidth:cell.bounds.size.width
                                      andHeight:cell.bounds.size.height];
        if (img != nil)
        {
            // TODO hacky
            cell.imageView.image = img;
            CGRect f = CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height);
            cell.imageView.frame = f;
            cell.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        }
    }
    
    //NSLog(@"Setting asset for a tile \\w indexPath: s: %d r: %d g: %d.", indexPath.section, indexPath.row, cell.generation);
    //[cell setAssetAsync:asset withCache:self.thumbnailCache forGeneration:cell.generation];
    
    

    return cell;
}


#pragma mark – UICollectionViewDelegateFlowLayout

// 1
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    NSString *searchTerm = self.searches[indexPath.section]; FlickrPhoto *photo =
//    self.searchResults[searchTerm][indexPath.row];
    // 2
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
