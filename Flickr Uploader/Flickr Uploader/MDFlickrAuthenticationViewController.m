//
//  MDViewController.m
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 11.06.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import "MDFlickrAuthenticationViewController.h"
#import "MDOAuthToken.h"
#import "RXFlickr/RXFlickr+checkToken.h"

static NSString* kConsumerKey = @"82e902bf5e9fbb66ba929778a927952e";
static NSString* kConsumerSecret = @"ca9a179f2bf0befa";
static NSString* kCallbackURL = @"md://flickr/callback";

@interface MDFlickrAuthenticationViewController () {
    RXFlickr *_flickrAccount;
    MDOAuthToken *_oauthToken;
}
@end

@implementation MDFlickrAuthenticationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    _oauthToken = [[MDOAuthToken alloc] initWithName:@"flickr.com"];
    NSLog(@"OAuth token: value: %@; secret: %@", _oauthToken.value, _oauthToken.secret);
    
    _flickrAccount = [[RXFlickr alloc] initWithConsumerKey:kConsumerKey secret:kConsumerSecret callbackURL:kCallbackURL];
    [_flickrAccount setDelegate:(id<RXFlickrDelegate>)self];
    
    [_flickrAccount checkTokenWithValue:_oauthToken.value andSecret:_oauthToken.secret];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - RXFlickr CheckToken Delegate

- (void)flickrDidVerifyToken:(RXFlickr *)flickr
{
    self.spinner.hidden = YES;
    [self performSegueWithIdentifier:@"authToMainSegue" sender:self];
}

- (void)flickrDidNotVerifyToken:(RXFlickr *)flickr
{
    self.spinner.hidden = YES;
    self.authenticateButton.hidden = NO;
}

#pragma mark - RXFlickr Delegate

- (void)flickrDidAuthorize:(RXFlickr *)flickr
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [_oauthToken saveValue:[flickr token] andSecret:[flickr tokenSecret]];
}

- (void)flickrDidNotAuthorize:(RXFlickr *)flickr
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An authorization error has occured" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}


- (IBAction)tappedAuthenticateButton:(id)sender {
    UIViewController *uc = [[UIViewController alloc] init];
    UIWebView *vw = [[UIWebView alloc] init];
    uc.view = vw;
    [_flickrAccount setWebView:vw];

    [self presentViewController:uc animated:YES completion:^{
       [_flickrAccount startAuthorization];
    }];
}
@end
