//
//  CodeConfuseCppGarbageCode.m
//  CodeConfuse
//
//  Created by ConfuseCode on 2018/12/25.
//  Copyright © 2018年 All rights reserved.
//

#include <iostream>
#include <sstream>
#include <vector>
#import "CodeConfuseCppGarbageCode.h"
#import "CodeConfuseMethodDeclData.h"
#import "CodeConfuseRandomCode.h"
#import "CodeConfuseOCGarbageCode.h"
#import "ConfuseCore.h"
#import "NSString+Extension.h"

using namespace std;

@implementation CodeConfuseCppGarbageCode

- (instancetype)init
{
    if (self = [super init])
    {
        _cpp_method_call_list = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (string)generate_cpp_class
{
    mix_cpp_class* mc = [self create_class];
    string hfile = [self generate_cpp_class:true mc:mc];
    string cppfile = [self generate_cpp_class:false mc:mc];
    
    [self free:mc];
    
    return hfile + cppfile;
}

- (void)free:(mix_cpp_class*)mc
{
    for (int i=0; i<mc->method_count; i++)
    {
        mix_cpp_method* method = mc->methods[i];
        if(method->params != NULL)
        {
            delete [] method->params;
        }
    }
    delete [] mc->methods;
    delete mc;
}

- (mix_cpp_method*)create_method
{
    mix_cpp_method* method = new mix_cpp_method();
    if ([ConfuseCore sharedInstance].customPrefixString && [ConfuseCore sharedInstance].customPrefixString.length > 0) {
        NSString *prefix = [ConfuseCore sharedInstance].customPrefixString.lowercaseString;
        method->name = [CodeConfuseRandomCode rand_identifierWithPrefix:prefix].UTF8String;
    }
    else {
        method->name = [CodeConfuseRandomCode rand_identifier].UTF8String;
    }
    method->is_static = [CodeConfuseRandomCode rand_bool] && [CodeConfuseRandomCode rand_bool] && [CodeConfuseRandomCode rand_bool];
    method->ret_type = [CodeConfuseRandomCode rand_cpp_ns_type:1];
    method->param_count = [CodeConfuseRandomCode rand_num:0 max:6];
    method->params = new mix_cpp_params*[method->param_count];
    for (int i=0; i<method->param_count; i++)
    {
        method->params[i] = [self create_params:i];
    }
    return method;
}

- (mix_cpp_params*)create_params:(int)index
{
    mix_cpp_params* param = new mix_cpp_params();
    ostringstream s1(param->param_type);
    ostringstream s2(param->param_name);
    string rand_param_type = [CodeConfuseRandomCode get_cpp_ns_type:[CodeConfuseRandomCode rand_cpp_ns_type:1]];
    s1<<rand_param_type<<index;
    s2<<[CodeConfuseRandomCode rand_identifier].UTF8String<<index;
    param->param_type = s1.str();
    param->param_name = s2.str();
    param->ret_type = [CodeConfuseRandomCode rand_cpp_ns_type:2];
    return param;
}

- (mix_cpp_class*)create_class
{
    mix_cpp_class* mc = new mix_cpp_class;
    if ([ConfuseCore sharedInstance].customPrefixString && [ConfuseCore sharedInstance].customPrefixString.length > 0) {
        NSString *prefix = [NSString captializedFirstCharOfString:[ConfuseCore sharedInstance].customPrefixString];
        mc->name = [CodeConfuseRandomCode rand_identifierWithPrefix:prefix].UTF8String;
    }
    else {
        mc->name = [CodeConfuseRandomCode rand_identifier_capitalized].UTF8String;
    }
    mc->method_count = [CodeConfuseRandomCode rand_num:15 max:35];
    mc->methods = new mix_cpp_method*[mc->method_count];
    for (int i=0; i<mc->method_count; i++)
    {
        mc->methods[i] = [self create_method];
    }
    return mc;
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
        case ns_void:
        default:
            return_value = ";";
            break;
    }
    
    return return_value;
}


+ (void)output_code:(Cpp_Define_Code *)cpp_code stream:(ostringstream *)oss
{
    string cpp_var = cpp_code.varString.UTF8String;
    string var_define = cpp_code.defineString.UTF8String;
    
    *oss << "\t" << var_define << "\n";
    
    if (cpp_code.blockBegin && cpp_code.blockBegin.length > 0) {
        
        *oss << "\t" << cpp_code.blockBegin.UTF8String << "\n";
    }
    
    if (cpp_code.callStringArray.count > 1) {
        NSMutableSet *randomSet = [[NSMutableSet alloc] init];
        while ([randomSet count] < [CodeConfuseRandomCode rand_num:1 max:(int)cpp_code.callStringArray.count]) {
            int randomIndex = arc4random() % [cpp_code.callStringArray count];
            [randomSet addObject:[cpp_code.callStringArray objectAtIndex:randomIndex]];
        }
        NSArray *callStringRandomArray = [randomSet allObjects];
        
        for (NSString *callString in callStringRandomArray) {
            string call_string = callString.UTF8String;
            *oss << "\t" << call_string << "\n";
        }
    }
    else {
        for (NSString *callString in cpp_code.callStringArray) {
            string call_string = callString.UTF8String;
            *oss << "\t" << call_string << "\n";
        }
    }
    
    if (cpp_code.blockEnd && cpp_code.blockEnd.length > 0) {
        
        *oss << "\t" << cpp_code.blockEnd.UTF8String << "\n";
    }
}

+ (BOOL)isVarName:(NSString *)varName containsIn:(NSArray *)varDefineArray
{
    for (Cpp_Define_Code *cpp_code in varDefineArray)
    {
        if ([cpp_code.varString isEqualToString:varName])
        {
            return YES;
        }
    }
    return NO;
}

//生成C++ 逻辑
+ (string)generate_cpp_code_with_return_type:(mix_ns_type)return_type
{
    ostringstream oss;
    oss<<"\n";
    
    NSMutableArray *varDefineArray = [[NSMutableArray alloc] init];
    for (int i=0; i<[CodeConfuseRandomCode rand_num:2 max:6]; i++)
    {
        Cpp_Define_Code *cpp_code = [CodeConfuseRandomCode random_cpp_var_define];
        if (![self isVarName:cpp_code.varString containsIn:varDefineArray])
        {
            [self output_code:cpp_code stream:&oss];
            [varDefineArray addObject:cpp_code];
        }
    }
    
    if(return_type != ns_void) {
        
        NSString *returnVarName = @"";
        
        switch (return_type) {
            case ns_char:
            {
                BOOL hasReturnVar = NO;
                for (Cpp_Define_Code *cpp_code in varDefineArray)
                {
                    if (cpp_code.code_type == ns_char)
                    {
                        hasReturnVar = YES;
                        returnVarName = cpp_code.returnVarString;
                    }
                }
                
                if (!hasReturnVar)
                {
                    Cpp_Define_Code *cpp_code = [CodeConfuseRandomCode generate_cpp_var_by_type:ns_char];
                    [self output_code:cpp_code stream:&oss];
                    returnVarName = cpp_code.returnVarString;
                }
            }
                break;
            case ns_int:
            {
                BOOL hasReturnVar = NO;
                for (Cpp_Define_Code *cpp_code in varDefineArray)
                {
                    if (cpp_code.code_type == ns_int)
                    {
                        hasReturnVar = YES;
                        returnVarName = cpp_code.returnVarString;
                    }
                }
                
                if (!hasReturnVar)
                {
                    Cpp_Define_Code *cpp_code = [CodeConfuseRandomCode generate_cpp_var_by_type:ns_int];
                    [self output_code:cpp_code stream:&oss];
                    returnVarName = cpp_code.returnVarString;
                }
            }
                break;
            case ns_float:
            {
                BOOL hasReturnVar = NO;
                for (Cpp_Define_Code *cpp_code in varDefineArray)
                {
                    if (cpp_code.code_type == ns_float)
                    {
                        hasReturnVar = YES;
                        returnVarName = cpp_code.returnVarString;
                    }
                }
                
                if (!hasReturnVar)
                {
                    Cpp_Define_Code *cpp_code = [CodeConfuseRandomCode generate_cpp_var_by_type:ns_float];
                    [self output_code:cpp_code stream:&oss];
                    returnVarName = cpp_code.returnVarString;
                }
            }
                break;
            case ns_double:
            {
                BOOL hasReturnVar = NO;
                for (Cpp_Define_Code *cpp_code in varDefineArray)
                {
                    if (cpp_code.code_type == ns_double)
                    {
                        hasReturnVar = YES;
                        returnVarName = cpp_code.returnVarString;
                    }
                }
                
                if (!hasReturnVar)
                {
                    Cpp_Define_Code *cpp_code = [CodeConfuseRandomCode generate_cpp_var_by_type:ns_double];
                    [self output_code:cpp_code stream:&oss];
                    returnVarName = cpp_code.returnVarString;
                }
            }
                break;
            default:
                break;
        }
        
        NSLog(@"returnVarName = (%@)", returnVarName);
        if (returnVarName.length > 0)
        {
            oss<<"\treturn "<<returnVarName.UTF8String<<";\n";
        }
    }
    
    return oss.str();
}

- (string)generate_cpp_class:(bool)is_header mc:(mix_cpp_class*)mc
{
    ostringstream oss;
    oss<<"\n";
    
    if(is_header)
    {
        oss<<"#include <vector>\n";
        oss<<"#include <string>\n";
        oss<<"#include <fstream>\n";
        oss<<"#include <math.h>\n";
        oss<<"using std::ifstream;\n";
        oss<<"using std::vector;\n";
        
        oss<<"\n";
        oss<<"class "<<mc->name<<" {\n";
        
        oss<<"protected:\n";
        
        NSString *prefix = @"";
        if ([ConfuseCore sharedInstance].customPrefixString && [ConfuseCore sharedInstance].customPrefixString.length > 0) {
            prefix = [ConfuseCore sharedInstance].customPrefixString.lowercaseString;

            for (int i=0; i<[CodeConfuseRandomCode rand_num:5 max:15]; i++) {
                mix_ns_type var_type = [CodeConfuseRandomCode rand_cpp_ns_type:2];
                oss << "\t" << [CodeConfuseRandomCode get_cpp_ns_type:var_type] << " " << [CodeConfuseRandomCode rand_identifierWithPrefix:prefix].UTF8String << ";\n";
            }
        }
        else {
            
            for (int i=0; i<[CodeConfuseRandomCode rand_num:5 max:15]; i++) {
                mix_ns_type var_type = [CodeConfuseRandomCode rand_cpp_ns_type:2];
                prefix = [NSString stringWithFormat:@"%s", [CodeConfuseRandomCode get_cpp_ns_type:var_type].c_str()];
                oss << "\t" << [CodeConfuseRandomCode get_cpp_ns_type:var_type] << " " << [CodeConfuseRandomCode rand_identifierWithPrefix:prefix].UTF8String << ";\n";
            }
        }
        
        oss<<"public:\n";
    }
    
    oss<<"\n";
    for (int m=0; m<mc->method_count; m++)
    {
        mix_cpp_method* method = mc->methods[m];
        
        if (is_header)
        {
            oss<<"\t";
        }
        
        //是否类方法
        if(method->is_static && is_header)
        {
            oss<<"static ";
        }
        else
        {
            oss<<"";
        }
        
        string cpp_action_scope = "";
        if (!is_header)
        {
            cpp_action_scope += mc->name;
            cpp_action_scope += "::";
        }
        
        //函数返回类型
        oss<<[CodeConfuseRandomCode get_cpp_ns_type:method->ret_type]<<" "<<cpp_action_scope<<method->name;
        oss<<"(";
        
        //参数列表
        for(int i=0; i<method->param_count; i++)
        {
            oss<<[CodeConfuseRandomCode get_cpp_ns_type:method->params[i]->ret_type]<<" "<<method->params[i]->param_name;
            //最后一个参数不留空格
            if(i < method->param_count-1)
            {
                oss<<", ";
            }
        }
        
        oss<<")";
        
        NSString *funcCallString = @"";
        
        if (method->param_count > 0)
        {
            if (method->is_static)
            {
                funcCallString = [NSString stringWithFormat:@"\t%s::%s(%@", mc->name.c_str(), method->name.c_str(), [CodeConfuseRandomCode random_cpp_value_by_type:method->params[0]->ret_type]];
            }
            else
            {
                NSString *instanceName = [NSString stringWithFormat:@"%@", [CodeConfuseRandomCode rand_identifier]];
                funcCallString = [funcCallString stringByAppendingString:[NSString stringWithFormat:@"\t%s %@;\n", mc->name.c_str(), instanceName]];
                funcCallString = [funcCallString stringByAppendingString:[NSString stringWithFormat:@"\t%@.%s(%@", instanceName, method->name.c_str(), [CodeConfuseRandomCode random_cpp_value_by_type:method->params[0]->ret_type]]];
            }
            
            for(int i=0; i<method->param_count; i++)
            {
                if(i > 0)
                {
                    funcCallString = [funcCallString stringByAppendingFormat:@",%@",[CodeConfuseRandomCode random_cpp_value_by_type:method->params[i]->ret_type]];
                }
            }
            
            funcCallString = [funcCallString stringByAppendingFormat:@");\n"];
        }
        else
        {
            if (method->is_static)
            {
                funcCallString = [NSString stringWithFormat:@"\t%s::%s();\n", mc->name.c_str(), method->name.c_str()];
            }
            else
            {
                NSString *instanceName = [NSString stringWithFormat:@"%@", [CodeConfuseRandomCode rand_identifier]];
                funcCallString = [funcCallString stringByAppendingString:[NSString stringWithFormat:@"\t%s %@;\n", mc->name.c_str(), instanceName]];
                funcCallString = [funcCallString stringByAppendingString:[NSString stringWithFormat:@"\t%@.%s();\n", instanceName, method->name.c_str()]];
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
            
            oss << [CodeConfuseCppGarbageCode generate_cpp_code_with_return_type:method->ret_type];
            
            oss<<"}\n\n";
        }
        
        NSString *randFileVar = [CodeConfuseRandomCode rand_identifierWithPrefix:[NSString stringWithFormat:@"f_%@_", [CodeConfuseRandomCode rand_string:2 max:5]]];
        NSString *methodCallCheckBegin = [NSString stringWithFormat:@"\n\tifstream %@(\"%@.%@\");\n\tif (%@.good()) {\n", randFileVar, [CodeConfuseRandomCode rand_string:12 max:28], [CodeConfuseRandomCode rand_bool]?@"png":@"jpg", randFileVar];
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
            [self.cpp_method_call_list addObject:declData];
        }
        else
        {
            declData.declMethod = CodeConfuseDeclMethodInstance;
            [self.cpp_method_call_list addObject:declData];
        }
    }
    
    if (is_header)
    {
        oss<<"};";
    }
    
    oss<<"\n";
    return oss.str();
}
@end
