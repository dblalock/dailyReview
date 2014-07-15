//
//  DBUtils.m
//  DailyReview
//
//  Created by DB on 7/8/14.
//
//

#import "DBUtils.h"

#import <QuickLook/QuickLook.h>
#import "DBSharedConsts.h"

#define ICON_SIZE 20.0

// only need to wrap one method that takes in a block
@implementation DBUtils

+(BOOL) quickLookFile:(NSString*)path {
	NSURL *fileURL = [NSURL fileURLWithPath:path];
    if (! path || !fileURL) {
		NSLog(@"DBUtils: quicklookfile: invalid path %@", path);
        return NO;
    }
    
	
	int width=600;
	int height=800;
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                     forKey:(NSString *)kQLThumbnailOptionIconModeKey];
    CGImageRef ref = QLThumbnailImageCreate(kCFAllocatorDefault,
                                            (__bridge CFURLRef)fileURL,
                                            CGSizeMake(width, height),
                                            (__bridge CFDictionaryRef)dict);
	return (ref != nil);
}

NSImage* iconImageForFile(NSString* filePath) {
	filePath = [filePath stringByExpandingTildeInPath];
	NSImage* iconImage = [[NSWorkspace sharedWorkspace] iconForFile:filePath];
	[iconImage setSize:NSMakeSize(ICON_SIZE, ICON_SIZE)];
	
	// make the icon better (according to QuickLookDownloader example app)...?
	NSDictionary *options = @{(id)kQLThumbnailOptionIconModeKey: (id)kCFBooleanTrue};
	NSURL *url = [NSURL fileURLWithPath:filePath];
	NSLog(@"creating img for path %@; url = %@", filePath, [url path]);
	CGImageRef quickLookIcon = QLThumbnailImageCreate(NULL,
													  (__bridge CFURLRef)url,
													  CGSizeMake(ICON_SIZE, ICON_SIZE),
													  (__bridge CFDictionaryRef)options);
	if (quickLookIcon != NULL) {
		NSLog(@"returning quicklook icon");
		NSImage* betterIcon = [[NSImage alloc] initWithCGImage:quickLookIcon size:NSMakeSize(ICON_SIZE, ICON_SIZE)];
		return betterIcon;
//		[self performSelectorOnMainThread:@selector(setIconImage:) withObject:betterIcon waitUntilDone:NO];
//		CFRelease(quickLookIcon);
	}
	NSLog(@"returning workspace icon");
	return iconImage;
}

+(void) chooseSaveFile:(NSString*)defaultFilePath  pathCallback:(void(^)(NSString*)) callback {
	NSSavePanel * savePanel = [NSSavePanel savePanel];
	[savePanel setExtensionHidden:NO];
	
	// get directory and filename
	NSURL * fileURL = [NSURL fileURLWithPath:defaultFilePath isDirectory:NO];
	NSString *directory = [[fileURL absoluteString] stringByDeletingLastPathComponent];
	NSString *filename = [[fileURL absoluteString] lastPathComponent];
	
	// set default directory and filename to the current ones of the file
	[savePanel setDirectoryURL:[NSURL fileURLWithPath:directory isDirectory:YES]];
	[savePanel setNameFieldStringValue:filename];
	
	// Use a completion handler -- this is a block which takes one argument
	// which corresponds to the button that was clicked
	__block NSString * filePath = nil;
	[savePanel beginWithCompletionHandler:^(NSInteger result) {
		if (result == NSFileHandlingPanelOKButton) {
			filePath = [[savePanel URL] path];
			callback(filePath);
		} else {
			callback(nil);
		}
	}];
}

@end

NSString* pathToShellScript(NSString* script) {
	return [[NSBundle mainBundle] pathForResource:script ofType:@"sh" inDirectory:@"scripts"];
}

NSString* pathToOutputFile(NSString* script) {
	return [[NSBundle mainBundle] pathForResource:script ofType:@"txt" inDirectory:@"scripts"];
}

NSArray* linesOfStr(NSString* str) {
	return [str componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]];
}

NSArray * readLines(NSString* path) {
	NSString *contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	NSArray *lines = linesOfStr(contents);
	if (! lines) {
		NSLog(@"lines nil");
		return [[NSArray alloc] init];
	}
	return lines;
}

