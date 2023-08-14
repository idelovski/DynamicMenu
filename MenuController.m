#import "MenuController.h"

static NSString  *gNewMenuName = @"Templates";

#define SWATCH_SIZE 12.0

@implementation MenuController

@synthesize  window;


// [newMenu popUpMenuPositioningItem:newItem atLocation:NSMakePoint(1,1) inView:self.window.contentView]; // If view is nil, the location is interpreted in the screen coordinate system


- (id)init
{
   if (self = [super init])  {
   
   colors = [[NSMutableDictionary alloc] init];
   colorNames = [[NSMutableDictionary alloc] init];
   templateMenu = nil;
   
   [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(applicationDidFinishLaunching:)
                                                name:NSApplicationDidFinishLaunchingNotification
                                              object:nil];
   
   nextTag = 0;
   changingType = NO;
   }
   
   return (self);
}

- (void)dealloc
{
   [[NSNotificationCenter defaultCenter] removeObserver:self];
   [colors release];
   [colorNames release];
   [super dealloc];
}

#ifdef _NE_RADI_OVAK_
- (void)terminate:(id)something
{
   NSLog (@"About to terminate!");
   
   [super terminate:something];
}
#endif

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
   // reset the colors pop-up
   [colorPopUp removeAllItems];
   [self addPopUpColor:[NSColor redColor] name:@"Red"];
   [self addPopUpColor:[NSColor greenColor] name:@"Green"];
   [self addPopUpColor:[NSColor blueColor] name:@"Blue"];
   [self colorPopUpChanged:nil];
   
   [self.window makeKeyAndOrderFront:nil];
   [self.window makeKeyAndOrderFront:nil];
}

- (IBAction)walkMainMenu:(id)sender
{
   [self walkMenu:[NSApp mainMenu] withIndent:@""];
}

- (void)walkMenu:(NSMenu *)menu withIndent:(NSString *)indentString
{
   NSArray       *items = [menu itemArray];
   NSEnumerator  *enumerator = [items objectEnumerator];
   id             item = [enumerator nextObject];
   
   while (item)  {
      BOOL  hasSubmenu = [item hasSubmenu];
      
      NSLog (@"%@%@ 0x%08x:  \"%@\"  tag:%d  action:%@  target:0x%08x", indentString, (hasSubmenu ? @"Menu" : @"Item"), (int)item, [item title], (int)[item tag], [item action] ? NSStringFromSelector([item action]) : @"#", (int)[item target]);
      
      /*if ([item isKindOfClass:[NSMenu class]])
         NSLog (@"This is a menu!");
      else  if ([item isKindOfClass:[NSMenuItem class]])
         NSLog (@"This is a menu item!");
      else
         NSLog (@"This is whatever!");*/
         
      if (hasSubmenu)
         [self walkMenu:[item submenu] withIndent:[NSString stringWithFormat:@"%@    ", indentString]];
      // else
      //    NSLog (@"No submenu for you!");
      
      item = [enumerator nextObject];
   }
}

- (IBAction)addSubmenu:(id)sender
{
   id   item;
   int  i, insertIndex = 0;

   NSMenuItem    *newItem;
   NSMenu        *newMenu;
   NSEnumerator  *enumerator = nil;
   NSMenu        *mainMenu = [NSApp mainMenu];
   NSMenu        *fileMenu = [[mainMenu itemAtIndex:1] submenu]; // app menu=0, then file menu
   NSMenuItem    *revertItem = nil;
   
   if (templateMenu)
      return;
   
   for (i=0; i<[fileMenu numberOfItems]; i++)  {
      NSMenuItem  *mi = [fileMenu.itemArray objectAtIndex:i];
      BOOL         hasSubmenu = [mi hasSubmenu];
      
      NSLog (@"%@ 0x%08x:  \"%@\"  tag:%d  action:%@  target:0x%08x", (hasSubmenu ? @"Menu" : @"Item"), (int)mi, [mi title], (int)[mi tag], [mi action] ? NSStringFromSelector([mi action]) : @"#", (int)[mi target]);
   }
   
   // newItem = [[NSMenuItem alloc] init];
   newItem = [[NSMenuItem alloc] initWithTitle:gNewMenuName
                                        action:nil keyEquivalent:@""];  // If you send nil as hotKey then Trump becomes the president again
   // [newItem setTitle:gNewMenuName];

   newMenu = [[NSMenu alloc] initWithTitle:newItem.title/*gNewMenuName*/];
   [newItem setSubmenu:newMenu];
   
   // find where to add the item
   enumerator = [[fileMenu itemArray] objectEnumerator];
   while ((!revertItem) && (item = [enumerator nextObject]))  {
      BOOL  hasSubmenu = [item hasSubmenu];
      NSLog (@"%@ 0x%08x:  \"%@\"  tag:%d  action:%@  target:0x%08x", (hasSubmenu ? @"Menu" : @"Item"), (int)item, [item title], (int)[item tag], [item action] ? NSStringFromSelector([item action]) : @"#", (int)[item target]);
      if ([item action] == @selector(revertDocumentToSaved:)) {
         revertItem = item;
         insertIndex = [fileMenu indexOfItem:revertItem] + 1;
      }
   }
   
   // add the items
   [fileMenu insertItem:newItem atIndex:insertIndex];
   [fileMenu insertItem:[NSMenuItem separatorItem] atIndex:insertIndex];
   // enable the "Add Item" button
   [addItemButton setEnabled:YES];
   [submenuButton setEnabled:NO];
   templateMenu = newMenu;
   [newItem release];
}

