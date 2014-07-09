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

@interface DBAppController ()

@end


//==================================================

@implementation DBAppController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
		//cd app/contents/resources/
		//mkdir review
		//if [ ! -f searchDirs.txt]; then
		//	echo "$HOME/Downloads" > searchDirs.txt
		//fi
    }
    return self;
}



- (void)windowDidLoad
{
    [super windowDidLoad];
	
	//updateSearchDirs
		//searchDirs = readLines(searchDirs.txt)
		//[dirsTable reloadStuff]
		//updateFilesToReview()
	
	//updateFilesToReview()
		//cd app/contents/resources/
		//getFilesToReview > reviewFiles.txt
		//filesToReview = readlines(reviewFiles.txt)
		//[reviewTable reloadStuff]
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


-(IBAction) addReviewDir:(id)sender {
	//pop up an open dialog
	//stick the result onto the end of our searchDirs array
	//echo dir >> searchDirs.txt
	//updateSearchDirs()
//	system("echo called addReviewDir from dir $(pwd)");
	NSLog(@"pwd: %@", runCommand(@"pwd") );
}
-(IBAction) removeReviewDir:(id)sender {
	//remove item from searchDirs
	//writeStringArray(searchDirs, searchDirs.txt)
	system("echo files present: $(find .)");
}

-(IBAction) open:(id)sender {
	//get selected strings from reviewTable
	//for each file
	//	system("open <file>")
	system("echo $(bash DailyReview.app/Contents/Resources/scripts/test.sh)");	//works
}
-(IBAction) move:(id)sender {
	//pop up an open dialog (only select folders)
	//for each file selected
	//	system("mv file saveDir")
	NSString * kDIRS_TO_SEARCH_FILENAME = @"dirsToSearch";
	NSString * kDIRS_TO_SEARCH_PATH = pathToOutputFile(kDIRS_TO_SEARCH_FILENAME);
	NSArray * dirsToSearch = readLines(kDIRS_TO_SEARCH_PATH);
	NSLog(@"contents of dirs to search:");
	for (NSString * str in dirsToSearch) {
		NSLog(@"%@", str);
	}
}
-(IBAction) trash:(id)sender {
	//system("mv selectedfiles $HOME/.Trash)"
	NSLog(@"example script path: %@", pathToShellScript(@"test"));
}

//NSArray* getSelectedFiles
//NSString* getFileId(NSString *filePath)
//NSString* getTimeFile(NSString *filePath)
//


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