BOOL writeStringArrayToFileAsLines(NSArray* ar, NSString* filePath) {
	NSString* fileContents = [ar componentsJoinedByString:@"\n"];
	return [fileContents writeToFile:filePath atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

NSArray * getSearchDirs() {
	NSArray * linesInFile = readLines(pathToOutputFile(kDIRS_TO_SEARCH_FILENAME));

	NSFileManager* mgr = [NSFileManager defaultManager];
	NSMutableArray* dirsToSearch = [[NSMutableArray alloc] init];

	NSLog(@"dirs to search:");
	for (NSString * str in linesInFile) {
		NSLog(@"%@", str);
		BOOL dirExists;
		[mgr fileExistsAtPath:str isDirectory:&dirExists];
		if (dirExists) {
			[dirsToSearch addObject:str];
		}
	}
	return dirsToSearch;
}

NSArray * getFilesToReview() {
	//SELF: if this stops working, check to make sure script is writing
	//to stdout, not file
	
	// read set of files to review
	NSString* getFilesScript = pathToShellScript(kGET_REVIEW_FILES_SCRIPT);
	NSString* filesStr = runScript([NSString stringWithFormat:@"%@", getFilesScript]);
	NSArray * linesInFile = linesOfStr(filesStr);
	
	NSLog(@"filesStr: %@",filesStr);
	
	// verify that everything is a path that actually exists (which
	// it should, but there *may* be whitespace in the files)
	NSFileManager* mgr = [NSFileManager defaultManager];
	NSMutableArray* filesToReview = [[NSMutableArray alloc] init];
	NSLog(@"files to review:");
	for (NSString * str in linesInFile) {
		NSLog(@"%@", str);
		if ([mgr fileExistsAtPath:str]) {
			[filesToReview addObject:str];
		}
	}
	return filesToReview;
}

NSString* runCommand(NSString *commandToRun) {
	NSLog(@"running command: %@",commandToRun);
	
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/bash"];
	
    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c" ,
                          [NSString stringWithFormat:@"%@", commandToRun],
                          nil];
    [task setArguments: arguments];
	
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
	
    NSFileHandle *file = [pipe fileHandleForReading];
	
    [task launch];
	
    NSData *data = [file readDataToEndOfFile];
    return [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
}

NSString* runScript(NSString *commandToRun) {
	return runScriptWithArgs(commandToRun, nil);
}

NSString* runScriptWithArgs(NSString *scriptPath, NSArray* arguments) {
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
	
	// set arguments to task; script path is 0th arg
	NSMutableArray *args = [[NSMutableArray alloc] init];
	[args addObject:scriptPath];
	[args addObjectsFromArray:arguments];
    [task setArguments: args];
	
    NSLog(@"running script: %@",scriptPath);

    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
	
    NSFileHandle *file = [pipe fileHandleForReading];
	
    [task launch];
	
    NSLog(@"waiting for task to exit...");
	[task waitUntilExit];
    NSLog(@"Task exited");
	
    NSData *data = [file readDataToEndOfFile];
	
    NSString *output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    return output;
}

NSString* chooseFolder() {
    // Create the File Open Dialog class.
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanChooseDirectories:YES];
	[openDlg setAllowsMultipleSelection:NO];
	
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    if ( [openDlg runModal] == NSOKButton )
    {
		NSURL* selectedDir = [[openDlg URLs] objectAtIndex:0];
		return [selectedDir path];
    }
	return nil;
}

void openFiles(NSArray* files) {
	for (NSString* file in files) {
		NSString* cmd = [NSString stringWithFormat:@"open '%@'", file];
		runCommand(cmd);
	}
}

BOOL moveFileToDir(NSString* file, NSString* dir) {
	NSString* fileName = [file lastPathComponent];
	NSString* destPath = [dir stringByAppendingPathComponent:fileName];
	return moveFile(file, destPath);
}

BOOL moveFile(NSString* origPath, NSString* newPath) {
	if (! origPath || ! newPath) return NO;
	return [[NSFileManager defaultManager] moveItemAtPath:origPath toPath:newPath error:nil];
}
