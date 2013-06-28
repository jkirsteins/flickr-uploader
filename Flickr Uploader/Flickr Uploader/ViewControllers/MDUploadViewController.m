//
//  MDUploadViewController.m
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 25.06.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import "MDUploadViewController.h"
#import "MDCurrentlyProcessingCell.h"
#import "MDQueuedPictureCell4.h"
@import AssetsLibrary;

@interface MDUploadViewController ()
@property (nonatomic,strong) NSMutableArray *photos;
@property (nonatomic,strong) NSMutableArray *thumbnailCache;
@property (nonatomic,strong) ALAssetsLibrary *library;
@end

@implementation MDUploadViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadPhotos];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [MDQueuedPictureCell4 removeAllExceptVisible:self.tableView.visibleCells];
}

#pragma mark -
#pragma mark Asset access

-(void)addPhoto:(ALAsset *)asset
{
    [self.photos addObject:asset];

}

-(void)loadPhotos
{
    self.library = [[ALAssetsLibrary alloc] init];
    self.photos = [[NSMutableArray alloc] init];
    self.thumbnailCache = [[NSMutableArray alloc] init];
    
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
                    [self.tableView reloadData];
                      NSLog(@"Done! Photo count: %lu.", ((unsigned long)[self.photos count]));
                  }
              }];
         }
         
                             failureBlock: ^(NSError *error) {
                                 // Typically you should handle an error more gracefully than this.
                                 NSLog(@"No groups");
                             }];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return 245.0f;
    
    return 80.0f;//[super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return (self.photos.count > 0 ? 1 : 0);
    
    NSLog(@"Photo count: %d", self.photos.count);
    int res = self.photos.count > 1 ? ceil((self.photos.count-1)/4.0f) : 0;
    NSLog(@"Section 1 rows: %d", res);
    return res;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSArray *visibleCells = [self.tableView visibleCells];
    [visibleCells enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MDQueuedPictureCell4 *cell = (MDQueuedPictureCell4 *)obj;
        
        CGPoint cellPos = [cell convertPoint:CGPointZero toView:scrollView];
        NSIndexPath *indexPath = [(UITableView*)scrollView indexPathForRowAtPoint:cellPos];
        if (indexPath.section == 1)
        {

        int skipAssets = MAX(indexPath.row*4,0)+1;
        for (int i = 0; i < 4; ++i)
        {
            int ix = skipAssets+i;
            if (ix < [self.photos count])
            {
                ALAsset *asset = [self.photos objectAtIndex:ix];
                [cell setThumbnail:asset atIndex:i andGeneration:cell.generation fromCacheOnly:NO];
            }
        }
            
        }
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int skipAssets = MAX(indexPath.row*4, 0);
    
    if (indexPath.section == 0)
    {
        MDCurrentlyProcessingCell *cell = (MDCurrentlyProcessingCell*)[tableView dequeueReusableCellWithIdentifier:@"currentlyProcessingCell" forIndexPath:indexPath];
        
        ALAsset *asset = [self.photos objectAtIndex:skipAssets];
        [cell setThumbnail:[asset aspectRatioThumbnail]];
        return cell;
    }
    else
    {
        MDQueuedPictureCell4 *cell = (MDQueuedPictureCell4*)[tableView dequeueReusableCellWithIdentifier:@"queueCell" forIndexPath:indexPath];
        cell.generation += 1;
        
        for (int i = 0; i < 4; ++i)
        {
            UIImageView *imgView = [[cell thumbnails] objectAtIndex:i];
//            [imgView setBackgroundColor:[UIColor grayColor]];
            imgView.image = nil; // load from cache here, and invalidate unused entries on memory warning
            
            int ix = skipAssets+i+1;
            if (ix < [self.photos count])
            {
                ALAsset *asset = [self.photos objectAtIndex:ix];
                if (!tableView.decelerating)
                {
                    [cell setThumbnail:asset atIndex:i andGeneration:cell.generation fromCacheOnly:NO];
                }
                else
                {
                    [cell setThumbnail:asset atIndex:i andGeneration:cell.generation fromCacheOnly:YES];
                }
            }
        }
        
        
        return cell;
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    // TODO: support rearranging the queue?
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

@end
