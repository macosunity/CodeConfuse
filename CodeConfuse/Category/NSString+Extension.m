//
//  NSString+Extension.m
//  CodeConfuse
//
//  Created by ConfuseCode on 2018/11/17.
//  Copyright © 2018年 All rights reserved.
//

#import "NSString+Extension.h"
#import <CommonCrypto/CommonDigest.h>
#import <zlib.h>

@interface ReadTxtFile : NSObject

@property (nonatomic, strong) NSString *dict;
@property (nonatomic, strong) NSArray *wordArray;

- (NSArray *)randomReadWordsFromTxtFile;
+ (instancetype)sharedInstance;

@end

@implementation ReadTxtFile

+ (instancetype)sharedInstance {
    static id sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (NSArray *)randomReadWordsFromTxtFile {
    if (!self.dict) {
        self.dict = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"Dict" withExtension:@"txt"] encoding:NSUTF8StringEncoding error:nil];
        
        self.wordArray = [self.dict componentsSeparatedByString:@"\n"];
        
        NSMutableArray *randomArray = [[NSMutableArray alloc] init];
        
        while ([randomArray count] < (arc4random()%300)+600 ) {
            int r = arc4random() % [self.wordArray count];
            [randomArray addObject:[self.wordArray objectAtIndex:r]];
        }
        
        self.wordArray = [NSArray arrayWithArray:randomArray];
    }
    
    return self.wordArray;
}

@end

@implementation NSString (Extension)

- (NSString *)code_MD5
{
    if (self.length == 0) return nil;
    const char *string = self.UTF8String;
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(string, (CC_LONG)strlen(string), result);
    NSMutableString *digest = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (NSInteger i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [digest appendFormat:@"%02x", result[i]];
    }
    return digest;
}

//第一个字母大写
+ (NSString *)captializedFirstCharOfString:(NSString *)string
{
    NSString *result = [string stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[string substringToIndex:1] uppercaseString]];
    
    return result;
}

//获取随机指定位数的字符串 小写
+ (NSString *)getRandomStringsWithLow:(int)length
{
    char data[length];
    
    for (int x=0;x < length; data[x++] = (char)('A' + (arc4random_uniform(26))));
    
    NSString *randomStr = [[NSString alloc] initWithBytes:data length:length encoding:NSUTF8StringEncoding];
    
    NSString *string = [NSString stringWithFormat:@"%@",randomStr];
    
    return string;
}

+ (NSString *)getRandomStringWithPrefix:(NSString *)prefixString
{    
    int length = (arc4random() % 6) + 2;
    
    //获取随机字符串
    NSString *randomStr = [self getRandomStringsWithLow:length];
    
    NSString *string = [NSString stringWithFormat:@"%@_%@", prefixString, randomStr];
    string = [[string lowercaseString] capitalizedString];//转换首字母大写
    
    return string;
}

