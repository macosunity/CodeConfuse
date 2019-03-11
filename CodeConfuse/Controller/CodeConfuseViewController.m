//
//  CodeConfuseViewController.m
//  CodeConfuse
//
//  Created by ConfuseCode on 2018/11/17.
//  Copyright © 2018年 All rights reserved.
//

#import "CodeConfuseViewController.h"
#import "NSFileManager+Extension.h"
#import "NSString+Extension.h"
#import "ConfuseCore.h"
#import "GarbageCodeCore.h"
#import "CustomMarqueeLabel.h"
#import "SSZipArchive.h"

@interface CodeConfuseViewController()
@property (weak) IBOutlet NSButton *openBtn;
@property (weak) IBOutlet NSButton *chooseBtn;
@property (weak) IBOutlet NSButton *backupBtn;
@property (weak) IBOutlet NSButton *startBtn;
@property (weak) IBOutlet CustomMarqueeLabel *filepathLabel;
@property (copy) NSString *filepath;
@property (copy) NSString *destFilepath;
@property (copy) NSString *backupFilepath;
@property (weak) IBOutlet NSTextField *destFilepathLabel;
@property (weak) IBOutlet NSTextField *prefixFiled;
@property (weak) IBOutlet NSButton *cbxClassNameConfuse;
@property (weak) IBOutlet NSButton *cbxGarbageCodeInject;
@property (weak) IBOutlet NSButton *lowLevelConfuseRadioButton;
@property (weak) IBOutlet NSButton *highLevelConfuseRadioButton;
@property (weak) IBOutlet NSTextField *customPrefixField;

@end

@implementation CodeConfuseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backupBtn.enabled = NO;
    self.openBtn.enabled = NO;
    self.filepathLabel.stringValue = @"";
    self.destFilepathLabel.stringValue = @"";
}

- (IBAction)chooseFile:(NSButton *)sender {
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.prompt = @"选择";
    openPanel.canChooseDirectories = YES;
    openPanel.canChooseFiles = NO;
    [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse result) {
        if (result != NSModalResponseOK) return;
        
        NSMutableArray* filePaths = [[NSMutableArray alloc] init];
        for (NSURL* elemnet in [openPanel URLs]) {
            [filePaths addObject:[elemnet path]];
            if ([elemnet path] != nil) {
                self.filepath = [elemnet path];
            }
        }
        NSLog(@"!!! %@", [openPanel URLs]);
        
        self.filepathLabel.stringValue = [@"当前混淆目录：" stringByAppendingFormat:@"%@", self.filepath];
        self.destFilepath = nil;
        self.destFilepathLabel.stringValue = @"";
        self.openBtn.enabled = YES;
        self.backupBtn.enabled = YES;
    }];
}

- (IBAction)openFile:(NSButton *)sender {
    
    NSString *file = self.destFilepath ? self.destFilepath : self.filepath;
    NSArray *fileURLs = @[[NSURL fileURLWithPath:file]];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:fileURLs];
}

- (IBAction)chooseConfuseLevel:(id)sender {
    
}

- (IBAction)openBackupFolder:(id)sender {
    
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSLog(@"cachePath: %@", cachePath);
    self.backupFilepath = cachePath;
    
    NSString *file = self.backupFilepath ? self.backupFilepath : self.filepath;
    NSArray *fileURLs = @[[NSURL fileURLWithPath:file]];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:fileURLs];
}


- (void)showMessage:(NSString *)alertMessage {
    
    NSAlert *alert = [NSAlert new];
    [alert addButtonWithTitle:@"确定"];
    [alert setMessageText:@"提示"];
    [alert setInformativeText:alertMessage];
    [alert setAlertStyle:NSAlertStyleInformational];
    [alert beginSheetModalForWindow:[self.view window] completionHandler:nil];
}

