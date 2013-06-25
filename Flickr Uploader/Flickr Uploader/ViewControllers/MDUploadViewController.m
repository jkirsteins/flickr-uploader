//
//  MDUploadViewController.m
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 25.06.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import "MDUploadViewController.h"
@import AssetsLibrary;

@interface MDUploadViewController ()
@property (nonatomic,strong) NSMutableArray *photos;
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
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Asset access

-(void)addPhoto:(ALAssetRepresentation *)asset
{
    NSLog(@"Adding photo: %@", [asset filename]);
    [self.photos addObject:asset];
    [self.tableView reloadData];
}

-(void)loadPhotos
{
    self.library = [[ALAssetsLibrary alloc] init];
    self.photos = [[NSMutableArray alloc] init];
    
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
                      ALAssetRepresentation *representation = [alAsset defaultRepresentation];
                      [self addPhoto:representation];
                  }
                  else
                  {
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
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
        return 245.0f;
    
    return 110.0f;//[super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Returning number of rows in section: %lu", ((unsigned long)[self.photos count]));
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    ALAssetRepresentation *cellAsset = [self.photos objectAtIndex:indexPath.row];
    
    if (indexPath.row == 0)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"currentlyProcessingCell" forIndexPath:indexPath];
        NSLog(@"Returning main cell: %@", cell);
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"queueCell" forIndexPath:indexPath];
        //[cell.textLabel setText:cellAsset.filename];
        //NSLog(@"Setting cell (%@) title to %@", cell, cell.textLabel.text);
    }
    
    id vwt = [cell.contentView viewWithTag:1];
    UIImageView *imageView = (UIImageView*)(vwt);
    imageView.image = [UIImage imageWithCGImage:cellAsset.fullResolutionImage];
    
    
    return cell;
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
