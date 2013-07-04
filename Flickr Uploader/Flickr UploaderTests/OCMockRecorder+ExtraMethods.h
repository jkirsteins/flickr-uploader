//
//  OCMockRecorder+ExtraMethods.h
//  Flickr Uploader
//
//  Created by Jānis Kiršteins on 04.07.13.
//  Copyright (c) 2013. g. SIA MONTA DIGITAL. All rights reserved.
//

#import <OCMock/OCMockRecorder.h>

@interface OCMockRecorder (ExtraMethods)
- (id) andReturnBoolean:(BOOL)aValue;
- (id) andReturnCGImageRef:(const void*)cgImageRefAddress;
@end
