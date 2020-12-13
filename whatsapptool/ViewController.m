//
//  ViewController.m
//  whatsapptool
//
//  Created by JianLong Nie on 2020/12/12.
//  Copyright © 2020 JianLong Nie. All rights reserved.
//

#import "ViewController.h"
#import "CParseXML.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //单例对象:在程序运行期间,只有一个对象存在
    NSFileManager *fm = [NSFileManager defaultManager];
    NSLog(@"%@",NSHomeDirectory());
    NSString *myurl = NSHomeDirectory();
    NSString *homepath = [myurl  componentsSeparatedByString:@"Library"][0];
    _rootpath = [NSString stringWithFormat:@"%@Downloads/",homepath];
    NSString *path =[NSString stringWithFormat:@"%@keystore.xml",_rootpath];
    // YES 存在   NO 不存在
    BOOL isYES = [fm fileExistsAtPath:path];
    
    if (isYES) {
        CParseXML *parser = [[CParseXML  alloc] initWithXMLPath:path];
        dic=parser.nodeDict;
        
        NSLog(@"-->%d",isYES);
    }

    // Do any additional setup after loading the view.
}
-(void)showAlert:(NSString *) title msg:(NSString *) msg{
    NSAlert *alert = [[NSAlert alloc] init];

    alert.alertStyle = NSAlertStyleWarning;

    [alert addButtonWithTitle:@"ok"];

    alert.messageText = title;

    alert.informativeText = msg;

    [alert beginSheetModalForWindow:[NSApplication sharedApplication].keyWindow completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) {
            NSLog(@"确定");

        } else if (returnCode == NSAlertSecondButtonReturn) {
            NSLog(@"取消");

        } else {
            NSLog(@"else");

        }

    }];
}
-(IBAction)writeAJson:(id)sender{
    if ([self.ccField.stringValue length]==0|| [self.phoneField.stringValue length]==0) {
        [self showAlert:@"Alert" msg:@"Please enter full information"];
    }else{
        [dic setObject:self.ccField.stringValue forKey:@"cc"];
        [dic setObject:[NSString stringWithFormat:@"%@%@",self.ccField.stringValue,self.phoneField.stringValue] forKey:@"phone"];
        [dic setObject:@"000" forKey:@"sim_mcc"];
        [dic setObject:@"000" forKey:@"sim_mnc"];
        [self writeStringToFile];
    }
  
    
}
- (void)writeStringToFile{

    // Build the path, and create if needed.
    NSString* filePath = [NSString stringWithFormat:@"%@%@%@.json",_rootpath,self.ccField.stringValue,self.phoneField.stringValue];
    NSData *serialzedData=[NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *saveBookmark = [[NSString alloc] initWithBytes:[serialzedData bytes] length:[serialzedData length] encoding:NSUTF8StringEncoding];
    NSError *error;
    //now i write json file.....
    [saveBookmark writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!error) {
        [self showAlert:@"Success" msg:[NSString stringWithFormat:@"The JSON file is in this directory %@",filePath]];
        self.ccField.stringValue=@"";
        self.phoneField.stringValue=@"";
    }
//    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
//        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
//    }

    // The main act...
 //   [[aString dataUsingEncoding:NSUTF8StringEncoding] writeToFile:fileAtPath atomically:NO];
}
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
