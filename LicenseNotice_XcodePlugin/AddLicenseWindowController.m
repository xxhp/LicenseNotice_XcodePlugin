//
//  AddLicenseWindowController.m
//  AutoLicensed_XcodePlugin
//
//  Created by xiaohaibo on 3/29/15.
//  Copyright (c) 2015 xiaohaibo. All rights reserved.
/**
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
//

#import "AddLicenseWindowController.h"
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//the following private head of xcode founded at
//http://stackoverflow.com/questions/23229867/xcode-plugin-get-access-to-the-main-textview-of-the-opened-file
//and here: https://github.com/benoitsan/BBUncrustifyPlugin-Xcode

@interface IDEEditorContext : NSObject
- (id)editor;
@end
@interface IDEEditorArea : NSObject
- (IDEEditorContext *)lastActiveEditorContext;
@end

@interface IDEWorkspaceWindowController : NSObject
- (IDEEditorArea *)editorArea;
@end

@interface IDESourceCodeEditor : NSObject
@property (retain) NSTextView *textView;
@end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface AddLicenseWindowController ()
@property (weak) IBOutlet NSPopUpButton *licenseSelect;
@property (weak) IBOutlet NSScrollView *previewTextView;
@property (unsafe_unretained) IBOutlet NSTextView *previewT;
@property (weak) IBOutlet NSButton *applyButton;

@end

@implementation AddLicenseWindowController
+(NSString *)getNoticeByLicense:(NSString *)license{
    NSDictionary *noti = @{
                           @"MIT" : @"Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the \"Software\"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.",
                           
                           @"Apache" : @"Licensed under the Apache License, Version 2.0 (the \"License\") you may not use this file except in compliance with the License.You may obtain a copy of the License at \n\n http://www.apache.org/licenses/LICENSE-2.0 \n\nUnless required by applicable law or agreed to in writing, software distributed under the License is distributed on an \"AS IS\" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.See the License for the specific language governing permissions and limitations under the License.",
                           
                           @"GPL" : @"This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.\n\nThis program is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.\n\nYou should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>." ,
                           
                           @"BSD" : @"Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:\n\n1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.\n\n2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.\n\n3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.\n\nTHIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."};
    return [noti valueForKey:license];
}
- (id)init
{
    return [self initWithWindowNibName:@"AddLicenseWindowController"];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [self loadLicense];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
- (void)windowWillLoad
{
    [super windowWillLoad];
  
}
- (void)loadLicense
{
    [self.licenseSelect setEnabled:NO];
    [self.licenseSelect removeAllItems];
    NSArray *itemTitles = @[@"MIT",@"GPL",@"Apache",@"BSD"];
    [self.licenseSelect addItemWithTitle:@""];
    [self.licenseSelect addItemsWithTitles:itemTitles];
    [self.licenseSelect selectItemWithTitle:@"MIT"];
    [self changeLicense:self.licenseSelect];
    [self.licenseSelect setEnabled:YES];
}
+ (id)currentEditor {
    NSWindowController *currentWindowController = [[NSApp mainWindow] windowController];
    if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        id workspaceController = (IDEWorkspaceWindowController *)currentWindowController;
        id editorArea = [workspaceController editorArea];
        id editorContext = [editorArea lastActiveEditorContext];
        return [editorContext editor];
    }
    return nil;
}

-(NSString *)noticeString{

    return [NSString stringWithFormat:@"%@%@%@",@"\n/**\n",self.previewT.string,@"\n*/\n"];
}

-(NSString *)firstCopywriteString:(NSString*)string{
    
    NSString *copywrite = nil;
    NSArray* dataArray = [string componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (NSString* line in dataArray) {
        if ([[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]hasPrefix:@"//"]&&[line rangeOfString:@"Copyright (c)"].length&& [line rangeOfString:@"All rights reserved."].length) {
            copywrite =  line;
            break;
        }
    }
    return copywrite;
}

- (IBAction)applyLicense:(id)sender {
    [self close];
    IDESourceCodeEditor *eidt =  [AddLicenseWindowController currentEditor];
    NSTextView* textView = eidt.textView;
    
    if (textView) {
        NSString *copywriteString =[self firstCopywriteString:textView.string];
        NSString *notice = [self noticeString];
        NSRange range =  [textView.string rangeOfString:copywriteString];
        if (![textView.string rangeOfString:notice].length) {
            
            if (range.location != NSNotFound) {
                NSRange newrange = NSMakeRange(range.location+range.length, 1);
                [textView insertText:notice replacementRange:newrange];
            }else{
                [textView insertText:notice replacementRange:NSMakeRange(0, 1)];
            }
  
        }
       
    }

}

- (IBAction)changeLicense:(NSPopUpButton*)sender {
    NSString *title = sender.selectedItem.title;
    [self.previewT setString:[AddLicenseWindowController getNoticeByLicense:title]];
}
@end
