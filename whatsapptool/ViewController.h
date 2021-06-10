//
//  ViewController.h
//  whatsapptool
//
//  Created by JianLong Nie on 2020/12/12.
//  Copyright © 2020 JianLong Nie. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface ViewController : NSViewController<NSWindowDelegate>{
    NSString *_rootpath;
    NSMutableDictionary *dic;
    NSMutableArray *devices;
}
@property(nonatomic, weak) IBOutlet NSTextField *ccField;
@property(nonatomic, weak) IBOutlet NSTextField *phoneField;
@property(nonatomic, weak) IBOutlet NSTextField *currentServerField;
@property(nonatomic, weak) IBOutlet NSPopUpButton *popBtn;
-(IBAction)writeAJson:(id)sender;
@end

