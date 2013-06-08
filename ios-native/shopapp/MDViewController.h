//
//  MDViewController.h
//  View tests
//
//  Created by Jānis Kiršteins on 19.04.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MDViewController : UIViewController<ZBarReaderDelegate>

@property (nonatomic, retain) IBOutlet UIImageView *resultImage;
@property (nonatomic, retain) IBOutlet UILabel *resultText;

- (IBAction) scanButtonTapped;
- (IBAction) toggleMenuButtonTapped:(id)sender;

- (UIViewController *) leftViewController;

@end
