//
//  WindowController.m
//  whatsapptool
//
//  Created by JianLong Nie on 2020/12/15.
//  Copyright © 2020 JianLong Nie. All rights reserved.
//

#import "WindowController.h"

@interface WindowController ()

@end

@implementation WindowController

- (void)windowDidLoad {
    
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
-(void)windowWillClose:(NSNotification *)notification{
    NSLog(@"fgdfgdfg");
}
- (BOOL)windowShouldClose:(NSWindow *)sender{
    [[NSApplication sharedApplication] terminate:self];
    return YES;
}
@end
