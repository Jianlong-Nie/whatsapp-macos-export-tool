//
//  ViewController.h
//  whatsapptool
//
//  Created by JianLong Nie on 2020/12/12.
//  Copyright © 2020 JianLong Nie. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface ViewController : NSViewController{
    NSString *_rootpath;
    NSMutableDictionary *dic;
}
@property(nonatomic, weak) IBOutlet NSTextField *ccField;
@property(nonatomic, weak) IBOutlet NSTextField *phoneField;
-(IBAction)writeAJson:(id)sender;
@end

