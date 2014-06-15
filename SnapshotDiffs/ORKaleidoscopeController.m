//
//  ORKaleidoscopeController.m
//  SnapshotDiffs
//
//  Created by Orta on 6/15/14.
//  Copyright (c) 2014 Orta. All rights reserved.
//

#import "ORKaleidoscopeController.h"
#import <ApplicationServices/ApplicationServices.h>

@implementation ORKaleidoscopeController

+ (BOOL)isInstalled
{
    BOOL found = NO;
    CFURLRef appURL = NULL;
    OSStatus result = LSFindApplicationForInfo ( kLSUnknownCreator,CFSTR("com.blackpixel.kaleidoscope"), NULL,NULL,&appURL );
    switch(result) {
        case noErr:
            found = YES;
    }

    if (appURL) {
        CFRelease(appURL);
    }
    return found;
}

@end
