//
//  NSFileManager+RecursiveFind.m
//  SnapshotDiffs
//
//  Created by Orta on 6/16/14.
//  Copyright (c) 2014 Orta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@implementation NSFileManager (ORRecursiveFind)

- (NSString *)or_findFileWithNamePrefix:(NSString *)name inFolder:(NSString *)folder
{
    @try {
        // Sure glad I built OROpenInAppCode already :)
    
        NSDocument *document = [NSApp orderedDocuments].firstObject;
        NSURL *workspaceDirectoryURL = [[[document valueForKeyPath:@"_workspace.representingFilePath.fileURL"] URLByDeletingLastPathComponent] filePathURL];

        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSDirectoryEnumerator *enumerator = nil;
        enumerator = [fileManager enumeratorAtURL:workspaceDirectoryURL
                       includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                          options:NSDirectoryEnumerationSkipsHiddenFiles
                                     errorHandler:^BOOL(NSURL *url, NSError *error) {
            NSLog(@"[Error] %@ (%@)", error, url);
            return YES;
        }];
        
        NSMutableArray *mutableFileURLs = [NSMutableArray array];
        for (NSURL *fileURL in enumerator) {
            
            NSString *filename;
            [fileURL getResourceValue:&filename forKey:NSURLNameKey error:nil];
            
            NSNumber *isDirectory;
            [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
            
            // Skip directories with '_' prefix, for example
            if ([filename hasPrefix:@"_"] && [isDirectory boolValue]) {
                [enumerator skipDescendants];
                continue;
            }
            
            if (![isDirectory boolValue]) {
                [mutableFileURLs addObject:fileURL];
            }
            
            if ([filename hasPrefix:name] && [fileURL.absoluteString rangeOfString:folder].location != NSNotFound) {
                return fileURL.absoluteString;
            }
        }
    }
    @catch (NSException *exception) {
        return nil;
    }

    return nil;
}

@end