# DynamicMenu
An example from a 2002 book Cocoa Programming

https://www.amazon.com/Cocoa-Programming-Scott-Anguish/dp/0672322307

I wanted to play with menus and found this example from back then.

So I created a new project as the original could not be used with the a newer Xcode.

Then I dragged all the needed files to it and built it. Well, after a while I noticed a ghost menu item.

In the nib file, there is no Close All item in the File menu, but when I look from the inside there is.

So, the File menu has Close item and then Save, but...

1) [fileMenu numberOfItems] returns +1 items
2) There are two ways to go through the items and they both find that extra (invisible item)
   - NSMenuItem  *mi = [fileMenu.itemArray objectAtIndex:i];
   - NSEnumerator  *enumerator = [[fileMenu itemArray] objectEnumerator];
3) Whatever I try, the Close All is in there
4) Nib file doesn't have it
5) Finally, File menu inside the built application does not have it
6) Well, a mistery!

Edit:

7) so -isHidden returns NO for CloseAll but YES for the next item Revert
