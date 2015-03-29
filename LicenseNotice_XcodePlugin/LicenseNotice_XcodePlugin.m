//
//  LicenseNotice_XcodePlugin.m
//  LicenseNotice_XcodePlugin
//
//  Created by xiaohaibo on 3/29/15.
//  Copyright (c) 2015 xiaohaibo. All rights reserved.
/**
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "LicenseNotice_XcodePlugin.h"
#import "AddLicenseWindowController.h"
static LicenseNotice_XcodePlugin *sharedPlugin;

@interface LicenseNotice_XcodePlugin()

@property (nonatomic, strong) AddLicenseWindowController *licenseNoticeWindow;
@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation LicenseNotice_XcodePlugin

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        
        // Create menu items, initialize UI, etc.

        // Sample Menu Item:
        NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
        if (menuItem) {
            [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
            NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Add License Notice"
                                                                    action:@selector(showLicenseWindow)
                                                             keyEquivalent:@"l"];
            
            [actionMenuItem setKeyEquivalentModifierMask:NSControlKeyMask | NSShiftKeyMask];
            
            
            [actionMenuItem setTarget:self];
            [[menuItem submenu] addItem:actionMenuItem];
        }
        [self initLicenseWindow];
    }
    return self;
}

- (void)initLicenseWindow
{
     self.licenseNoticeWindow = [[AddLicenseWindowController alloc] init];
    [self.licenseNoticeWindow.window setFrame:NSMakeRect(0, 0, 489, 305) display:NO];
    [self.licenseNoticeWindow.window center];
}

// Sample Action, for menu item:
- (void)showLicenseWindow
{
    
    [self.licenseNoticeWindow showWindow:nil];
    
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
