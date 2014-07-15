//
//  DBAppController.m
//  DailyReview
//
//  Created by DB on 7/6/14.
//
//

#import "DBAppController.h"

#include <stdlib.h>
#import <Quartz/Quartz.h>	//for quicklook
#include "DBUtils.h"
#include "DBSharedConsts.h"

@interface DBAppController () <QLPreviewPanelDataSource, QLPreviewPanelDelegate>

- (NSArray*) getSelectedSearchDirs;
- (NSArray*) getSelectedFiles;
- (NSArray*) removeSelectedFiles;

- (void) updateFilesToReview;
- (void) updateDirsToSearch;

- (void) storeDirsToSearch;
- (void) waitAndUpdateFilesToReview;
- (void) searchDirsModified;

- (void) reviewSelectedAtTime:(NSString*)when;

@property (strong) QLPreviewPanel *previewPanel;

@end

@implementation DBAppController

// ==================================================
// MARK: Utility functions
// ==================================================

//-------------------------------
// Files to Review
//-------------------------------

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

//-------------------------------
// Search dirs
//-------------------------------

- (NSArray*) getSelectedSearchDirs {
	NSIndexSet* selectedIdxs = [_searchTable selectedRowIndexes];
	NSArray* dirs = [_dirsToSearch objectsAtIndexes:selectedIdxs];
	return dirs;
}

- (void) updateDirsToSearch {
	_dirsToSearch = [getSearchDirs() mutableCopy];
	[_searchTable reloadData];
}

- (void) storeDirsToSearch {
	NSString* searchFile = pathToOutputFile(kDIRS_TO_SEARCH_FILENAME);
	NSLog(@"attempting to write to search file: %@", searchFile);
	writeStringArrayToFileAsLines(_dirsToSearch, searchFile);
}

- (void) waitAndUpdateFilesToReview {
	// get files to review given this new directory to search, but wait
	// a second first so that the above file will have been written
	[NSTimer scheduledTimerWithTimeInterval:2.0f
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
	if (! dir) return;
	if ([_dirsToSearch containsObject:dir]) return;
	
	[_dirsToSearch addObject:dir];
	[self searchDirsModified];
}

//-------------------------------
// Review Functions
//-------------------------------
- (void) reviewSelectedAtTime:(NSString*)when {
	NSArray* selectedFiles = [self removeSelectedFiles];
	NSString* adjustTimeScript = pathToShellScript(kADJUST_TIME_SCRIPT);
//	NSString* cmdFormat = @"%@ %@ %@";
	for (NSString* file in selectedFiles) {
//		NSString* cmd = [NSString stringWithFormat:cmdFormat, adjustTimeScript, when, file];
		NSArray* args = [NSArray arrayWithObjects:when, file, nil];
		runScriptWithArgs(adjustTimeScript, args);
	}
}

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

//- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn
//			row:(NSInteger)rowIndex {
//	if (aTableView == _searchTable) {
//		return [[_dirsToSearch objectAtIndex: rowIndex] stringByAbbreviatingWithTildeInPath];
//	} else if (aTableView == _reviewTable) {
////		if ([aTableColumn ==	//TODO 2 cols, second one editable
//		return [[_filesToReview objectAtIndex: rowIndex] stringByAbbreviatingWithTildeInPath];
//	}
//	return nil;
//}

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

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
	
    // Get an existing cell with the MyView identifier if it exists
    NSTableCellView *result = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
	
    // There is no existing cell to reuse so create a new one
    if (result == nil) {
		
		result = [[NSTableCellView alloc] init];
		
		// The identifier of the NSTextField instance is set to MyView.
		// This allows the cell to be reused.
		result.identifier = tableColumn.identifier;
	}
	
	// result is now guaranteed to be valid, either as a reused cell
	// or as a new cell, so set the stringValue of the cell to the
	// nameArray value at row
	if (tableView == _searchTable) {
		result.textField.stringValue = [[_dirsToSearch objectAtIndex: row] stringByAbbreviatingWithTildeInPath];
	} else if (tableView == _reviewTable) {
		NSString* path = [[_filesToReview objectAtIndex: row] stringByAbbreviatingWithTildeInPath];
		NSString* text = [NSString stringWithFormat:@"%@\n%@",
						  [path lastPathComponent], [path stringByDeletingLastPathComponent]];
		result.textField.stringValue = text;
		result.imageView.image = iconImageForFile(path);
	}
	
	// Return the result
	return result;
	
}

// ==================================================
// MARK: Quick Look Panel Control (NSResponder)
// ==================================================

- (BOOL)acceptsPreviewPanelControl:(QLPreviewPanel *)panel {
    return YES;
}

- (void)beginPreviewPanelControl:(QLPreviewPanel *)panel {
    // This document is now responsible of the preview panel
    // It is allowed to set the delegate, data source and refresh panel.
    _previewPanel = panel;
    panel.delegate = self;
    panel.dataSource = self;
}

- (void)endPreviewPanelControl:(QLPreviewPanel *)panel {
    // This document loses its responsisibility on the preview panel
    // Until the next call to -beginPreviewPanelControl: it must not
    // change the panel's delegate, data source or refresh it.
    _previewPanel = nil;
}

// ==================================================
// MARK: QLPreviewPanelDataSource
// ==================================================

- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel {
	return 1;	//only preview one selected item at a time
}

- (id <QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index {
    NSString* item = [[self getSelectedFiles] objectAtIndex:index];
	return [NSURL fileURLWithPath:item];	//needs an NSURL, not path string
}

// ==================================================
// MARK: QLPreviewPanelDelegate
// ==================================================

- (BOOL)previewPanel:(QLPreviewPanel *)panel handleEvent:(NSEvent *)event {
    // redirect all key down events to the table view (so it'll
	// scroll through files using arrow keys like the Finder)
    if ([event type] == NSKeyDown) {
        [_reviewTable keyDown:event];
		[_previewPanel reloadData];
        return YES;
    }
    return NO;
}

// ==================================================
// MARK: IBActions
// ==================================================

-(IBAction) refresh:(id)sender {
	[self updateFilesToReview];
}

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
	if (! dirs || ! [dirs count]) return;
	
	for (NSString* dir in dirs) {
		[_dirsToSearch removeObject:dir];
	}
	[self searchDirsModified];
}

//-------------------------------
// Review Files Table
//-------------------------------
-(IBAction) quickLook:(id)sender {
	NSString* path = [[self getSelectedFiles] lastObject];
	NSLog(@"calling quickLook on file: %@", path);
	[DBUtils quickLookFile: path];
}

-(IBAction) open:(id)sender {
	NSArray *selectedFiles = [self getSelectedFiles];
	openFiles(selectedFiles);
}

-(IBAction) move:(id)sender {
	NSArray *selectedFiles = [self getSelectedFiles];
	if (! selectedFiles || ! [selectedFiles count]) return;
	
	NSString* newFolder = chooseFolder();
	if (! newFolder) return;
	
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
	[self reviewSelectedAtTime:@"hour"];
}
-(IBAction) reviewTomorrow:(id)sender {
	[self reviewSelectedAtTime:@"day"];
}
-(IBAction) reviewTwoDays:(id)sender {
	[self reviewSelectedAtTime:@"2days"];
}
-(IBAction) reviewNextWeek:(id)sender {
	[self reviewSelectedAtTime:@"week"];
}
-(IBAction) reviewNextMonth:(id)sender {
	[self reviewSelectedAtTime:@"month"];
}
-(IBAction) reviewNever:(id)sender {
	[self reviewSelectedAtTime:@"never"];
}

@end
