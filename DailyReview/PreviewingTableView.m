
#import "PreviewingTableView.h"
#import "DBAppDelegate.h"

@implementation PreviewingTableView

- (void)keyDown:(NSEvent *)theEvent
{
    NSString *key = [theEvent charactersIgnoringModifiers];
    if ([key isEqual:@" "])
    {
        [[NSApp delegate] togglePreviewPanel:self];
    }
    else
    {
        [super keyDown:theEvent];
    }
}

@end
