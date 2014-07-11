//
//  DBUtils.h
//  DailyReview
//
//  Created by DB on 7/8/14.
//
//

#import <Foundation/Foundation.h>

@interface DBUtils : NSObject

+(void) chooseSaveFile:(NSString*)defaultFilePath  pathCallback:(void(^)(NSString*)) callback;

@end


NSString* pathToShellScript(NSString* scriptName);
NSString* pathToOutputFile(NSString* fileName);

NSArray* readLines(NSString* file);
BOOL writeStringArrayToFileAsLines(NSArray* ar, NSString* filePath);

NSString* runCommand(NSString *cmd);
NSString* runScriptWithArgs(NSString *commandToRun);

NSArray * getSearchDirs();
NSArray * getFilesToReview();

NSString* chooseFolder();

void openFiles(NSArray* files);
BOOL moveFileToDir(NSString* file, NSString*dir);
BOOL moveFile(NSString* origPath, NSString*newPath);