- (IBAction)start:(NSButton *)sender {
    
    if (self.cbxClassNameConfuse.state == NSControlStateValueOn &&
        ([self.prefixFiled.stringValue code_stringByRemovingSpace].length == 0 ||
         ![self.prefixFiled.stringValue containsString:@">"]) ) {
        [self showMessage:@"请按照：原类名前缀>新类名前缀 格式填写！"];
        
        return;
    }
    
    if (self.cbxGarbageCodeInject.state == NSControlStateValueOn &&
        (self.filepath == nil || self.filepath.length == 0))
    {
        [self showMessage:@"请选择要混淆的项目工程目录！"];
        
        return;
    }
    
    [ConfuseCore sharedInstance].isHighLevelConfuse = NO;
    
    if (self.highLevelConfuseRadioButton.state == NSControlStateValueOn) {
        [ConfuseCore sharedInstance].isHighLevelConfuse = YES;
    }
    
    [ConfuseCore sharedInstance].customPrefixString = @"";
    if ([self.customPrefixField.stringValue code_stringByRemovingSpace].length > 0) {
        [ConfuseCore sharedInstance].customPrefixString = self.customPrefixField.stringValue;
    }
    
    self.destFilepath = nil;
    self.destFilepathLabel.stringValue = @"";
    self.startBtn.enabled = NO;
    self.openBtn.enabled = NO;
    self.chooseBtn.enabled = NO;
    self.backupBtn.enabled = NO;
    self.prefixFiled.enabled = NO;
    self.cbxClassNameConfuse.enabled = NO;
    self.cbxGarbageCodeInject.enabled = NO;
    
    // 获得前缀
    NSArray *prefixes = [self.prefixFiled.stringValue componentsSeparatedByString:@">"];
    NSLog(@"prefixes: %@", prefixes);
    
    // 处理进度
    void (^progress)(NSString *) = ^(NSString *detail) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (detail && detail.length > 0) {
                self.destFilepathLabel.stringValue = detail;
            }
        });
    };
    
    void (^completion)(NSString *, BOOL) = ^(NSString *tips, BOOL isEnableButton) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (tips && tips.length > 0) {
                self.destFilepathLabel.stringValue = tips;
            }
            
            if (isEnableButton) {
                self.chooseBtn.enabled = YES;
                self.backupBtn.enabled = YES;
                self.openBtn.enabled = YES;
                self.startBtn.enabled = YES;
                self.prefixFiled.enabled = YES;
                
                self.cbxClassNameConfuse.enabled = YES;
                self.cbxGarbageCodeInject.enabled = YES;
            }
        });
    };
    
    [ConfuseCore sharedInstance].projectRootPath = self.filepath;
    
    NSString *shellCommand = [NSString stringWithFormat:@"find '%@' -name \"*.xcodeproj\"", self.filepath];
    NSLog(@"根目录: %@", self.filepath);
    NSString *projectPath = [ConfuseCore excuteShellWithScript:shellCommand path:self.filepath];
    NSLog(@"projectPath : %@", projectPath);
    
    BOOL isProjectFileExist = NO;
    NSMutableString *projectContent = nil;
    NSString *projectFilePath = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:projectPath]) {
        isProjectFileExist = YES;
        
        projectFilePath = [[projectPath stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByAppendingPathComponent:@"project.pbxproj"];
        NSLog(@"projectFilePath is : %@", projectFilePath);
        
        //读取工程文件
        NSError *error = nil;
        projectContent = [NSMutableString stringWithContentsOfFile:projectFilePath encoding:NSUTF8StringEncoding error:&error];
        if (error && self.cbxClassNameConfuse.state == NSControlStateValueOn) {
            printf("打开工程文件 %s 失败：%s\n", projectFilePath.UTF8String, error.localizedDescription.UTF8String);
            completion(@"", YES);
            [self showMessage:@"读取工程文件失败，请确认选择的目录中包含Xcode工程文件!"];
            return;
        }
    }
    
    progress(@"正在备份代码...");

    if (self.cbxClassNameConfuse.state == NSControlStateValueOn && self.cbxGarbageCodeInject.state == NSControlStateValueOn) {

        dispatch_queue_t queue = dispatch_queue_create("com.confusetool.queue", DISPATCH_QUEUE_CONCURRENT);
        
        dispatch_async(queue, ^{
            
            dispatch_async(queue, ^{
                
                NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
                NSLog(@"cachePath: %@", cachePath);
                NSString *zipPath = [NSString stringWithFormat:@"%@/code_backup_%llu.zip", cachePath, (unsigned long long)[[NSDate date] timeIntervalSince1970] ];
                BOOL success = [SSZipArchive createZipFileAtPath:zipPath
                                         withContentsOfDirectory:self.filepath
                                             keepParentDirectory:NO
                                                compressionLevel:-1
                                                        password:nil
                                                             AES:YES
                                                 progressHandler:nil];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (success) {
                        progress(@"备份成功！");
                    } else {
                        progress(@"备份失败！");
                    }
                });
            });
            
            dispatch_barrier_async(queue, ^{
                NSLog(@"dispatch_barrier_async === %@", [NSThread currentThread]);
            });
            
            //类名前缀混淆
            [ConfuseCore confuseCodeAtDir:self.filepath isEndEnable:NO projectContent:projectContent projectFilePath:projectFilePath dispatch_queue:queue withPrefixes:prefixes progress:progress completion:completion];
            
            dispatch_barrier_async(queue, ^{
                NSLog(@"dispatch_barrier_async === %@", [NSThread currentThread]);
            });

            //垃圾代码注入
            [GarbageCodeCore generateCodeAtDir:self.filepath dispatch_queue:queue progress:progress completion:completion];

        });
    }
    else {
        
        __block ConfuseType confuseType = ConfuseTypeClassName;
        //类名前缀混淆
        if (self.cbxClassNameConfuse.state == NSControlStateValueOn) {
            confuseType = ConfuseTypeClassName;
        }
        //垃圾代码注入
        else if (self.cbxGarbageCodeInject.state == NSControlStateValueOn) {
            confuseType = ConfuseTypeCodeInjection;
        }
        else {
            confuseType = ConfuseTypeNone;
        }
        
        dispatch_queue_t queue = dispatch_queue_create("com.confusetool.queue", DISPATCH_QUEUE_CONCURRENT);
        
        dispatch_async(queue, ^{
            
            dispatch_async(queue, ^{
                
                NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
                NSLog(@"cachePath: %@", cachePath);
                NSString *zipPath = [NSString stringWithFormat:@"%@/code_backup_%llu.zip", cachePath, (unsigned long long)[[NSDate date] timeIntervalSince1970] ];
                BOOL success = [SSZipArchive createZipFileAtPath:zipPath
                                         withContentsOfDirectory:self.filepath
                                             keepParentDirectory:NO
                                                compressionLevel:-1
                                                        password:nil
                                                             AES:YES
                                                 progressHandler:nil];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (success) {
                        progress(@"备份成功！");
                    } else {
                        progress(@"备份失败！");
                    }
                });
            });
            
            dispatch_barrier_async(queue, ^{
                NSLog(@"dispatch_barrier_async === %@", [NSThread currentThread]);
            });
        
            //类名前缀混淆
            if (confuseType == ConfuseTypeClassName) {
                
                [GarbageCodeCore convertEncodingInDir:self.filepath dispatch_queue:queue progress:progress completion:nil];

                dispatch_barrier_async(queue, ^{
                    NSLog(@"dispatch_barrier_async === %@", [NSThread currentThread]);
                });
                
                [ConfuseCore confuseCodeAtDir:self.filepath isEndEnable:YES projectContent:projectContent projectFilePath:projectFilePath dispatch_queue:queue withPrefixes:prefixes progress:progress completion:completion];
            }
            //垃圾代码注入
            else if (confuseType == ConfuseTypeCodeInjection) {
                [GarbageCodeCore generateCodeAtDir:self.filepath dispatch_queue:queue progress:progress completion:completion];
            }
            else {
                [GarbageCodeCore convertEncodingInDir:self.filepath dispatch_queue:queue progress:progress completion:completion];
            }
        });
    }

}

@end
