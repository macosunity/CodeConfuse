//
//  CodeConfuseOCGarbageCode.mm
//  CodeConfuse
//
//  Created by ConfuseCode on 2018/12/24.
//  Copyright © 2018年 fkd All rights reserved.
//

#include <iostream>
#include <sstream>
#include <vector>
#import "CodeConfuseMethodDeclData.h"
#import "CodeConfuseRandomCode.h"
#import "CodeConfuseOCGarbageCode.h"
#import "CodeConfuseMixOCModel.h"
#import "ConfuseCore.h"
#import "NSString+Extension.h"

using namespace std;

@implementation CodeConfuseOCGarbageCode

- (instancetype)init
{
    if (self = [super init])
    {
        _class_method_call_list = [[NSMutableArray alloc] init];
        _instance_method_call_list = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)free:(mix_oc_class*)mc
{
    for (int i=0; i<mc->method_count; i++)
    {
        mix_oc_method* method = mc->methods[i];
        if(method->params != NULL)
        {
            delete [] method->params;
        }
    }
    delete [] mc->methods;
    delete mc;
}

- (string)generate_oc_class
{
    mix_oc_class* mc = [self create_class];
    string hfile = [self generate_oc_class:true mc:mc];
    string mfile = [self generate_oc_class:false mc:mc];
    
    [self free:mc];
    
    return hfile + mfile;
}

- (mix_oc_class*)create_class
{
    mix_oc_class* mc = new mix_oc_class;
    if ([ConfuseCore sharedInstance].customPrefixString && [ConfuseCore sharedInstance].customPrefixString.length > 0) {
        NSString *prefix = [NSString captializedFirstCharOfString:[ConfuseCore sharedInstance].customPrefixString];
        mc->name = [CodeConfuseRandomCode rand_identifierWithPrefix:prefix].UTF8String;
    }
    else {
        mc->name = [CodeConfuseRandomCode rand_identifier_capitalized].UTF8String;
    }
    mc->method_count = [CodeConfuseRandomCode rand_num:15 max:35];
    mc->methods = new mix_oc_method*[mc->method_count];
    for (int i=0; i<mc->method_count; i++)
    {
        mc->methods[i] = [self create_method];
    }
    return mc;
}

- (mix_oc_method*)create_method
{
    mix_oc_method* method = new mix_oc_method();
    if ([ConfuseCore sharedInstance].customPrefixString && [ConfuseCore sharedInstance].customPrefixString.length > 0) {
        NSString *prefix = [ConfuseCore sharedInstance].customPrefixString.lowercaseString;
        method->name = [CodeConfuseRandomCode rand_identifierWithPrefix:prefix].UTF8String;
    }
    else {
        method->name = [CodeConfuseRandomCode rand_identifier].UTF8String;
    }
    method->is_static = [CodeConfuseRandomCode rand_bool] && [CodeConfuseRandomCode rand_bool] && [CodeConfuseRandomCode rand_bool];
    method->ret_type = [CodeConfuseRandomCode rand_oc_ns_type:1];
    method->param_count = [CodeConfuseRandomCode rand_num:0 max:6];
    method->params = new mix_oc_params*[method->param_count];
    for (int i=0; i<method->param_count; i++)
    {
        method->params[i] = [self create_params:i];
    }
    return method;
}

//创建参数列表
- (mix_oc_params*)create_params:(int)index
{
    mix_oc_params* param = new mix_oc_params();
    ostringstream s1(param->arg_name);
    ostringstream s2(param->param_name);
    s1<<"arg"<<index;
    s2<<"param"<<index;
    param->arg_name = s1.str();
    param->param_name = s2.str();
    param->ret_type = [CodeConfuseRandomCode rand_oc_ns_type:2];
    return param;
}

+ (void)output_code:(OC_Define_Code *)oc_code stream:(ostringstream *)oss
{
    string oc_var = oc_code.varString.UTF8String;
    string var_define = oc_code.defineString.UTF8String;
    
    *oss << "\t" << var_define << "\n";
    
    if (oc_code.blockBegin && oc_code.blockBegin.length > 0) {
        
        *oss << "\t" << oc_code.blockBegin.UTF8String << "\n";
    }
    
    if (oc_code.callStringArray.count > 1) {
        NSMutableSet *randomSet = [[NSMutableSet alloc] init];
        while ([randomSet count] < [CodeConfuseRandomCode rand_num:1 max:(int)oc_code.callStringArray.count]) {
            int randomIndex = arc4random() % [oc_code.callStringArray count];
            [randomSet addObject:[oc_code.callStringArray objectAtIndex:randomIndex]];
        }
        NSArray *callStringRandomArray = [randomSet allObjects];
        
        for (NSString *callString in callStringRandomArray) {
            string call_string = callString.UTF8String;
            *oss << "\t" << call_string << "\n";
        }
    }
    else {
        for (NSString *callString in oc_code.callStringArray) {
            string call_string = callString.UTF8String;
            *oss << "\t" << call_string << "\n";
        }
    }
    
    if (oc_code.blockEnd && oc_code.blockEnd.length > 0) {
        
        *oss << "\t" << oc_code.blockEnd.UTF8String << "\n";
    }
}

+ (BOOL)isVarName:(NSString *)varName containsIn:(NSArray *)varDefineArray
{
    for (OC_Define_Code *oc_code in varDefineArray)
    {
        if ([oc_code.varString isEqualToString:varName])
        {
            return YES;
        }
    }
    return NO;
}

//生成Objective C方法内逻辑
+ (string)generate_oc_with_return_type:(mix_ns_type)return_type
{
    ostringstream oss;
    oss<<"\n";
    
    NSMutableArray *viewControlsArray = [[NSMutableArray alloc] init];
    NSMutableArray *varDefineArray = [[NSMutableArray alloc] init];
    for (int i=0; i<[CodeConfuseRandomCode rand_num:3 max:5]; i++)
    {
        OC_Define_Code *oc_code = [CodeConfuseRandomCode random_oc_var_define];
        if (![self isVarName:oc_code.varString containsIn:varDefineArray])
        {
            [self output_code:oc_code stream:&oss];
            [varDefineArray addObject:oc_code];
        }
        
        if (oc_code.code_type >= ns_UIWindow && oc_code.code_type <= ns_UIAlertView)
        {
            [viewControlsArray addObject:oc_code];
        }
    }
    
    if ([viewControlsArray count] >=2)
    {
        for (NSUInteger i = [viewControlsArray count]-1; i>0; i--)
        {
            OC_Define_Code *oc_code = [viewControlsArray objectAtIndex:i];
            OC_Define_Code *oc_code_previous = [viewControlsArray objectAtIndex:i-1];
            oc_code_previous.isVarUsed = YES;
            
            NSString *addSubViewString = [NSString stringWithFormat:@"[%@ addSubview:%@];", oc_code.varString, oc_code_previous.varString];
            oss << "\t" << addSubViewString.UTF8String << "\n";
            
            NSString *removeSubViewString = [NSString stringWithFormat:@"[%@ removeFromSuperview];", oc_code_previous.varString];
            oss << "\t" << removeSubViewString.UTF8String << "\n";
        }
    }
    
    for (NSUInteger vIndex = [varDefineArray count]-1; vIndex>0; vIndex--)
    {
        OC_Define_Code *oc_code = [varDefineArray objectAtIndex:vIndex];
        OC_Define_Code *oc_code_previous = [varDefineArray objectAtIndex:vIndex-1];
        if (!oc_code.isVarUsed)
        {
            NSString *setDataString = [NSString stringWithFormat:@"[%@ setValue:%@ %@:@\"%@\"];", oc_code.varString, oc_code_previous.varString,
                                       [CodeConfuseRandomCode rand_for_key:vIndex]
                                       , [CodeConfuseRandomCode rand_identifierWithPrefix:@"key_"]];
            oss << "\t" << setDataString.UTF8String << "\n";
        }
    }
    
    if(return_type != ns_void) {
        
        NSString *returnVarName = @"";
        
        switch (return_type)
        {
            case ns_char:
            {
                char randomChar = [CodeConfuseRandomCode rand_char];
                string varName = [CodeConfuseRandomCode rand_identifierWithPrefix:@"ch"].UTF8String;
                NSString *defineChar = [NSString stringWithFormat:@"char %s = '%c';", varName.c_str(), randomChar];
                oss << "\t" << defineChar.UTF8String << "\n";
                returnVarName = [NSString stringWithFormat:@"%s", varName.c_str()];
            }
                break;
            case ns_int:
            {
                int randomInt = [CodeConfuseRandomCode rand_num:0 max:65535];
                string varName = [CodeConfuseRandomCode rand_identifierWithPrefix:@"i"].UTF8String;
                NSString *defineInt = [NSString stringWithFormat:@"int %s = %d;", varName.c_str(), randomInt];
                oss << "\t" << defineInt.UTF8String << "\n";
                returnVarName = [NSString stringWithFormat:@"%s", varName.c_str()];
            }
                break;
            case ns_float:
            {
                float randomFloat = [CodeConfuseRandomCode random_float:0.0 max:99999.0];
                string varName = [CodeConfuseRandomCode rand_identifierWithPrefix:@"float"].UTF8String;
                NSString *defineFloat = [NSString stringWithFormat:@"float %s = %lf;", varName.c_str(), randomFloat];
                oss << "\t" << defineFloat.UTF8String << "\n";
                returnVarName = [NSString stringWithFormat:@"%s", varName.c_str()];
            }
                break;
            case ns_double:
            {
                double randomDouble = [CodeConfuseRandomCode rand_num:0.0 max:99999.0];
                string varName = [CodeConfuseRandomCode rand_identifierWithPrefix:@"double"].UTF8String;
                NSString *defineDouble = [NSString stringWithFormat:@"double %s = %lf;", varName.c_str(), randomDouble];
                oss << "\t" << defineDouble.UTF8String << "\n";
                returnVarName = [NSString stringWithFormat:@"%s", varName.c_str()];
            }
                break;
            
            case ns_NSObject:
            {
                for(int i=0; i<varDefineArray.count; i++)
                {
                    OC_Define_Code *oc_code = [varDefineArray objectAtIndex:i];
                    if (oc_code.code_type == ns_NSObject) {
                        returnVarName = oc_code.varString;
                        break;
                    }
                }
                
                if (returnVarName.length == 0) {
                    
                    OC_Define_Code *oc_code = [CodeConfuseRandomCode generate_oc_var_by_type:ns_NSObject];
                    [self output_code:oc_code stream:&oss];
                    returnVarName = oc_code.varString;
                }
            }
                break;
            case ns_NSString:
            {
                for(int i=0; i<varDefineArray.count; i++)
                {
                    OC_Define_Code *oc_code = [varDefineArray objectAtIndex:i];
                    if (oc_code.code_type == ns_NSString) {
                        returnVarName = oc_code.varString;
                        break;
                    }
                }
                
                if (returnVarName.length == 0) {
                    
                    OC_Define_Code *oc_code = [CodeConfuseRandomCode generate_oc_var_by_type:ns_NSString];
                    [self output_code:oc_code stream:&oss];
                    returnVarName = oc_code.varString;
                }
            }
                break;
            case ns_NSSet:
            {
                for(int i=0; i<varDefineArray.count; i++)
                {
                    OC_Define_Code *oc_code = [varDefineArray objectAtIndex:i];
                    if (oc_code.code_type == ns_NSSet) {
                        returnVarName = oc_code.varString;
                        break;
                    }
                }
                
                if (returnVarName.length == 0) {
                    
                    OC_Define_Code *oc_code = [CodeConfuseRandomCode generate_oc_var_by_type:ns_NSSet];
                    [self output_code:oc_code stream:&oss];
                    returnVarName = oc_code.varString;
                }
            }
                break;
            case ns_NSArray:
            {
                for(int i=0; i<varDefineArray.count; i++)
                {
                    OC_Define_Code *oc_code = [varDefineArray objectAtIndex:i];
                    if (oc_code.code_type == ns_NSArray) {
                        returnVarName = oc_code.varString;
                        break;
                    }
                }
                
                if (returnVarName.length == 0) {
                    
                    OC_Define_Code *oc_code = [CodeConfuseRandomCode generate_oc_var_by_type:ns_NSArray];
                    [self output_code:oc_code stream:&oss];
                    returnVarName = oc_code.varString;
                }
            }
                break;
            case ns_NSDictionary:
            {
                for(int i=0; i<varDefineArray.count; i++)
                {
                    OC_Define_Code *oc_code = [varDefineArray objectAtIndex:i];
                    if (oc_code.code_type == ns_NSDictionary) {
                        returnVarName = oc_code.varString;
                        break;
                    }
                }
                
                if (returnVarName.length == 0) {
                    
                    OC_Define_Code *oc_code = [CodeConfuseRandomCode generate_oc_var_by_type:ns_NSDictionary];
                    [self output_code:oc_code stream:&oss];
                    returnVarName = oc_code.varString;
                }
            }
                break;
            case ns_UIColor:
            {
                for(int i=0; i<varDefineArray.count; i++)
                {
                    OC_Define_Code *oc_code = [varDefineArray objectAtIndex:i];
                    if (oc_code.code_type == ns_UIColor) {
                        returnVarName = oc_code.varString;
                        break;
                    }
                }
                
                if (returnVarName.length == 0) {
                    OC_Define_Code *oc_code = [CodeConfuseRandomCode generate_oc_var_by_type:ns_UIColor];
                    [self output_code:oc_code stream:&oss];
                    returnVarName = oc_code.varString;
                }
            }
                break;
            case ns_UIWindow:
            {
                for(int i=0; i<varDefineArray.count; i++)
                {
                    OC_Define_Code *oc_code = [varDefineArray objectAtIndex:i];
                    if (oc_code.code_type == ns_UIWindow) {
                        returnVarName = oc_code.varString;
                        break;
                    }
                }
                
                if (returnVarName.length == 0) {
                    
                    OC_Define_Code *oc_code = [CodeConfuseRandomCode generate_oc_var_by_type:ns_UIWindow];
                    [self output_code:oc_code stream:&oss];
                    returnVarName = oc_code.varString;
                }
            }
                break;
            case ns_UISlider:
            {
                for(int i=0; i<varDefineArray.count; i++)
                {
                    OC_Define_Code *oc_code = [varDefineArray objectAtIndex:i];
                    if (oc_code.code_type == ns_UISlider) {
                        returnVarName = oc_code.varString;
                        break;
                    }
                }
                
                if (returnVarName.length == 0) {
                    
                    OC_Define_Code *oc_code = [CodeConfuseRandomCode generate_oc_var_by_type:ns_UISlider];
                    [self output_code:oc_code stream:&oss];
                    returnVarName = oc_code.varString;
                }
            }
                break;
            case ns_UIStepper:
            {
                for(int i=0; i<varDefineArray.count; i++)
                {
                    OC_Define_Code *oc_code = [varDefineArray objectAtIndex:i];
                    if (oc_code.code_type == ns_UIStepper) {
                        returnVarName = oc_code.varString;
                        break;
                    }
                }
                
                if (returnVarName.length == 0) {
                    
                    OC_Define_Code *oc_code = [CodeConfuseRandomCode generate_oc_var_by_type:ns_UIStepper];
                    [self output_code:oc_code stream:&oss];
                    returnVarName = oc_code.varString;
                }
            }
                break;
            case ns_UISwitch:
            {
                for(int i=0; i<varDefineArray.count; i++)
                {
                    OC_Define_Code *oc_code = [varDefineArray objectAtIndex:i];
                    if (oc_code.code_type == ns_UISwitch) {
                        returnVarName = oc_code.varString;
                        break;
                    }
                }
                
                if (returnVarName.length == 0) {
                    
                    OC_Define_Code *oc_code = [CodeConfuseRandomCode generate_oc_var_by_type:ns_UISwitch];
                    [self output_code:oc_code stream:&oss];
                    returnVarName = oc_code.varString;
                }
            }
                break;
            case ns_UITableView:
            {
                for(int i=0; i<varDefineArray.count; i++)
                {
                    OC_Define_Code *oc_code = [varDefineArray objectAtIndex:i];
                    if (oc_code.code_type == ns_UITableView) {
                        returnVarName = oc_code.varString;
                        break;
                    }
                }
                
                if (returnVarName.length == 0) {
                    
                    OC_Define_Code *oc_code = [CodeConfuseRandomCode generate_oc_var_by_type:ns_UITableView];
                    [self output_code:oc_code stream:&oss];
                    returnVarName = oc_code.varString;
                }
            }
                break;
            case ns_UICollectionView:
            {
                for(int i=0; i<varDefineArray.count; i++)
                {
                    OC_Define_Code *oc_code = [varDefineArray objectAtIndex:i];
                    if (oc_code.code_type == ns_UICollectionView) {
                        returnVarName = oc_code.varString;
                        break;
                    }
                }
                
                if (returnVarName.length == 0) {
                    
                    OC_Define_Code *oc_code = [CodeConfuseRandomCode generate_oc_var_by_type:ns_UICollectionView];
                    [self output_code:oc_code stream:&oss];
                    returnVarName = oc_code.varString;
                }
            }
                break;
                
            case ns_UIImage:
            {
                for(int i=0; i<varDefineArray.count; i++)
                {
                    OC_Define_Code *oc_code = [varDefineArray objectAtIndex:i];
                    if (oc_code.code_type == ns_UIImage) {
                        returnVarName = oc_code.varString;
                        break;
                    }
                }
                
                if (returnVarName.length == 0) {
                    
                    OC_Define_Code *oc_code = [CodeConfuseRandomCode generate_oc_var_by_type:ns_UIImage];
                    [self output_code:oc_code stream:&oss];
                    returnVarName = oc_code.varString;
                }
            }
                break;
                
            case ns_UIAlertView:
            {
                for(int i=0; i<varDefineArray.count; i++)
                {
                    OC_Define_Code *oc_code = [varDefineArray objectAtIndex:i];
                    if (oc_code.code_type == ns_UIAlertView) {
                        returnVarName = oc_code.varString;
                        break;
                    }
                }
                
                if (returnVarName.length == 0) {
                    
                    OC_Define_Code *oc_code = [CodeConfuseRandomCode generate_oc_var_by_type:ns_UIAlertView];
                    [self output_code:oc_code stream:&oss];
                    returnVarName = oc_code.varString;
                }
            }
                break;
                
            case ns_UITabBar:
            {
                for(int i=0; i<varDefineArray.count; i++)
                {
                    OC_Define_Code *oc_code = [varDefineArray objectAtIndex:i];
                    if (oc_code.code_type == ns_UITabBar) {
                        returnVarName = oc_code.varString;
                        break;
                    }
                }
                
                if (returnVarName.length == 0) {
                    
                    OC_Define_Code *oc_code = [CodeConfuseRandomCode generate_oc_var_by_type:ns_UITabBar];
                    [self output_code:oc_code stream:&oss];
                    returnVarName = oc_code.varString;
                }
            }
                break;
                
            default:
                break;
        }
        oss<<"\treturn "<<returnVarName.UTF8String<<";\n";
    }
    
    return oss.str();
}

- (string)generate_oc_class:(bool)is_header mc:(mix_oc_class*)mc
{
    ostringstream oss;
    oss<<"\n";
    
    if(is_header)
    {
        oss<<"#import <UIKit/UIKit.h>\n";
        oss<<"\n";
        
        oss<<"@interface "<<mc->name<<" : "<<"NSObject<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource>\n";
        
        NSString *prefix = @"";
        if ([ConfuseCore sharedInstance].customPrefixString && [ConfuseCore sharedInstance].customPrefixString.length > 0) {
            prefix = [ConfuseCore sharedInstance].customPrefixString.lowercaseString;
            
            for (int i=0; i<[CodeConfuseRandomCode rand_num:5 max:15]; i++) {
                mix_ns_type var_type = [CodeConfuseRandomCode rand_oc_ns_type:2];
                oss << "@property (" << [CodeConfuseRandomCode rand_oc_property_attributes:var_type] << ") " << [CodeConfuseRandomCode get_oc_ns_type:var_type] << " " << [CodeConfuseRandomCode rand_identifierWithPrefix:prefix].UTF8String << ";\n";
            }
        }
        else {
            
            for (int i=0; i<[CodeConfuseRandomCode rand_num:5 max:15]; i++) {
                mix_ns_type var_type = [CodeConfuseRandomCode rand_oc_ns_type:2];
                prefix = [NSString stringWithFormat:@"%s", [CodeConfuseRandomCode get_prefix_from_ns_type:var_type].c_str()];
                oss << "@property (" << [CodeConfuseRandomCode rand_oc_property_attributes:var_type] << ") " << [CodeConfuseRandomCode get_oc_ns_type:var_type] << " " << [CodeConfuseRandomCode rand_identifierWithPrefix:prefix].UTF8String << ";\n";
            }
        }
    }
    else
    {
        oss<<"@implementation "<<mc->name<<"\n";
    }
    oss<<"\n";
    
    for (int m=0; m<mc->method_count; m++)
    {
        mix_oc_method* method = mc->methods[m];
        //是否类方法
        if(method->is_static)
        {
            oss<<"+";
        }
        else
        {
            oss<<"-";
        }
        
        //函数返回类型
        oss<<" ("<<[CodeConfuseRandomCode get_oc_ns_type:method->ret_type]<<")"<<method->name;
        if(method->param_count > 0)
        {
            oss<<":";
        }
        
        //参数列表
        for(int i=0; i<method->param_count; i++)
        {
            //第一个参数不加名字
            if(i > 0)
            {
                oss<<method->params[i]->arg_name<<":";
            }
            oss<<"("<<[CodeConfuseRandomCode get_oc_ns_type:method->params[i]->ret_type]<<")"<<method->params[i]->param_name;
            //最后一个参数不留空格
            if(i < method->param_count-1)
            {
                oss<<" ";
            }
        }
        
        NSString *funcCallString = @"";
        
        if (method->param_count > 0)
        {
            if (method->is_static)
            {
                funcCallString = [NSString stringWithFormat:@"\t[%s %s:%@", mc->name.c_str(), method->name.c_str(), [CodeConfuseRandomCode random_value_by_type:method->params[0]->ret_type]];
            }
            else
            {
                
                funcCallString = [NSString stringWithFormat:@"\t[[[%s alloc] init] %s:%@", mc->name.c_str(), method->name.c_str(), [CodeConfuseRandomCode random_value_by_type:method->params[0]->ret_type]];
            }
            
            for(int i=0; i<method->param_count; i++)
            {
                if(i > 0)
                {
                    funcCallString = [funcCallString stringByAppendingFormat:@" %s:%@", method->params[i]->arg_name.c_str(),[CodeConfuseRandomCode random_value_by_type:method->params[i]->ret_type]];
                }
            }
            
            funcCallString = [funcCallString stringByAppendingFormat:@"];\n"];
        }
        else
        {
            if (method->is_static)
            {
                funcCallString = [NSString stringWithFormat:@"\t[%s %s];\n", mc->name.c_str(), method->name.c_str()];
            }
            else
            {
                funcCallString = [NSString stringWithFormat:@"\t[[[%s alloc] init] %s];\n", mc->name.c_str(), method->name.c_str()];
            }
        }
        
        NSLog(@"funcCallString: %@", funcCallString);
        
        //函数结尾
        if(is_header)
        {
            oss<<";\n";
        }
        else
        {
            oss<<"\n{\n";
            
            oss << [CodeConfuseOCGarbageCode generate_oc_with_return_type:method->ret_type];
            
            oss<<"}\n\n";
        }
        
        NSString *methodCallCheckBegin = [NSString stringWithFormat:@"\n\tif ([[NSUserDefaults standardUserDefaults] objectForKey:@\"%@\"]) {\n", [CodeConfuseRandomCode rand_string:10 max:25]];
        NSString *methodCallCheckEnd = @"\t}\n";
        
        // 生成简单的随机模板方法 没有参数, 可以适当的添加参数
        CodeConfuseMethodDeclData* declData = [CodeConfuseMethodDeclData new];
        // 方法调用
        declData.callText = [NSString stringWithFormat:@"%@\t%@%@", methodCallCheckBegin, funcCallString, methodCallCheckEnd];
        
        // 方法实现
        declData.declText = @"";
        // 方法类型
        if (method->is_static)
        {
            declData.declMethod = CodeConfuseDeclMethodClass;
            [self.class_method_call_list addObject:declData];
        }
        else
        {
            declData.declMethod = CodeConfuseDeclMethodInstance;
            [self.instance_method_call_list addObject:declData];
        }
    }
    oss<<"@end\n";
    return oss.str();
}

- (string)get_default_value:(mix_ns_type)nstype
{
    string return_value = "";
    switch (nstype)
    {
        case ns_int:
        {
            return_value += "= ";
            return_value += std::to_string(arc4random()%200);
            return_value +=";";
        }
            break;
        case ns_float:
        {
            return_value += "= ";
            return_value += std::to_string([CodeConfuseRandomCode random_float:1.0 max:1000.0]);
            return_value +=";";
        }
            break;
        case ns_double:
        {
            return_value += "= ";
            return_value += std::to_string([CodeConfuseRandomCode random_double:10.0 max:3000.0]);
            return_value +=";";
        }
            break;
        case ns_char:
        {
            return_value += "= '";
            return_value += [CodeConfuseRandomCode rand_num_range:26] + ([CodeConfuseRandomCode rand_bool] ? 64 : 96);
            return_value +="';";
        }
            break;
        case ns_NSObject:
        {
            return_value = "= [[NSObject alloc] init];";
        }
            break;
        case ns_NSSet:
        {
            return_value = "= [[NSSet alloc] init];";
        }
            break;
        case ns_NSArray:
        {
            return_value = "= [[NSArray alloc] init];";
        }
            break;
        case ns_NSString:
        {
            return_value = "= [[NSString alloc] init];";
        }
            break;
        case ns_NSDictionary:
        {
            return_value = "= [[NSDictionary alloc] init];";
        }
            break;
        case ns_void:
        default:
            return_value = ";";
            break;
    }
    
    return return_value;
}

@end