+ (instancetype)code_randomStringWithoutDigital
{
    NSArray *dictArray = [[ReadTxtFile sharedInstance] randomReadWordsFromTxtFile];

    NSString *randomWord = @"";
    NSUInteger index = arc4random() % dictArray.count;
    if (index < dictArray.count-1) {
        randomWord = dictArray[index];
        randomWord = [randomWord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSArray<NSString *> *prefixs = @[@"check",@"find",@"contains",@"res",@"data",@"table",@"with",@"without",@"account",@"flipped",@"crush",@"notifyAll",@"controller",@"notify",@"handle",@"encoding",@"finish",@"start",@"end",@"call",@"model",@"component",@"index",@"did",@"code",@"rest",@"restful",@"request",@"response",@"free",@"trans",@"before",@"after",@"setup",@"teardown",@"retry",@"reload",@"random",@"exist",@"get",@"client",@"server",@"move",@"click",@"begin",@"touch",@"press",@"push",@"pop",@"enter",@"flip",@"animate",@"view",@"edit",@"read",@"write",@"core",@"reset",@"change",@"modify",@"contents",@"clean"];
        NSUInteger indexPrefix = arc4random() % prefixs.count;
        indexPrefix = (indexPrefix < prefixs.count) ? indexPrefix : (prefixs.count-1);
        
        NSArray<NSString *> *joins = @[@"And", @"Between", @"For", @"By", @"At", @"Inside",@"Because",@"Of", @"On", @"When", @"While", @"In", @"Under", @"Until", @"AccordingTo", @"Among", @"Above", @"Over", @"Below", @"Beside", @"Behind", @"After"];
        
        NSUInteger indexJoin = arc4random() % joins.count;
        indexJoin = (indexJoin < joins.count) ? indexJoin : (joins.count-1);

        NSUInteger indexWord2 = arc4random() % dictArray.count;
        indexWord2 = (indexWord2 < dictArray.count) ? indexWord2 : (dictArray.count-1);
        NSString *randomWord2 = dictArray[indexWord2];
        randomWord2 = [randomWord2 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        randomWord = [NSString stringWithFormat:@"%@%@%@%@", prefixs[indexPrefix], [randomWord capitalizedString], joins[indexJoin], [randomWord2 capitalizedString]];
    }
    else {
        NSArray<NSString *> *strings = @[@"parameter",@"view",@"containsObj",@"dict",@"dataArr",@"table",@"with",@"without",@"gameid",@"flipped",@"crush",@"notifyAll",@"controller",@"truth",@"damage",@"encodings",@"increase",@"decrease",@"other",@"model",@"handler",@"component",@"profile",@"towards",@"given",@"sense",@"passion",@"eternity",@"fantastic",@"freedom",@"example",@"partly",@"education",@"dist",@"information",@"extreme",@"styles",@"setok",@"removing",@"umbrella",@"occur",@"newline",@"extension",@"objByte",@"current",@"boost",@"handed",@"errorno",@"author",@"values",@"least",@"explosion",@"fuselage",@"zxing",@"believe",@"survivors",@"helps",@"likely",@"filename",@"tasks",@"recent",@"education",@"delegated", @"projected"];
        NSUInteger index = arc4random() % strings.count;
        index = (index < strings.count) ? index : (strings.count-1);
        randomWord = strings[index];
        
        NSUInteger indexWord2 = arc4random() % dictArray.count;
        indexWord2 = (indexWord2 < dictArray.count) ? indexWord2 : (dictArray.count-1);
        NSString *randomWord2 = dictArray[indexWord2];
        randomWord2 = [randomWord2 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        randomWord = [NSString stringWithFormat:@"%@%@", randomWord, [randomWord2 capitalizedString]];
    }
    return randomWord;
}

+ (instancetype)code_randomStringWithoutDigital:(NSString *)prefix
{
    NSArray *dictArray = [[ReadTxtFile sharedInstance] randomReadWordsFromTxtFile];
    
    NSString *randomWord = @"";
    NSUInteger index = arc4random() % dictArray.count;
    if (index < dictArray.count-1) {
        randomWord = dictArray[index];
        randomWord = [randomWord stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSArray<NSString *> *prefixs = @[@"check",@"find",@"contains",@"res",@"data",@"table",@"with",@"without",@"account",@"flipped",@"crush",@"notifyAll",@"controller",@"notify",@"handle",@"encoding",@"finish",@"start",@"end",@"call",@"model",@"component",@"index",@"did",@"code",@"rest",@"restful",@"request",@"response",@"free",@"trans",@"before",@"after",@"setup",@"teardown",@"retry",@"reload",@"random",@"exist",@"get",@"client",@"server",@"move",@"click",@"begin",@"touch",@"press",@"push",@"pop",@"enter",@"flip",@"animate",@"view",@"edit",@"read",@"write",@"core",@"reset",@"change",@"modify",@"contents",@"clean"];
        NSUInteger indexPrefix = arc4random() % prefixs.count;
        indexPrefix = (indexPrefix < prefixs.count) ? indexPrefix : (prefixs.count-1);
        
        randomWord = [NSString stringWithFormat:@"%@%@%@", prefix, [prefixs[indexPrefix] capitalizedString], [randomWord capitalizedString]];
    }
    else {
        NSArray<NSString *> *strings = @[@"parameter",@"view",@"containsObj",@"dict",@"dataArr",@"table",@"with",@"without",@"gameid",@"flipped",@"crush",@"notifyAll",@"controller",@"truth",@"damage",@"encodings",@"increase",@"decrease",@"other",@"model",@"handler",@"component",@"profile",@"towards",@"given",@"sense",@"passion",@"eternity",@"fantastic",@"freedom",@"example",@"partly",@"education",@"dist",@"information",@"extreme",@"styles",@"setok",@"removing",@"umbrella",@"occur",@"newline",@"extension",@"objByte",@"current",@"boost",@"handed",@"errorno",@"author",@"values",@"least",@"explosion",@"fuselage",@"zxing",@"believe",@"survivors",@"helps",@"likely",@"filename",@"tasks",@"recent",@"education",@"delegated", @"projected"];
        NSUInteger index = arc4random() % strings.count;
        index = (index < strings.count) ? index : (strings.count-1);
        randomWord = strings[index];
        randomWord = [NSString stringWithFormat:@"%@%@", prefix, randomWord];
        
        NSUInteger indexWord2 = arc4random() % dictArray.count;
        indexWord2 = (indexWord2 < dictArray.count) ? indexWord2 : (dictArray.count-1);
        NSString *randomWord2 = dictArray[indexWord2];
        randomWord2 = [randomWord2 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        randomWord = [NSString stringWithFormat:@"%@%@", randomWord, [randomWord2 capitalizedString]];
    }
    return randomWord;
}

- (instancetype)code_stringByRemovingSpace
{
    return [self stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (NSArray *)code_componentsSeparatedBySpace
{
    if (self.code_stringByRemovingSpace.length == 0) return nil;
    return [self componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (instancetype)code_stringWithFilename:(NSString *)filename extension:(NSString *)extension
{
    if (filename.code_stringByRemovingSpace.length == 0) return nil;
    
    return [self stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:filename withExtension:extension] encoding:NSUTF8StringEncoding error:nil];
}

- (NSString *)code_crc32
{
    if (self.length == 0) return nil;
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uLong crc = crc32(0L, Z_NULL, 0);
    crc = crc32(crc, data.bytes, (uInt)data.length);
    return [NSString stringWithFormat:@"%lu", crc];
}
@end

@implementation NSString (URL)

/**
 *  URLEncode
 */
- (NSString *)URLEncodedString
{
    // CharactersToBeEscaped = @":/?&=;+!@#$()~',*";
    // CharactersToLeaveUnescaped = @"[].";
    
    NSString *unencodedString = self;
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)unencodedString,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    
    return encodedString;
}

/**
 *  URLDecode
 */
-(NSString *)URLDecodedString
{
    //NSString *decodedString = [encodedString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding ];
    
    NSString *encodedString = self;
    NSString *decodedString  = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                                     (__bridge CFStringRef)encodedString,
                                                                                                                     CFSTR(""),
                                                                                                                     CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}

@end