- (IBAction)itemTypeChanged:(id)sender  // Upper popUp
{
   int        tag = [[sender selectedCell] tag];
   NSWindow  *theWindow = [itemNameField window];
   
   changingType = YES;
   //    if ([theWindow firstResponder] == itemNameField) {
   [theWindow makeFirstResponder:nil];
   //    }
   [itemNameField setEditable:((tag == 0) ? YES : NO)];
   
   if (!tag)  {
      [itemNameField setEditable:YES];
      [theWindow makeFirstResponder:itemNameField];
   }
   else
      [itemNameField setEditable:NO];
   
   changingType = NO;
}

- (IBAction)addItem:(id)sender
{
   NSMenuItem *newItem = nil;
   // return if menu doesn't exist yet or we're changing between separators/items
   if (!templateMenu || changingType) return;
   // figure out what to add
   if ([[itemTypePopUp selectedItem] tag] == 1) {
      newItem = [NSMenuItem separatorItem];
      [newItem retain];
   } else {
      newItem = [[NSMenuItem alloc] init];
      [newItem setTitle:[itemNameField stringValue]];
      [newItem setTarget:self];
      [newItem setAction:@selector(templateChosen:)];
   }
   // add it
   [templateMenu addItem:newItem];
   [newItem release];
}

- (IBAction)templateChosen:(id)sender
{
   [templateField setStringValue:[sender title]];
}

- (IBAction)colorPopUpChanged:(id)sender
{
   NSMenuItem *selectedItem = [colorPopUp selectedItem];
   NSNumber *tagKey = [NSNumber numberWithInt:[selectedItem tag]];
   [selectedColorWell setColor:[colors objectForKey:tagKey]];
   [selectedColorField setStringValue:[colorNames objectForKey:tagKey]];
}

- (IBAction)addColorItem:(id)sender
{
   if (changingType) return;
   [self addPopUpColor:[newColorWell color] name:[newColorField stringValue]];
}

- (void)addPopUpColor:(NSColor *)theColor name:(NSString *)theColorName
{
   NSMenuItem *theItem;
   NSImage *swatch = [[NSImage alloc] initWithSize:NSMakeSize(SWATCH_SIZE, SWATCH_SIZE)];
   NSNumber *tagKey = [NSNumber numberWithInt:nextTag];
   
   [swatch lockFocus];
   [theColor set];
   NSRectFill(NSMakeRect(0.0, 0.0, SWATCH_SIZE, SWATCH_SIZE));
   [swatch unlockFocus];
   [colorPopUp addItemWithTitle:theColorName];
   theItem = [colorPopUp itemWithTitle:theColorName];
   [theItem setImage:swatch];
   [theItem setTag:nextTag];
   nextTag++;
   [colors setObject:theColor forKey:tagKey];
   [colorNames setObject:theColorName forKey:tagKey];
   [swatch release];
}

- (BOOL)validateMenuItem:(id <NSMenuItem>)menuItem
{
   SEL  theAction = [(NSMenuItem *)menuItem action];
   
   if (theAction == @selector(dummy1:)) {
      return [dummy1Switch state];
   } else if (theAction == @selector(dummy2:)) {
      return [dummy2Switch state];
   } else if (theAction == @selector(dummy3:)) {
      return [dummy3Switch state];
   }
   return YES; // we'll assume anything else is OK, which is the default
}

- (IBAction)dummy1:(id)sender
{
   NSLog(@"Dummy action #1 invoked.");
}

- (IBAction)dummy2:(id)sender
{
   NSLog(@"Dummy action #2 invoked.");
}

- (IBAction)dummy3:(id)sender
{
   NSLog(@"Dummy action #3 invoked.");
}

@end
