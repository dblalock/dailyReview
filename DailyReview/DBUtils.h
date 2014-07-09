//
//  DBUtils.h
//  DailyReview
//
//  Created by DB on 7/8/14.
//
//

#import <Foundation/Foundation.h>


NSString* pathToShellScript(NSString* scriptName);
NSString* pathToOutputFile(NSString* fileName);

NSArray* readLines(NSString* file);

NSString* runCommand(NSString *cmd);
