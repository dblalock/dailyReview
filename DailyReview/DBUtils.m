//
//  DBUtils.m
//  DailyReview
//
//  Created by DB on 7/8/14.
//
//

#import "DBUtils.h"

#import "DBSharedConsts.h"


// only need to wrap one method that takes in a block
@implementation DBUtils

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
	return lines;
}

BOOL writeStringArrayToFileAsLines(NSArray* ar, NSString* filePath) {
	NSString* fileContents = [ar componentsJoinedByString:@"\n"];
	return [fileContents writeToFile:filePath atomically:NO encoding:NSUTF8StringEncoding error:nil];
}

NSArray * getSearchDirs() {
	NSArray * dirsToSearch = readLines(pathToOutputFile(kDIRS_TO_SEARCH_FILENAME));
//	NSLog(@"dirs to search:");
//	for (NSString * str in dirsToSearch) {
//		NSLog(@"%@", str);
//	}
	return dirsToSearch;
}

NSArray * getFilesToReview() {
	// create the file containing which files to review
	NSString* getFilesScript = pathToShellScript(@"getFilesToReview");
	NSLog(@"get files script loc: %@", getFilesScript);
	
	// read its contents into an array of strings
	NSString* filesStr = runScriptWithArgs([NSString stringWithFormat:@"%@", getFilesScript ]);
	NSArray * filesToReview = linesOfStr(filesStr);
	
	//SELF: if this stops working, check to make sure script is writing
	//to stdout, not file
//	NSLog(@"files to review:");
//	for (NSString * str in filesToReview) {
//		NSLog(@"%@", str);
//	}
	return filesToReview;
}

NSString* runCommand(NSString *commandToRun) {
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
	
    NSArray *arguments = [NSArray arrayWithObjects:
                          @"-c" ,
                          [NSString stringWithFormat:@"%@", commandToRun],
                          nil];
    NSLog(@"running command: %@",commandToRun);
    [task setArguments: arguments];
	
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
	
    NSFileHandle *file = [pipe fileHandleForReading];
	
    [task launch];
	
    NSData *data = [file readDataToEndOfFile];
	
    NSString *output;
    output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    return output;
}

NSString* runScriptWithArgs(NSString *commandToRun) {
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: @"/bin/sh"];
	
    NSArray *arguments = [NSArray arrayWithObjects:
                          [NSString stringWithFormat:@"%@", commandToRun],
                          nil];
    NSLog(@"running command: %@",commandToRun);
    [task setArguments: arguments];
	
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
	
    NSFileHandle *file = [pipe fileHandleForReading];
	
    [task launch];
	
    NSData *data = [file readDataToEndOfFile];
	
    NSString *output;
    output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
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
		NSString* cmd = [NSString stringWithFormat:@"open '%@'", file];	//TODO remove echo
		runCommand(cmd);
	}
}

BOOL moveFileToDir(NSString* file, NSString* dir) {
	return moveFile(file, dir);
}

BOOL moveFile(NSString* origPath, NSString* newPath) {
	//ideally, use moveItemAtPath:toPath:error: of NSFileManager
	if (! origPath || ! newPath) return NO;
	NSString* cmd = [NSString stringWithFormat:@"mv %@ %@", origPath, newPath];	//TODO remove echo
	runCommand(cmd);
	return YES;
}
