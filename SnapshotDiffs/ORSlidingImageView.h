//
//  ORSlidingImageView.h
//  SnapshotDiffs
//
//  Created by Orta on 6/15/14.
//  Copyright (c) 2014 Orta. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ORSlidingImageView : NSView

@property (nonatomic, strong) NSImage *frontImage;
@property (nonatomic, strong) NSImage *backImage;

@property (readwrite, nonatomic, strong) NSString *frontMessage;
@property (readwrite, nonatomic, strong) NSString *backMessage;

@end
