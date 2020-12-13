//
//  CParseXML.h
//  whatsapptool
//
//  Created by JianLong Nie on 2020/12/13.
//  Copyright © 2020 JianLong Nie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CParseXML : NSObject<NSXMLParserDelegate>{
    NSMutableString *_currentPropertyValue;
    NSString *_currentProperty;
}
@property (nonatomic, strong) NSMutableDictionary *nodeDict;

-(id)initWithXMLPath:(NSString *)path;

- (uint) nodesLength;
- (uint) linesLength;
- (id)getNodeAt:(uint)nid;
- (id)getLineAt:(uint)lid;
@end

