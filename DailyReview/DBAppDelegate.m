//
//  DBAppDelegate.m
//  DailyReview
//
//  Created by DB on 7/6/14.
//
//

#import "DBAppDelegate.h"

#include <Quartz/Quartz.h>


@implementation DBAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (IBAction)togglePreviewPanel:(id)previewPanel
{
    if ([QLPreviewPanel sharedPreviewPanelExists] && [[QLPreviewPanel sharedPreviewPanel] isVisible])
    {
        [[QLPreviewPanel sharedPreviewPanel] orderOut:nil];
    }
    else
    {
        [[QLPreviewPanel sharedPreviewPanel] makeKeyAndOrderFront:nil];
    }
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    SEL action = [menuItem action];
    if (action == @selector(togglePreviewPanel:))
    {
        if ([QLPreviewPanel sharedPreviewPanelExists] && [[QLPreviewPanel sharedPreviewPanel] isVisible])
        {
            [menuItem setTitle:@"Close Quick Look panel"];
        }
        else
        {
            [menuItem setTitle:@"Open Quick Look panel"];
        }
        return YES;
    }
    return NO;
}

@end
