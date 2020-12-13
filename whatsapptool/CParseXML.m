//
//  CParseXML.m
//  whatsapptool
//
//  Created by JianLong Nie on 2020/12/13.
//  Copyright © 2020 JianLong Nie. All rights reserved.
//

#import "CParseXML.h"

@implementation CParseXML

-(id)initWithXMLPath:(NSString *)path
{
    if (self = [super init]) {
        self.nodeDict = [NSMutableDictionary dictionary];
    
//        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"xml"];
//        NSLog(@"xml path: %@", path);
        NSError *error;
        NSString* contents = [NSString stringWithContentsOfFile:path
                                       encoding:NSUTF8StringEncoding
                                       error:&error];
        NSData* xmlData = [contents dataUsingEncoding:NSUTF8StringEncoding];
        [self parseData:xmlData parseError:&error];
    }
    return self;
}

- (void)parseData:(NSData *)data parseError:(NSError **)err
{
    NSXMLParser *parser;
    parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    // we don't care about namespaces
    parser.shouldProcessNamespaces = NO;
    // we just want data, no other stuff.
    parser.shouldResolveExternalEntities = NO;
    [parser parse];
    if (err && [parser parserError]) {
        *err = [parser parserError];
    }
}

#pragma mark- NSXMLParserDelegate

//处理标签包含内容字符 （报告元素的所有或部分内容）
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (!_currentPropertyValue) {
        _currentPropertyValue = [[NSMutableString alloc] init];
    }
    if (string) {
        [_currentPropertyValue appendString:string];
        [_currentPropertyValue setString:[_currentPropertyValue
                                          stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    }
}

//发现元素开始符的处理函数  （即报告元素的开始以及元素的属性）
- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"string"]) {
        NSString *name =attributeDict[@"name"];
        if ([attributeDict[@"name"]  isEqual:@"server_static_public"]) {
            [self.nodeDict setObject:_currentPropertyValue forKey:@"server_static_public"];
        }
        if ([attributeDict[@"name"]  isEqual:@"client_static_keypair"]) {
                 [self.nodeDict setObject:_currentPropertyValue forKey:@"client_static_keypair"];
             }
       
    }
    
}

//发现元素结束符的处理函数，保存元素各项目数据（即报告元素的结束标记）
- (void)parser:(NSXMLParser *)parser
 didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"-----parse error！！！-----");
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    NSLog(@"-----starting parse xml file.-----");
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    NSLog(@"-----ended parse xml file.-----\n");
}


#pragma mark - public method
- (uint) nodesLength
{
    return [self.nodeDict count];
}


- (id)getNodeAt:(uint)nid
{
    NSString *nidStr = [NSString stringWithFormat:@"%d", nid];
    return [self.nodeDict objectForKey:nidStr];
}


@end
