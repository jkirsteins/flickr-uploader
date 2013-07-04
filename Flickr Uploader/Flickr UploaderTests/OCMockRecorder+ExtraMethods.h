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
- (id) andReturnStruct:(void*)aValue objCType:(const char *)type;
@end
