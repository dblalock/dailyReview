//
//  DBAppController.m
//  DailyReview
//
//  Created by DB on 7/6/14.
//
//

#import "DBAppController.h"

#include <stdlib.h>
#include "DBUtils.h"

static NSString* kDIRS_TO_SEARCH_FILE_NAME = @"dirsToSearch";

@interface DBAppController ()

- (NSArray*) getSelectedSearchDirs;
- (NSArray*) getSelectedFiles;
- (NSArray*) removeSelectedFiles;

- (void) updateFilesToReview;
- (void) updateDirsToSearch;

- (void) storeDirsToSearch;
- (void) waitAndUpdateFilesToReview;
- (void) searchDirsModified;

@end

@implementation DBAppController

// ==================================================
// MARK: Utility functions
// ==================================================

- (NSArray*) getSelectedSearchDirs {
	NSIndexSet* selectedIdxs = [_searchTable selectedRowIndexes];
	NSArray* dirs = [_dirsToSearch objectsAtIndexes:selectedIdxs];
	return dirs;
}

// return the selected files
- (NSArray*) getSelectedFiles {
	NSIndexSet* selectedIdxs = [_reviewTable selectedRowIndexes];
	NSArray* files = [_filesToReview objectsAtIndexes:selectedIdxs];
	return files;
}

// remove the selected files and return them
- (NSArray*) removeSelectedFiles {
	NSIndexSet* selectedIdxs = [_reviewTable selectedRowIndexes];
	NSArray* files = [_filesToReview objectsAtIndexes:selectedIdxs];
	
	[_filesToReview removeObjectsAtIndexes:selectedIdxs];
	[_reviewTable reloadData];
	
	return files;
}

- (void) updateFilesToReview {
	_filesToReview = [getFilesToReview() mutableCopy];
	[_reviewTable reloadData];
}

- (void) updateDirsToSearch {
	_dirsToSearch = [getSearchDirs() mutableCopy];
	[_searchTable reloadData];
}

- (void) storeDirsToSearch {
	NSString* searchFile = pathToOutputFile(kDIRS_TO_SEARCH_FILE_NAME);
	NSLog(@"attempting to write to search file: %@", searchFile);
	writeStringArrayToFileAsLines(_dirsToSearch, searchFile);
}

- (void) waitAndUpdateFilesToReview {
	// get files to review given this new directory to search, but wait
	// a second first so that the above file will have been written
	[NSTimer scheduledTimerWithTimeInterval:1.0f
									 target:self
								   selector:@selector(updateFilesToReview)
								   userInfo:nil
									repeats:NO];
}

- (void) searchDirsModified {
	// write the modified set of dirs to search to the appropriate file
	// so our shell scripts that do the real work learn about it
	[_searchTable reloadData];
	[self storeDirsToSearch];
	
	[self waitAndUpdateFilesToReview];
}

- (void) addSearchDir:(NSString *) dir {
	if ([_dirsToSearch containsObject:dir]) return;
	
	[_dirsToSearch addObject:dir];
	[self searchDirsModified];
}

//- (void) removeSearchDir:(NSString *) dir {
//	if (! [_dirsToSearch containsObject:dir]) return;
//
//	[_dirsToSearch removeObject:dir];
//	[self searchDirsModified];
//}

// ==================================================
// MARK: NSWindowDelegate
// ==================================================

