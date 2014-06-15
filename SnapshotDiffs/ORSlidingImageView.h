//
//  ORSlidingImageView.h
//  SnapshotDiffs
//
//  Created by Orta on 6/15/14.
//  Copyright (c) 2014 Orta. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ORSlidingImageView;
@protocol ORSlidingImageViewClickDelegate <NSObject>

- (void)doubleClickedOnSlidingView:(ORSlidingImageView *)imageView;

@end

@interface ORSlidingImageView : NSView

@property (nonatomic, strong) NSImage *frontImage;
@property (nonatomic, strong) NSImage *backImage;

@property (nonatomic, weak) id <ORSlidingImageViewClickDelegate> clickDelegate;

@end
