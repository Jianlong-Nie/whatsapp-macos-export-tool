//
//  ViewController.m
//  whatsapptool
//
//  Created by JianLong Nie on 2020/12/12.
//  Copyright © 2020 JianLong Nie. All rights reserved.
//

#import "ViewController.h"
#import "CParseXML.h"
#import "STPrivilegedTask.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self runSTPrivilegedTask];
    //单例对象:在程序运行期间,只有一个对象存在
  

    // Do any additional setup after loading the view.
}

- (void)runSTPrivilegedTask {
    NSString *cmd = @"/bin/sh launcher.sh";
    
    STPrivilegedTask *privilegedTask = [[STPrivilegedTask alloc] init];
    
    NSMutableArray *components = [[cmd componentsSeparatedByString:@" "] mutableCopy];
    NSString *launchPath = components[0];
    [components removeObjectAtIndex:0];
    
    [privilegedTask setLaunchPath:launchPath];
    [privilegedTask setArguments:components];
    [privilegedTask setCurrentDirectoryPath:[[NSBundle mainBundle] resourcePath]];
    
    // Set it off
    OSStatus err = [privilegedTask launch];
    if (err != errAuthorizationSuccess) {
        if (err == errAuthorizationCanceled) {
            NSLog(@"User cancelled");
            return;
        }  else {
            NSLog(@"Something went wrong: %d", (int)err);
            // For error codes, see http://www.opensource.apple.com/source/libsecurity_authorization/libsecurity_authorization-36329/lib/Authorization.h
        }
    }
    
    [privilegedTask waitUntilExit];
    
    // Success! Now, read the output file handle for data
    NSFileHandle *readHandle = [privilegedTask outputFileHandle];
    NSData *outputData = [readHandle readDataToEndOfFile]; // Blocking call
    NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    //[self.outputTextField setString:outputString];
    NSLog(@"输出%@",outputString);
    
    NSString *exitStr = [NSString stringWithFormat:@"Exit status: %d", privilegedTask.terminationStatus];
    NSString *result = [[outputString componentsSeparatedByString:@"\"client_static_keypair\">"]  [1]  componentsSeparatedByString:@"</string>"][0];
      NSLog(@"输出臭豆腐的%@",exitStr);

            
    dic=[[NSMutableDictionary alloc] init];
    [dic setObject:[NSString stringWithFormat:@"%@==",result] forKey:@"client_static_keypair"];
            //  [dic setObject:[NSString stringWithFormat:@"%@==",parser.nodeDict[@"server_static_public"]] forKey:@"server_static_public"];
            // dic=parser.nodeDict;
             
          //   NSLog(@"-->%d",isYES);
        // }
     
    
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
-(IBAction)refresh:(id)sender{
     
    [self runSTPrivilegedTask];
  
    
}

-(IBAction)writeAJson:(id)sender{
     
    if ([self.ccField.stringValue length]==0|| [self.phoneField.stringValue length]==0) {
        [self showAlert:@"Alert" msg:@"Please enter full information"];
    }else{
        [dic setObject:@"1" forKey:@"version"];
       // [dic setObject:@"" forKey:<#(nonnull id<NSCopying>)#>];
        [dic setObject:self.ccField.stringValue forKey:@"cc"];
        [dic setObject:[NSString stringWithFormat:@"%@",self.phoneField.stringValue] forKey:@"phone"];
        [dic setObject:@"000" forKey:@"sim_mcc"];
        [dic setObject:@"000" forKey:@"sim_mnc"];
        [self writeStringToFile];
    }
  
    
}
- (void)writeStringToFile{

    // Build the path, and create if needed.
    NSString* filePath = [NSString stringWithFormat:@"~/Desktop/%@.json",self.phoneField.stringValue];
    NSData *serialzedData=[NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *saveBookmark = [[NSString alloc] initWithBytes:[serialzedData bytes] length:[serialzedData length] encoding:NSUTF8StringEncoding];
    NSError *error;
    
    //now i write json file.....
  //  [saveBookmark writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    NSString *cmd = [NSString stringWithFormat:@"/bin/sh write.sh %@ %@.json",saveBookmark,self.phoneField.stringValue];
//        STPrivilegedTask *privilegedTask = [[STPrivilegedTask alloc] init];
//        NSMutableArray *components = [[cmd componentsSeparatedByString:@" "] mutableCopy];
//        NSString *launchPath = components[0];
//        [components removeObjectAtIndex:0];
//        [privilegedTask setLaunchPath:launchPath];
//        [privilegedTask setArguments:components];
//        [privilegedTask setCurrentDirectoryPath:[[NSBundle mainBundle] resourcePath]];
//
//        // Set it off
//        OSStatus err = [privilegedTask launch];
//        if (err != errAuthorizationSuccess) {
//            if (err == errAuthorizationCanceled) {
//                NSLog(@"User cancelled");
//                return;
//            }  else {
//                NSLog(@"Something went wrong: %d", (int)err);
//                // For error codes, see http://www.opensource.apple.com/source/libsecurity_authorization/libsecurity_authorization-36329/lib/Authorization.h
//            }
//        }
//
//        [privilegedTask waitUntilExit];
      NSTask *task = [[NSTask alloc] init];
       
       NSMutableArray *components = [[cmd componentsSeparatedByCharactersInSet:
                          [NSCharacterSet whitespaceCharacterSet]] mutableCopy];
       
       task.launchPath = components[0];
       [components removeObjectAtIndex:0];
       task.arguments = components;
       task.currentDirectoryPath = [[NSBundle  mainBundle] resourcePath];
       
       NSPipe *outputPipe = [NSPipe pipe];
       [task setStandardOutput:outputPipe];
       [task setStandardError:outputPipe];
       NSFileHandle *readHandle = [outputPipe fileHandleForReading];
       
       [task launch];
       [task waitUntilExit];
     NSData *outputData = [readHandle readDataToEndOfFile];
        NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
       
        
        NSString *exitStr = [NSString stringWithFormat:@"Exit status: %d", task.terminationStatus];
       

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