- (id)initWithWindow:(NSWindow *)window {
    self = [super initWithWindow:window];
    if (self) {
		[self updateDirsToSearch];
		[self updateFilesToReview];
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void) awakeFromNib {			//these calls need to be in this function or it won't work
	[_searchTable setDataSource:self];
	[_reviewTable setDataSource:self];
	[_searchTable setDelegate:self];
	[_reviewTable setDelegate:self];
	
	// make it open files on double click
	[_reviewTable setTarget:self];
	[_reviewTable setDoubleAction:@selector(open:)];
}

// ==================================================
// MARK: NSTableViewDataSource
// ==================================================

- (NSInteger) numberOfRowsInTableView:(NSTableView*)aTableView {
	if (aTableView == _searchTable) {
		return [_dirsToSearch count];
	} else if (aTableView == _reviewTable) {
		return [_filesToReview count];
	}
	return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn
			row:(NSInteger)rowIndex {
	if (aTableView == _searchTable) {
		return [[_dirsToSearch objectAtIndex: rowIndex] stringByAbbreviatingWithTildeInPath];
	} else if (aTableView == _reviewTable) {
//		if ([aTableColumn ==	//TODO 2 cols, second one editable
		return [[_filesToReview objectAtIndex: rowIndex] stringByAbbreviatingWithTildeInPath];
	}
	return nil;
}

// ==================================================
// MARK: NSTableViewDelegate
// ==================================================

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn
			  row:(NSInteger)rowIndex {
	if (aTableView == _reviewTable) {
		return NO;
//		return YES; //TODO 2 cols, second one editable
	} else {
		return NO;
	}
}

// ==================================================
// MARK: IBActions
// ==================================================

//-------------------------------
// Search Dirs Table
//-------------------------------
-(IBAction) addReviewDir:(id)sender {
	NSString* path = chooseFolder();
	NSLog(@"chose folder = %@", path);
	[self addSearchDir:path];
}
-(IBAction) removeReviewDir:(id)sender {
	NSArray* dirs = [self getSelectedSearchDirs];
	for (NSString* dir in dirs) {
		[_dirsToSearch removeObject:dir];
	}
	[self searchDirsModified];
}

//-------------------------------
// Review Files Table
//-------------------------------
-(IBAction) open:(id)sender {
	NSArray *selectedFiles = [self getSelectedFiles];
	openFiles(selectedFiles);
}

-(IBAction) move:(id)sender {
	NSArray *selectedFiles = [self getSelectedFiles];
	NSString* newFolder = chooseFolder();
	
	for (NSString* file in selectedFiles) {
		if (moveFileToDir(file, newFolder) ) {
			[_filesToReview removeObject:file];
		}
	}
	
	// initially move the files out of the table, but check if
	// they're still in a directory subject to review and ensure
	// they're put back if they are
	[_reviewTable reloadData];
	[self updateFilesToReview];
	
//	__block long numFilesSelected = [selectedFiles count];
//	__block long numFilesDealtWith = 0;
//	
//	if (! numFilesSelected) return;
//	
//	for (NSString* file in selectedFiles) {
//		[DBUtils chooseSaveFile:file pathCallback:^(NSString* newPath) {
//			numFilesDealtWith++;
//			
//			if (newPath) {
//				NSLog(@"moving %@ to %@", file, newPath);
//			}
//			
//			if (numFilesDealtWith == numFilesSelected) {
//				// initially move the files out of the table, but check if
//				// they're still in a directory subject to review and ensure
//				// they're put back if they are
//				[_reviewTable reloadData];
//				[self updateFilesToReview];
//				[_reviewTable reloadData];
//			}
//		}];
//	}
}

-(IBAction) trash:(id)sender {
	NSArray *selectedFiles = [self removeSelectedFiles];
	NSString *trashDir = [@"~/.Trash/" stringByExpandingTildeInPath];
	for (NSString* file in selectedFiles) {
		moveFileToDir(file, trashDir);
	}
	[_reviewTable reloadData];
}

//-------------------------------
// Review Functions
//-------------------------------

-(IBAction) reviewLater:(id)sender {
	//for each selected file
		//remove file from reviewTable
		//set 1h from now as the file's reviewDate
}
-(IBAction) reviewTomorrow:(id)sender {
	//for each selected file
		//remove file from reviewTable
		//set tomorrow at 4AM as the file's reviewDate
}
-(IBAction) reviewTwoDays:(id)sender {
	//for each selected file
		//remove file from reviewTable
		//set day after tomorrow at 4AM as the file's reviewDate
}
-(IBAction) reviewNextWeek:(id)sender {
	//for each selected file
		//remove file from reviewTable
		//set 7 days from now at 4AM as the file's reviewDate
}
-(IBAction) reviewNextMonth:(id)sender {
	//for each selected file
		//remove file from reviewTable
		//set 1 month from now at 4AM as the file's reviewDate
}
-(IBAction) reviewNever:(id)sender {
	//for each selected file
		//remove file from reviewTable
		//set 1 month from now at 4AM as the file's reviewDate
}

@end
