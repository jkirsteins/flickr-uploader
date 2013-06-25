//
//  MDFlickrUploaderMainViewController.m
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 17.06.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import "MDFlickrUploaderMainViewController.h"
@import AssetsLibrary;

@interface MDFlickrUploaderMainViewController ()

@end

@implementation MDFlickrUploaderMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self loadPhotos];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationItem.hidesBackButton = YES;
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
//    NSLog(@"%@", [asset metadata]);
    NSLog(@"Adding photo: %@", [asset filename]);
}

-(void)loadPhotos
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
         
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
                         NSLog(@"Done!");
                     }
                }];
            }
                            
            failureBlock: ^(NSError *error) {
                // Typically you should handle an error more gracefully than this.
                NSLog(@"No groups");
            }];
    }
}

@end
