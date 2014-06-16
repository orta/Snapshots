//
//  ORSlidingImageView.m
//  SnapshotDiffs
//
//  Created by Orta on 6/15/14.
//  Copyright (c) 2014 Orta. All rights reserved.
//

#import "ORSlidingImageView.h"
#import <Quartz/Quartz.h>
#import "NSColor+ORSnapshotColours.h"

static CGFloat ORContentInset = 8;

@interface ORSlidingImageView()
@property (nonatomic, weak) NSImageView *frontImageView;
@property (nonatomic, weak) NSImageView *backImageView;
@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic, weak) NSView *divider;
@end

@implementation ORSlidingImageView

- (void)setFrontImage:(NSImage *)frontImage
{
    _frontImage = frontImage;
    
    if (!self.frontImageView) {
        NSImageView *frontImageView = [self createImageView];
        [self addSubview:frontImageView];
        
        self.frontImageView = frontImageView;
        self.frontImageView.layer.borderColor = [NSColor or_redColour].CGColor;
    }
    
    self.frontImageView.image = frontImage;
}

- (void)setBackImage:(NSImage *)backImage
{
    _backImage = backImage;
    if (!self.backImageView) {
        NSImageView *backImageView = [self createImageView];
        
        NSView *front = self.frontImageView;
        [self.frontImageView removeFromSuperview];
        [self addSubview:backImageView];
        [self addSubview:front];
        
        backImageView.layer.borderColor = [NSColor or_greenColour].CGColor;
        self.backImageView = backImageView;
        
        [self createDivider];
    }
    
    self.backImageView.image = backImage;
    [self maskViewsWithX:CGRectGetMidX(self.bounds)];
}

- (BOOL) wantsDefaultClipping
{
    return NO;
}

- (void)createDivider
{
    if (self.divider) return;
    
    NSView *divider = [[NSView alloc] initWithFrame:self.boundsForDivider];
    divider.wantsLayer = YES;
    divider.layer.backgroundColor = [NSColor blackColor].CGColor;
    [self addSubview:divider];
    self.divider = divider;
}

- (NSImageView *)createImageView
{
    CGRect frame = CGRectInset(self.bounds, 0, ORContentInset);
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:frame];
    imageView.imageFrameStyle = NSImageFrameNone;
    imageView.wantsLayer = YES;
    imageView.layer.masksToBounds = YES;
    imageView.layer.borderWidth = 2;
    return imageView;
}

- (void)ensureTrackingArea
{
    if (self.trackingArea == nil) {
        _trackingArea = [[NSTrackingArea alloc] initWithRect:NSZeroRect options:NSTrackingInVisibleRect | NSTrackingActiveAlways | NSTrackingMouseMoved | NSTrackingMouseEnteredAndExited owner:self userInfo:nil];
    }
}

- (void)updateTrackingAreas
{
    [super updateTrackingAreas];
    [self ensureTrackingArea];
    if (![[self trackingAreas] containsObject:self.trackingArea]) {
        [self addTrackingArea:self.trackingArea];
    }
}

- (void)mouseMoved:(NSEvent *)event
{
    NSPoint location = [self convertPoint:event.locationInWindow fromView:nil];
    [self maskViewsWithX:location.x];
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    [self mouseMoved:theEvent];
}

- (void)maskViewsWithX:(CGFloat)x
{
    x = roundf(x);
    
    CGPathRef mask = [self newRightMaskPathWithX:x];
	CAShapeLayer *rightBasedMaskLayer = [CAShapeLayer layer];
	[rightBasedMaskLayer setPath:mask];
	CGPathRelease(mask);
    
    self.frontImageView.layer.mask = rightBasedMaskLayer;
    
    mask = [self newLeftMaskPathWithX:x];
	CAShapeLayer *leftBasedMaskLayer = [CAShapeLayer layer];
	[leftBasedMaskLayer setPath:mask];
	CGPathRelease(mask);
    
    self.backImageView.layer.mask = leftBasedMaskLayer;
    
    CGRect frame = [self boundsForDivider];
    frame.origin.x = x;
    self.divider.frame = frame;
}

- (CGRect)boundsForDivider
{
    return CGRectMake(0, -20, 1, CGRectGetHeight(self.bounds) + 40);
}

- (CGPathRef)newRightMaskPathWithX:(CGFloat)x;
{
	CGMutablePathRef maskPath = CGPathCreateMutable();
	
    CGRect rect = CGRectMake(0, 0, x, CGRectGetHeight(self.bounds));
    CGPathAddRect(maskPath, NULL, rect);
	
	CGPathCloseSubpath(maskPath);
	
	return maskPath;
}

- (CGPathRef)newLeftMaskPathWithX:(CGFloat)x;
{
	CGMutablePathRef maskPath = CGPathCreateMutable();
	
    CGRect rect = CGRectMake(x, 0, CGRectGetWidth(self.bounds) - x, CGRectGetHeight(self.bounds));
    CGPathAddRect(maskPath, NULL, rect);
	
	CGPathCloseSubpath(maskPath);
	
	return maskPath;
}

@end
