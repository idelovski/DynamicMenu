/* MenuController */

#import <Cocoa/Cocoa.h>

@interface MenuController : NSObject
{
    IBOutlet NSButton       *addItemButton;
    IBOutlet NSPopUpButton  *colorPopUp;
    IBOutlet NSTextField    *itemNameField;
    IBOutlet NSPopUpButton  *itemTypePopUp;
    IBOutlet NSTextField    *newColorField;
    IBOutlet NSColorWell    *newColorWell;
    IBOutlet NSTextField    *selectedColorField;
    IBOutlet NSColorWell    *selectedColorWell;
    IBOutlet NSButton       *submenuButton;
    IBOutlet NSTextField    *templateField;
    IBOutlet NSButton       *dummy1Switch;
    IBOutlet NSButton       *dummy2Switch;
    IBOutlet NSButton       *dummy3Switch;
   
   IBOutlet  NSWindow       *window;

    NSMenu               *templateMenu;
    NSMutableDictionary  *colors;
    NSMutableDictionary  *colorNames;
   
    int   nextTag;
    BOOL  changingType;
}

@property (nonatomic, retain)  NSWindow  *window;

- (id)init;
- (void)dealloc;

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (void)walkMenu:(NSMenu *)menu withIndent:(NSString *)indentString;

- (IBAction)walkMainMenu:(id)sender;
- (IBAction)addSubmenu:(id)sender;
- (IBAction)itemTypeChanged:(id)sender;
- (IBAction)addItem:(id)sender;
- (IBAction)templateChosen:(id)sender;
- (IBAction)colorPopUpChanged:(id)sender;
- (IBAction)addColorItem:(id)sender;

- (void)addPopUpColor:(NSColor *)theColor name:(NSString *)theColorName;
- (BOOL)validateMenuItem:(id <NSMenuItem>)menuItem;

- (IBAction)dummy1:(id)sender;
- (IBAction)dummy2:(id)sender;
- (IBAction)dummy3:(id)sender;

@end
