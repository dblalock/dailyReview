//
//  DBAppController.h
//  DailyReview
//
//  Created by DB on 7/6/14.
//
//

#import <Cocoa/Cocoa.h>



@interface DBAppController : NSWindowController <NSWindowDelegate,
NSTableViewDataSource, NSTableViewDelegate> {
	NSMutableArray *_dirsToSearch;
	NSMutableArray *_filesToReview;
}

NSArray* getSelectedFiles();

//@property(assign) IBOutlet NSWindow* window;
@property(assign) IBOutlet NSTableView* searchTable;
@property(assign) IBOutlet NSTableView* reviewTable;

-(IBAction) refresh:(id)sender;

-(IBAction) addReviewDir:(id)sender;
-(IBAction) removeReviewDir:(id)sender;

-(IBAction) quickLook:(id)sender;
-(IBAction) open:(id)sender;
-(IBAction) move:(id)sender;
-(IBAction) trash:(id)sender;

-(IBAction) reviewLater:(id)sender;
-(IBAction) reviewTomorrow:(id)sender;
-(IBAction) reviewTwoDays:(id)sender;
-(IBAction) reviewNextWeek:(id)sender;
-(IBAction) reviewNextMonth:(id)sender;
-(IBAction) reviewNever:(id)sender;

@end
