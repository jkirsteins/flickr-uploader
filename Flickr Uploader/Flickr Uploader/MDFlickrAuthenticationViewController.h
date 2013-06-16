//
//  MDViewController.h
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 11.06.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RXFlickr/RXFlickr.h"
#import "RXFlickr/RXFlickr+checkToken.h"

@interface MDFlickrAuthenticationViewController : UIViewController<RXFlickrDelegate,    RXFlickrCheckTokenDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIButton *authenticateButton;

- (IBAction)tappedAuthenticateButton:(id)sender;

@end
