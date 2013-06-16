//
//  RXFlickr+checkToken.m
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 16.06.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import "RXFlickr+checkToken.h"
#import "NSString+MD5.h"
#import "SBJson.h"

@interface RXFlickr () {
    NSString* _consumerKey;
    NSString* _consumerSecret;
}
@end

@implementation RXFlickr (checkToken)

-(void)checkTokenWithValue:(NSString*)value andSecret:(NSString*)secret
{
    self.token = value;
    self.tokenSecret = secret;
    
    NSString *signature = [[NSString stringWithFormat:@"%@api_key%@formatjsonmethod%@nojsoncallback1oauth_token%@",
                                _consumerSecret, _consumerKey, @"flickr.auth.oauth.checkToken", value] MD5String];
    
    NSString *restEndpoint = @"http://api.flickr.com/services/rest";
    NSURL* apiUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@?method=flickr.auth.oauth.checkToken&api_key=%@&oauth_token=%@&api_sig=%@&format=json&nojsoncallback=1", restEndpoint,
        _consumerKey,
        value,
        signature]];
    
    NSURLRequest *req = [NSURLRequest requestWithURL:apiUrl];
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSString *apiResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSLog(@"Parsing checkToken response: %@.", apiResponse);
        NSDictionary *respObj = [[[SBJsonParser alloc] init] objectWithString:apiResponse];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[respObj valueForKey:@"stat"] isEqualToString:@"ok"])
            {
                [((id<RXFlickrCheckTokenDelegate>)self.delegate) flickrDidVerifyToken:self];
            }
            else
            {
                [((id<RXFlickrCheckTokenDelegate>)self.delegate) flickrDidNotVerifyToken:self];
            }
        });
    }];
}


@end
