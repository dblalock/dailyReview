//
//  DBUtils.m
//  DailyReview
//
//  Created by DB on 7/8/14.
//
//

#import "DBUtils.h"

#import "DBSharedConsts.h"

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

NSArray * getSearchDirs() {
	NSArray * dirsToSearch = readLines(pathToOutputFile(kDIRS_TO_SEARCH_FILENAME));
	NSLog(@"contents of dirs to search:");
	for (NSString * str in dirsToSearch) {
		NSLog(@"%@", str);
	}
	return dirsToSearch;
}

NSArray * getFilesToReview() {
	// create the file containing which files to review
	NSString* getFilesScript = pathToShellScript(@"getFilesToReview");
	
	// read its contents into an array of strings
	NSString* filesStr = runScriptWithArgs([NSString stringWithFormat:@"%@", getFilesScript ]);
	NSArray * filesToReview = linesOfStr(filesStr);
	
	NSLog(@"files to review:");
	for (NSString * str in filesToReview) {
		NSLog(@"%@", str);
	}
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
