//
//  DBUtils.h
//  DailyReview
//
//  Created by DB on 7/8/14.
//
//

#import <Foundation/Foundation.h>

@interface DBUtils : NSObject

+(BOOL) quickLookFile:(NSString*)path;
+(void) chooseSaveFile:(NSString*)defaultFilePath  pathCallback:(void(^)(NSString*)) callback;

@end

NSImage* iconImageForFile(NSString* path);

NSString* pathToShellScript(NSString* scriptName);
NSString* pathToOutputFile(NSString* fileName);

NSArray* readLines(NSString* file);
BOOL writeStringArrayToFileAsLines(NSArray* ar, NSString* filePath);

NSString* runCommand(NSString *cmd);
NSString* runScript(NSString *commandToRun);
NSString* runScriptWithArgs(NSString *commandToRun, NSArray* args);

NSArray * getSearchDirs();
NSArray * getFilesToReview();

NSString* chooseFolder();

void openFiles(NSArray* files);
BOOL moveFileToDir(NSString* file, NSString*dir);
BOOL moveFile(NSString* origPath, NSString*newPath);
