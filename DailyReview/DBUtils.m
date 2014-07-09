//
//  DBUtils.m
//  DailyReview
//
//  Created by DB on 7/8/14.
//
//

#import "DBUtils.h"


NSString* pathToShellScript(NSString* script) {
	return [[NSBundle mainBundle] pathForResource:script ofType:@"sh" inDirectory:@"scripts"];
}

NSString* pathToOutputFile(NSString* script) {
	return [[NSBundle mainBundle] pathForResource:script ofType:@"txt" inDirectory:@"scripts"];
}

NSArray * readLines(NSString* path) {
	NSString *contents = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	NSArray *lines = [contents componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"]];
	return lines;
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
