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
#import "MDFlickrActivityIndicatorView.h"

@interface MDFlickrAuthenticationViewController : UIViewController<RXFlickrDelegate,    RXFlickrCheckTokenDelegate>

@property (weak, nonatomic) IBOutlet MDFlickrActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIButton *authenticateButton;

@end
