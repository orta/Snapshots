//
//  NSString+StringBetweenStrings.m
//  Artsy Folio
//
//  Created by orta therox on 03/10/2012.
//  Copyright (c) 2012 http://art.sy. All rights reserved.
//

#import "NSString+StringBetweenStrings.h"

@implementation NSString (StringBetweenStrings)

- (NSString *)or_substringBetween:(NSString *)start and:(NSString *)end {
    NSRange startingRange = [self rangeOfString:start];
    NSRange endingRange = [self rangeOfString:end];

    if (startingRange.location == NSNotFound || endingRange.location == NSNotFound) {
        return nil;
    }

    NSUInteger length = endingRange.location - startingRange.location - startingRange.length;
    NSUInteger location = startingRange.location + startingRange.length;

    if (length + location > self.length) {
        return nil;
    }

    return [self substringWithRange:NSMakeRange(location, length)];
}

@end
