//
//  CodeConfuseRandomCode.mm
//  CodeConfuse
//
//  Created by ConfuseCode on 2018/12/24.
//  Copyright © 2018年 fkd All rights reserved.
//

#include "CodeConfuseRandomCode.h"
#import "NSString+Extension.h"

@implementation OC_Define_Code

@end

@implementation Cpp_Define_Code

@end

@implementation CodeConfuseRandomCode

//根据nstype获取描述
+ (string)get_oc_ns_type:(mix_ns_type)nstype
{
    switch (nstype) {
        case ns_void:
            return "void";
        case ns_char:
            return "char";
        case ns_int:
            return "int";
        case ns_float:
            return "float";
        case ns_double:
            return "double";
        case ns_NSObject:
            return "NSObject*";
        case ns_NSSet:
            return "NSSet*";
        case ns_NSArray:
            return "NSArray*";
        case ns_NSString:
            return "NSString*";
        case ns_NSDictionary:
            return "NSDictionary*";
        case ns_UIColor:
            return "UIColor*";
        case ns_UIWindow:
            return "UIWindow*";
        case ns_UISlider:
            return "UISlider*";
        case ns_UIStepper:
            return "UIStepper*";
        case ns_UISwitch:
            return "UISwitch*";
        case ns_UITableView:
            return "UITableView*";
        case ns_UICollectionView:
            return "UICollectionView*";
        case ns_UIAlertView:
            return "UIAlertView*";
        case ns_UITabBar:
            return "UITabBar*";
        case ns_UIImage:
            return "UIImage*";
        default:
            return "void";
    }
    return "void";
}

//生成对应类型变量名称的前缀
+ (string)get_prefix_from_ns_type:(mix_ns_type)nstype
{
    switch (nstype) {
        case ns_void:
            return "vo";
        case ns_char:
            return "ch";
        case ns_int:
            return "i";
        case ns_float:
            return "float";
        case ns_double:
            return "double";
        case ns_NSObject:
            return "obj";
        case ns_NSSet:
            return "set";
        case ns_NSArray:
            return "array";
        case ns_NSString:
            return "str";
        case ns_NSDictionary:
            return "dict";
        case ns_UIColor:
            return "color";
        case ns_UIWindow:
            return "win";
        case ns_UISwitch:
            return "swtch";
        case ns_UIStepper:
            return "step";
        case ns_UISlider:
            return "slider";
        case ns_UITableView:
            return "tableView";
        case ns_UICollectionView:
            return "collectionView";
        case ns_UITabBar:
            return "tab";
        case ns_UIImage:
            return "img";
        case ns_UIAlertView:
            return "alert";
        default:
            return "void";
    }
    return "void";
}

+ (string)get_cpp_ns_type:(mix_ns_type)nstype
{
    switch (nstype) {
        case ns_void:
            return "void";
        case ns_char:
            return "char";
        case ns_int:
            return "int";
        case ns_float:
            return "float";
        case ns_double:
            return "double";
        default:
            return "void";
    }
    return "void";
}

+ (string)rand_oc_property_attributes:(mix_ns_type)nstype
{
    string attribute_str = [self rand_bool] ? "atomic,":"nonatomic,";
    if (nstype > 5)
    {
        if (nstype == ns_NSString)
        {
            if ([self rand_num:5 max:150] % 2 == 0)
            {
                if ([self rand_num:8 max:300] % 2 == 0)
                {
                    if ([self rand_num:10 max:2000] % 2 == 0)
                    {
                        attribute_str.append("strong");
                    }
                    else
                    {
                        attribute_str.append("copy");
                    }
                }
                else
                {
                    attribute_str.append("weak");
                }
            }
            else
            {
                attribute_str.append("retain");
            }
        }
        else
        {
            if ([self rand_num:8 max:100] % 2 == 0)
            {
                if ([self rand_num:15 max:500] % 2 == 0)
                {
                    attribute_str.append("strong");
                }
                else
                {
                    attribute_str.append("weak");
                }
            }
            else
            {
                attribute_str.append("retain");
            }
        }
    }
    else
    {
        attribute_str.append("assign");
    }
    
    return attribute_str;
}

+ (NSString *)random_value_by_type:(mix_ns_type)nstype
{
    switch (nstype) {
        case ns_void:
            return @"NULL";
        case ns_char:
            return [NSString stringWithFormat:@"'%c'", [CodeConfuseRandomCode rand_num_range:26] + ([CodeConfuseRandomCode rand_bool] ? 64 : 96)];
        case ns_int:
            return [NSString stringWithFormat:@"%d", [CodeConfuseRandomCode rand_num:10 max:65535]];
        case ns_float:
            return [NSString stringWithFormat:@"%f", [CodeConfuseRandomCode random_float:3.0f max:3000.0f]];
        case ns_double:
            return [NSString stringWithFormat:@"%lf", [CodeConfuseRandomCode random_double:20.0 max:5000.0]];
        case ns_NSObject:
            return [NSString stringWithFormat:@"[[NSObject alloc] init]"];
        case ns_NSSet:
            return [NSString stringWithFormat:@"[[NSSet alloc] init]"];
        case ns_NSArray:
            return [NSString stringWithFormat:@"[[NSArray alloc] init]"];
        case ns_NSString:
            return [NSString stringWithFormat:@"@\"%@\"", [self rand_string:5 max:100]];
        case ns_NSDictionary:
            return [NSString stringWithFormat:@"[[NSDictionary alloc] init]"];
        default:
            return @"NULL";
    }
    return @"NULL";
}

+ (OC_Define_Code *)random_oc_var_define {
    
    mix_ns_type random_type = [CodeConfuseRandomCode rand_oc_ns_type:ns_NSObject];
    OC_Define_Code *oc_code = [self generate_oc_var_by_type:random_type];
    return oc_code;
}

+ (Cpp_Define_Code *)random_cpp_var_define {
    
    mix_ns_type random_type = [CodeConfuseRandomCode rand_cpp_ns_type:ns_int];
    Cpp_Define_Code *cpp_code = [self generate_cpp_var_by_type:random_type];
    return cpp_code;
}

+ (OC_Define_Code *)generate_oc_var_by_type:(mix_ns_type)generate_type {
    
    NSString * oc_var = @"";
    OC_Define_Code *oc_code = [[OC_Define_Code alloc] init];
    oc_code.code_type = generate_type;
    oc_code.callStringArray = [[NSArray alloc] init];
    switch (generate_type) {
        case ns_NSObject:
        {
            oc_var = [CodeConfuseRandomCode rand_identifierWithPrefix:@"obj"];
            NSString *defineString = [NSString stringWithFormat:@"NSObject *%@ = [[NSObject alloc] init];", oc_var];
            oc_code.varString = [NSString stringWithFormat:@"%@", oc_var];
            oc_code.defineString = defineString;
        }
            break;
        case ns_NSString:
        {
            oc_var = [CodeConfuseRandomCode rand_identifierWithPrefix:@"str"];
            NSString *defineString = [NSString stringWithFormat:@"NSString *%@ = [[NSString alloc] init];", oc_var];
            oc_code.varString = [NSString stringWithFormat:@"%@", oc_var];
            oc_code.defineString = defineString;
        }
            break;
        case ns_NSSet:
        {
            oc_var = [CodeConfuseRandomCode rand_identifierWithPrefix:@"set"];
            NSString *defineString = [NSString stringWithFormat:@"NSSet *%@ = [[NSSet alloc] init];", oc_var];
            oc_code.varString = [NSString stringWithFormat:@"%@", oc_var];
            oc_code.defineString = defineString;
        }
            break;
        case ns_NSArray:
        {
            oc_var = [CodeConfuseRandomCode rand_identifierWithPrefix:@"arr"];
            NSString *defineString = [NSString stringWithFormat:@"NSArray *%@ = [[NSArray alloc] init];", oc_var];
            oc_code.varString = [NSString stringWithFormat:@"%@", oc_var];
            oc_code.defineString = defineString;
        }
            break;
        case ns_NSDictionary:
        {
            oc_var = [CodeConfuseRandomCode rand_identifierWithPrefix:@"dict"];
            NSString *defineString = [NSString stringWithFormat:@"NSDictionary *%@ = [[NSDictionary alloc] init];", oc_var];
            oc_code.varString = [NSString stringWithFormat:@"%@", oc_var];
            oc_code.defineString = defineString;
        }
            break;
        case ns_UIColor:
        {
            oc_var = [CodeConfuseRandomCode rand_identifierWithPrefix:@"color"];
            NSString *defineString = [NSString stringWithFormat:@"UIColor *%@ = %@;", oc_var, [self random_color_string]];
            oc_code.varString = [NSString stringWithFormat:@"%@", oc_var];
            oc_code.defineString = defineString;
            
            NSString *callString = [NSString stringWithFormat:@""];
            
            oc_code.callStringArray = @[callString];
        }
            break;
        case ns_UIWindow:
        {
            oc_var = [CodeConfuseRandomCode rand_identifierWithPrefix:@"win"];
            NSString *defineString = [NSString stringWithFormat:@"UIWindow *%@ = [[UIWindow alloc] init];", oc_var];
            oc_code.varString = [NSString stringWithFormat:@"%@", oc_var];
            oc_code.defineString = defineString;
        }
            break;
        case ns_UISlider:
        {
            oc_var = [CodeConfuseRandomCode rand_identifierWithPrefix:@"slider"];
            NSString *defineString = [NSString stringWithFormat:@"UISlider *%@ = [[UISlider alloc] init];", oc_var];
            oc_code.varString = [NSString stringWithFormat:@"%@", oc_var];
            oc_code.defineString = defineString;
            
            
            NSArray *callStringArray = @[];
            oc_code.callStringArray = callStringArray;
        }
            break;
        case ns_UITabBar:
        {
            oc_var = [CodeConfuseRandomCode rand_identifierWithPrefix:@"tab"];
            NSString *defineString = [NSString stringWithFormat:@"UITabBar *%@ = [[UITabBar alloc] init];", oc_var];
            oc_code.varString = [NSString stringWithFormat:@"%@", oc_var];
            oc_code.defineString = defineString;
            
            NSArray *callStringArray = @[];
            oc_code.callStringArray = callStringArray;
        }
            break;
        case ns_UISwitch:
        {
            oc_var = [CodeConfuseRandomCode rand_identifierWithPrefix:@"swtch"];
            NSString *defineString = [NSString stringWithFormat:@"UISwitch *%@ = [[UISwitch alloc] init];", oc_var];
            oc_code.varString = [NSString stringWithFormat:@"%@", oc_var];
            oc_code.defineString = defineString;
            
            
            NSArray *callStringArray = @[];
            oc_code.callStringArray = callStringArray;
        }
            break;
        case ns_UIStepper:
        {
            oc_var = [CodeConfuseRandomCode rand_identifierWithPrefix:@"step"];
            oc_code.varString = [NSString stringWithFormat:@"%@", oc_var];
            
            NSString *defineString = [NSString stringWithFormat:@"UIStepper *%@ = [[UIStepper alloc] initWithFrame:CGRectMake(%d, %d, %d, %d)];", oc_var, [CodeConfuseRandomCode rand_num:10 max:25], [CodeConfuseRandomCode rand_num:20 max:45], [CodeConfuseRandomCode rand_num:88 max:210], [CodeConfuseRandomCode rand_num:43 max:287]];
            oc_code.defineString = defineString;
            
            
            NSArray *callStringArray = @[];
            oc_code.callStringArray = callStringArray;
        }
            break;
        case ns_UITableView:
        {
            oc_var = [CodeConfuseRandomCode rand_identifierWithPrefix:@"tableView"];
            oc_code.varString = [NSString stringWithFormat:@"%@", oc_var];
            
            NSString *defineString = [NSString stringWithFormat:@"UITableView *%@ = [[UITableView alloc] init];", oc_var];
            oc_code.defineString = defineString;
            
            
            
            NSArray *callStringArray = @[];
            oc_code.callStringArray = callStringArray;
            
        }
            break;
            
        case ns_UICollectionView:        {
            oc_var = [CodeConfuseRandomCode rand_identifierWithPrefix:@"collectionView"];
            oc_code.varString = [NSString stringWithFormat:@"%@", oc_var];
            
            NSString *defineString = [NSString stringWithFormat:@"UICollectionView *%@ = [[UICollectionView alloc] initWithFrame:CGRectMake(%d, %d, %d, %d)];", oc_var, [CodeConfuseRandomCode rand_num:20 max:100], [CodeConfuseRandomCode rand_num:20 max:80], [CodeConfuseRandomCode rand_num:50 max:200], [CodeConfuseRandomCode rand_num:60 max:300]];
            oc_code.defineString = defineString;
            
            
            NSArray *callStringArray = @[];
            oc_code.callStringArray = callStringArray;
            
        }
            break;
        case ns_UIImage:
        {
            oc_var = [CodeConfuseRandomCode rand_identifierWithPrefix:@"img"];
            oc_code.varString = [NSString stringWithFormat:@"%@", oc_var];
            
            NSString *dataVar = [CodeConfuseRandomCode rand_identifierWithPrefix:@"data"];
            NSString *resultImgVar = [CodeConfuseRandomCode rand_identifierWithPrefix:@"resultImg"];

            NSString *defineString = [NSString stringWithFormat:@"UIImage *%@ = nil;\n\
\tNSData *%@ = UIImageJPEGRepresentation(%@, %.2lf);\n\
\tUIImage *%@ = [UIImage imageWithData:%@];\n", oc_var, dataVar, oc_var, [CodeConfuseRandomCode random_float:0.0 max:1.0], resultImgVar, dataVar];
            oc_code.defineString = defineString;
            
            NSString *start = [NSString stringWithFormat:@"%@", [CodeConfuseRandomCode rand_bool]?@"if":@"while"];
            oc_code.blockBegin = [NSString stringWithFormat:@"%@ (%@.length > %@.size.height) {", start, dataVar, resultImgVar];
            
            
            
            oc_code.blockEnd = [NSString stringWithFormat:@"}"];
            
            NSArray *callStringArray = @[];
            oc_code.callStringArray = callStringArray;
        }
            break;
        case ns_UIAlertView:
        {
            oc_var = [CodeConfuseRandomCode rand_identifierWithPrefix:@"alert"];
            oc_code.varString = [NSString stringWithFormat:@"%@", oc_var];
            
            NSString *cancelTitle = [CodeConfuseRandomCode rand_string:3 max:8];
            NSString *otherTitle = [CodeConfuseRandomCode rand_string:5 max:10];
            
            NSString *defineString = [NSString stringWithFormat:@"UIAlertView *%@ = [[UIAlertView alloc] initWithTitle:nil message:@\"%@\" delegate:nil cancelButtonTitle:@\"%@\" otherButtonTitles:@\"%@\", nil];", oc_var, [CodeConfuseRandomCode rand_identifier], cancelTitle, otherTitle];
            oc_code.defineString = defineString;
            
            
            NSString *callString = [NSString stringWithFormat:@"\n\t[%@ show];", oc_var];
            
            oc_code.callStringArray = @[callString];
        }
            break;
        default:
        {
            oc_var = [CodeConfuseRandomCode rand_identifierWithPrefix:@"url"];
            oc_code.varString = [NSString stringWithFormat:@"%@", oc_var];

            
            oc_code.defineString = [NSString stringWithFormat:@""];
            
            NSString *callString = [NSString stringWithFormat:@""];
            oc_code.callStringArray = @[callString];
        }
            break;
    }
    
    return oc_code;
}

+ (Cpp_Define_Code *)generate_cpp_var_by_type:(mix_ns_type)generate_type
{
    NSString *cpp_var = @"";
    Cpp_Define_Code *cpp_code = [[Cpp_Define_Code alloc] init];
    cpp_code.code_type = generate_type;
    cpp_code.callStringArray = [[NSArray alloc] init];
    switch (generate_type)
    {
        case ns_int:
        {
            NSString *randSizeVarA = [CodeConfuseRandomCode rand_identifierWithPrefix:@"iSize"];
            NSString *randMatrixVarA = [CodeConfuseRandomCode rand_identifierWithPrefix:@"matrixI"];
            NSString *randMatrixVarR = [CodeConfuseRandomCode rand_identifierWithPrefix:@"matrixJ"];
            NSString *randMatrixVarR1 = [CodeConfuseRandomCode rand_identifierWithPrefix:@"matrixK"];
            cpp_var = [CodeConfuseRandomCode rand_bool] ? randMatrixVarA: ([CodeConfuseRandomCode rand_bool] ? randMatrixVarR: randMatrixVarR1 );
            
            NSString *randDeltaVarR = [CodeConfuseRandomCode rand_identifierWithPrefix:@"del"];
            NSString *randPerVarR = [CodeConfuseRandomCode rand_identifierWithPrefix:@"pe"];
            NSString *randQuiVarR = [CodeConfuseRandomCode rand_identifierWithPrefix:@"qu"];
            NSString *randMaxVarR = [CodeConfuseRandomCode rand_identifierWithPrefix:@"ma"];
            
            NSString *randErrVarR = [CodeConfuseRandomCode rand_identifierWithPrefix:@"errno"];
            
            NSString *randSinVarR = [CodeConfuseRandomCode rand_identifierWithPrefix:@"single"];
            NSString *randTanVarR = [CodeConfuseRandomCode rand_identifierWithPrefix:@"tangle"];
            NSString *randCosVarR = [CodeConfuseRandomCode rand_identifierWithPrefix:@"cosle"];
            
            NSString *defineString = [NSString stringWithFormat:@"\tconst int %@ = %d;\n\
\tint %@ = 10;\n\
\tint %@[%@][%@];\n\
\tint %@[%@][%@] = {0};\n\
\tint %@[%@][%@] = {0};\n\
\tint %@ = 0;\n\
\tint %@ = 0;\n\
\tint %@ = 0;\n\
\tint %@ = 0;\n\
\tint %@ = 0;\n\
\tint %@ = 0;\n\
\tint %@ = 0;\n", randSizeVarA, [CodeConfuseRandomCode rand_num:15 max:500], randErrVarR, randMatrixVarA, randSizeVarA, randSizeVarA, randMatrixVarR, randSizeVarA, randSizeVarA, randMatrixVarR1, randSizeVarA, randSizeVarA, randMaxVarR, randPerVarR, randQuiVarR, randDeltaVarR, randTanVarR, randSinVarR, randCosVarR];
            
            cpp_code.blockBegin = [NSString stringWithFormat:@"\twhile(%@ > %lf) {", randErrVarR, [CodeConfuseRandomCode random_float:1.12 max:35.68]];
            
            NSString *callString1 = [NSString stringWithFormat:@"\n\
\tfor(int i=0;i<%@;i++)\n\
\t{\n\
\t\tfor(int j=0;j<%@;j++)\n\
\t\t{\n\
\t\t\tif(i == j)\n\
\t\t\t{\n\
\t\t\t\t%@[i][j]=1;\n\
\t\t\t\t%@[i][j]=1;\n\
\t\t\t}\n\
\t\t\telse\n\
\t\t\t{\n\
\t\t\t\t%@[i][j]=0;\n\
\t\t\t\t%@[i][j]=0;\n\
\t\t\t}\n\
\t\t}\n\
\t}\n", randSizeVarA, randSizeVarA, randMatrixVarR, randMatrixVarR1, randMatrixVarR, randMatrixVarR1];
            
            NSString *callString2 = [NSString stringWithFormat:@"%@=0;", randMaxVarR];
            
            NSString *callString3 = [NSString stringWithFormat:@"\n\
\tfor(int i=0;i<%@;i++)\n\
\t{\n\
\t\tfor(int j=i+1;j<%@;j++)\n\
\t\t{\n\
\t\t\tif(%@<::abs(%@[i][j]))\n\
\t\t\t{\n\
\t\t\t\t%@=::abs(%@[i][j]);\n\
\t\t\t\t%@=i;\n\
\t\t\t\t%@=j;\n\
\t\t\t}\n\
\t\t\t%@ += %@;\n\
\t\t}\n\
\t}\n", randSizeVarA, randSizeVarA, randMaxVarR, randMatrixVarA, randMaxVarR, randMatrixVarA, randPerVarR, randQuiVarR, randErrVarR, randMaxVarR];
            
            NSString *callString4 = [NSString stringWithFormat:@"\n\
\tif(::abs(%@[%@][%@]-%@[%@][%@])>0.001)\n\
\t{\n\
\t\t%@=(2*%@[%@][%@])/(%@[%@][%@]-%@[%@][%@]);\n\
\t\t%@=%@/(1+::sqrt(1+%@*%@));\n\
\t\t%@=1/::sqrt(1+%@*%@);\n\
\t\t%@=%@*%@;\n\
\t\t%@ -= %@;\n\
\t}\n\
\telse\n\
\t{\n\
\t\tif(%@[%@][%@]>0)\n\
\t\t{\n\
\t\t\t%@=::sqrt(%.2lf)/%d;\n\
\t\t\t%@=::sqrt(%.2lf)/%d;\n\
\t\t\t%@ -= %@;\n\
\t\t}\n\
\t\telse\n\
\t\t{\n\
\t\t\t%@=::sqrt(%.2lf)/%d;\n\
\t\t\t%@=-::sqrt(%.2lf)/%d;\n\
\t\t\t%@ += %@;\n\
\t\t}\n\
\t}\n", randMatrixVarA, randPerVarR, randPerVarR, randMatrixVarA, randQuiVarR, randQuiVarR, randDeltaVarR, randMatrixVarA, randPerVarR, randQuiVarR, randMatrixVarA, randPerVarR, randPerVarR, randMatrixVarA, randQuiVarR, randQuiVarR, randSinVarR, randDeltaVarR, randDeltaVarR, randDeltaVarR, randTanVarR, randCosVarR, randCosVarR, randTanVarR, randSinVarR, randCosVarR, randErrVarR, randTanVarR, randMatrixVarA, randPerVarR, randQuiVarR, randSinVarR, [CodeConfuseRandomCode random_float:2.0 max:36.0], [CodeConfuseRandomCode rand_num:5 max:200], randSinVarR, [CodeConfuseRandomCode random_float:7.0 max:48.0], [CodeConfuseRandomCode rand_num:10 max:300], randErrVarR, randTanVarR, randCosVarR, [CodeConfuseRandomCode random_float:15.2 max:600.0],  [CodeConfuseRandomCode rand_num:20 max:170], randSinVarR, [CodeConfuseRandomCode random_float:19.0 max:1223.0], [CodeConfuseRandomCode rand_num:15 max:400], randErrVarR, randCosVarR];
            
            NSString *callString5 = [NSString stringWithFormat:@"\n\
\tfor(int i=0;i<%@;i++)\n\
\t{\n\
\t\tfor(int j=0;j<%@;j++)\n\
\t\t{\n\
\t\t\tif(i==j)\n\
\t\t\t{\n\
\t\t\t\t%@[i][j]=1;\n\
\t\t\t}\n\
\t\t\telse\n\
\t\t\t{\n\
\t\t\t\t%@[i][j]=0;\n\
\t\t\t}\n\
\t\t}\n\
\t}\n", randSizeVarA, randSizeVarA, randMatrixVarR1, randMatrixVarR1];
            
            NSString *callString6 = [NSString stringWithFormat:@"%@[%@][%@]=%@;", randMatrixVarR, randPerVarR, randPerVarR, randCosVarR];
            NSString *callString7 = [NSString stringWithFormat:@"%@[%@][%@]=%@;", randMatrixVarR1, randQuiVarR, randQuiVarR, randCosVarR];
            NSString *callString8 = [NSString stringWithFormat:@"%@[%@][%@]=%@;", randMatrixVarR, randPerVarR, randQuiVarR, randSinVarR];
            NSString *callString9 = [NSString stringWithFormat:@"%@[%@][%@]=-%@;", randMatrixVarR1, randQuiVarR, randPerVarR, randSinVarR];
            
            cpp_code.blockEnd = [NSString stringWithFormat:@"}"];
            
            NSArray *callStringArray = @[callString1,callString2,callString3,callString4,callString5,callString6,callString7,callString8,callString9];
            
            cpp_code.varString = [NSString stringWithFormat:@"%@", cpp_var];
            cpp_code.returnVarString = [NSString stringWithFormat:@"%@[0][0]", cpp_var];
            cpp_code.defineString = defineString;
            cpp_code.callStringArray = callStringArray;
        }
            break;
        case ns_float:
        {
            cpp_var = [CodeConfuseRandomCode rand_identifierWithPrefix:@"vecFloat"];
            NSString *randVecVarA = [CodeConfuseRandomCode rand_identifierWithPrefix:@"vecFloat"];
            NSString *randVecVarZ = [CodeConfuseRandomCode rand_identifierWithPrefix:@"vecFloatP"];
            NSString *randNormVar = [CodeConfuseRandomCode rand_identifierWithPrefix:@"normal"];
            NSString *randErrVar = [CodeConfuseRandomCode rand_identifierWithPrefix:@"err"];
            NSString *randSumVar = [CodeConfuseRandomCode rand_identifierWithPrefix:@"summary"];
            NSString *randCalSizeVar = [CodeConfuseRandomCode rand_identifierWithPrefix:@"sizeFloat"];
            
            NSString *defineString = [NSString stringWithFormat:@"float %@ = 6;\n\
\tvector<float> %@;\n\
\tvector<vector<float>> %@;\n\
\tfloat %s = 0;\n\
\tfloat %s = 0;\n\
\tvector<float> %@(%@);\n\
\tfloat %s = 0;", randCalSizeVar, cpp_var, randVecVarA, randNormVar.UTF8String, randErrVar.UTF8String, randVecVarZ, randCalSizeVar, randSumVar.UTF8String];
            
            cpp_code.blockBegin = [NSString stringWithFormat:@"\tfor (float i = 0; i < %d; ++i) {", [CodeConfuseRandomCode rand_num:15 max:200]];
            
            NSString *callString1 = [NSString stringWithFormat:@"\tfor (float j = 0; j < %@; ++j) {\n\
\t\t%@.assign(%@, vector<float>(%@, 1));\n\
\t\tfor (float j = 0; j < %@; ++j) {\n\
\t\t\t%@[j][j] = %@-1;\n\
\t\t}\n\
\t}\n", randCalSizeVar, randVecVarA, randCalSizeVar, randCalSizeVar, randCalSizeVar, randVecVarA, randCalSizeVar];
            
            NSString *callString2 = [NSString stringWithFormat:@"\t%s = 0;\n\
\tfor (float j = 0; j < %@; ++j) {\n\
\t\tif (i != j) {\n\
\t\t\t%s += (%@[i][j] + %@[j][i]) / (%@[i] + %@[j]);\n\
\t\t}\n\
\t\t%@[i] = %@[i][i] / %s;\n\
\t\t%s += %@[i];\n\
\t}\n", randSumVar.UTF8String, randCalSizeVar, randSumVar.UTF8String, randVecVarA, randVecVarA, cpp_var, cpp_var, cpp_var, randVecVarA, randSumVar.UTF8String, randNormVar.UTF8String, randVecVarZ];
            
            NSString *callString3 = [NSString stringWithFormat:@"\n\
\tfor (float i = 0; i < %@; ++i)  {\n\
\t\t%s += ::fabs(%@[i] - %@[i] / %s);\n\
\t\t%@[i] = %@[i] / %s;\n\
\t}\n\
\tif (%s < %.2lfe-%d) {\n\
\t\t%@;\n\
\t}\n", randCalSizeVar, randErrVar.UTF8String, randVecVarZ, randVecVarZ, randNormVar.UTF8String, cpp_var, cpp_var, randNormVar.UTF8String,  randErrVar.UTF8String, [CodeConfuseRandomCode random_float:1.15 max:15.56], [CodeConfuseRandomCode rand_num:1 max:10], [CodeConfuseRandomCode rand_bool] ? @"break":@"continue"];
            
            cpp_code.blockEnd = [NSString stringWithFormat:@"}"];
            
            NSArray *callStringArray = @[callString1,callString2,callString3];
            
            cpp_code.varString = [NSString stringWithFormat:@"%@", cpp_var];
            cpp_code.returnVarString = [NSString stringWithFormat:@"%@[0]", cpp_var];
            cpp_code.defineString = defineString;
            cpp_code.callStringArray = callStringArray;
        }
            break;
        case ns_double:
        {
            
            NSString *randSizeVarA = [CodeConfuseRandomCode rand_identifierWithPrefix:@"iSize"];
            NSString *randMatrixVarA = [CodeConfuseRandomCode rand_identifierWithPrefix:@"arrA"];
            NSString *randMatrixVarR = [CodeConfuseRandomCode rand_identifierWithPrefix:@"arrR"];
            NSString *randMatrixVarR1 = [CodeConfuseRandomCode rand_identifierWithPrefix:@"arrR1"];
            cpp_var = [CodeConfuseRandomCode rand_bool] ? randMatrixVarA: ([CodeConfuseRandomCode rand_bool] ? randMatrixVarR: randMatrixVarR1 );
            
            NSString *randDeltaVarR = [CodeConfuseRandomCode rand_identifierWithPrefix:@"delta"];
            NSString *randPerVarR = [CodeConfuseRandomCode rand_identifierWithPrefix:@"per"];
            NSString *randQuiVarR = [CodeConfuseRandomCode rand_identifierWithPrefix:@"qui"];
            NSString *randMaxVarR = [CodeConfuseRandomCode rand_identifierWithPrefix:@"max"];
            
            NSString *randErrVarR = [CodeConfuseRandomCode rand_identifierWithPrefix:@"err"];
            
            NSString *randSinVarR = [CodeConfuseRandomCode rand_identifierWithPrefix:@"sin"];
            NSString *randTanVarR = [CodeConfuseRandomCode rand_identifierWithPrefix:@"tan"];
            NSString *randCosVarR = [CodeConfuseRandomCode rand_identifierWithPrefix:@"cos"];
            
            NSString *defineString = [NSString stringWithFormat:@"\tconst int %@ = %d;\n\
\tdouble %@ = 10;\n\
\tdouble %@[%@][%@];\n\
\tdouble %@[%@][%@] = {0};\n\
\tdouble %@[%@][%@] = {0};\n\
\tdouble %@ = 0;\n\
\tint %@ = 0;\n\
\tint %@ = 0;\n\
\tdouble %@ = 0;\n\
\tdouble %@ = 0;\n\
\tdouble %@ = 0;\n\
\tdouble %@ = 0;\n", randSizeVarA, [CodeConfuseRandomCode rand_num:50 max:300], randErrVarR, randMatrixVarA, randSizeVarA, randSizeVarA, randMatrixVarR, randSizeVarA, randSizeVarA, randMatrixVarR1, randSizeVarA, randSizeVarA, randMaxVarR, randPerVarR, randQuiVarR, randDeltaVarR, randTanVarR, randSinVarR, randCosVarR];
            
            cpp_code.blockBegin = [NSString stringWithFormat:@"\twhile(%@ > %lf) {", randErrVarR, [CodeConfuseRandomCode random_float:1.12 max:35.68]];
            
            NSString *callString1 = [NSString stringWithFormat:@"\n\
\tfor(int i=0;i<%@;i++)\n\
\t{\n\
\t\tfor(int j=0;j<%@;j++)\n\
\t\t{\n\
\t\t\tif(i == j)\n\
\t\t\t{\n\
\t\t\t\t%@[i][j]=1;\n\
\t\t\t\t%@[i][j]=1;\n\
\t\t\t}\n\
\t\t\telse\n\
\t\t\t{\n\
\t\t\t\t%@[i][j]=0;\n\
\t\t\t\t%@[i][j]=0;\n\
\t\t\t}\n\
\t\t}\n\
\t}\n", randSizeVarA, randSizeVarA, randMatrixVarR, randMatrixVarR1, randMatrixVarR, randMatrixVarR1];
            
            NSString *callString2 = [NSString stringWithFormat:@"%@=0;", randMaxVarR];
            
            NSString *callString3 = [NSString stringWithFormat:@"\n\
\tfor(int i=0;i<%@;i++)\n\
\t{\n\
\t\tfor(int j=i+1;j<%@;j++)\n\
\t\t{\n\
\t\t\tif(%@<::abs(%@[i][j]))\n\
\t\t\t{\n\
\t\t\t\t%@=::abs(%@[i][j]);\n\
\t\t\t\t%@=i;\n\
\t\t\t\t%@=j;\n\
\t\t\t}\n\
\t\t\t%@ += %@;\n\
\t\t}\n\
\t}\n", randSizeVarA, randSizeVarA, randMaxVarR, randMatrixVarA, randMaxVarR, randMatrixVarA, randPerVarR, randQuiVarR, randErrVarR, randMaxVarR];
            
            NSString *callString4 = [NSString stringWithFormat:@"\n\
\tif(::abs(%@[%@][%@]-%@[%@][%@])>0.001)\n\
\t{\n\
\t\t%@=(2*%@[%@][%@])/(%@[%@][%@]-%@[%@][%@]);\n\
\t\t%@=%@/(1+::sqrt(1+%@*%@));\n\
\t\t%@=1/::sqrt(1+%@*%@);\n\
\t\t%@=%@*%@;\n\
\t\t%@ -= %@;\n\
\t}\n\
\telse\n\
\t{\n\
\t\tif(%@[%@][%@]>0)\n\
\t\t{\n\
\t\t\t%@=::sqrt(%.2lf)/%.3lf;\n\
\t\t\t%@=::sqrt(%.2lf)/%.5lf;\n\
\t\t\t%@ -= %@;\n\
\t\t}\n\
\t\telse\n\
\t\t{\n\
\t\t\t%@=::sqrt(%.2lf)/%.2lf;\n\
\t\t\t%@=-::sqrt(%.2lf)/%.4lf;\n\
\t\t\t%@ += %@;\n\
\t\t}\n\
\t}\n", randMatrixVarA, randPerVarR, randPerVarR, randMatrixVarA, randQuiVarR, randQuiVarR, randDeltaVarR, randMatrixVarA, randPerVarR, randQuiVarR, randMatrixVarA, randPerVarR, randPerVarR, randMatrixVarA, randQuiVarR, randQuiVarR, randSinVarR, randDeltaVarR, randDeltaVarR, randDeltaVarR, randTanVarR, randCosVarR, randCosVarR, randTanVarR, randSinVarR, randCosVarR, randErrVarR, randTanVarR, randMatrixVarA, randPerVarR, randQuiVarR, randSinVarR, [CodeConfuseRandomCode random_float:2.0 max:36.0], [CodeConfuseRandomCode random_double:5.0 max:200.0], randSinVarR, [CodeConfuseRandomCode random_float:7.0 max:48.0], [CodeConfuseRandomCode random_double:10 max:300], randErrVarR, randTanVarR, randCosVarR, [CodeConfuseRandomCode random_float:15.2 max:600.0],  [CodeConfuseRandomCode random_double:20 max:170], randSinVarR, [CodeConfuseRandomCode random_float:19.0 max:1223.0], [CodeConfuseRandomCode random_double:15 max:400], randErrVarR, randCosVarR];
            
            NSString *callString5 = [NSString stringWithFormat:@"\n\
\tfor(int i=0;i<%@;i++)\n\
\t{\n\
\t\tfor(int j=0;j<%@;j++)\n\
\t\t{\n\
\t\t\tif(i==j)\n\
\t\t\t{\n\
\t\t\t\t%@[i][j]=1;\n\
\t\t\t}\n\
\t\t\telse\n\
\t\t\t{\n\
\t\t\t\t%@[i][j]=0;\n\
\t\t\t}\n\
\t\t}\n\
\t}\n", randSizeVarA, randSizeVarA, randMatrixVarR1, randMatrixVarR1];
            
            NSString *callString6 = [NSString stringWithFormat:@"%@[%@][%@]=%@;", randMatrixVarR, randPerVarR, randPerVarR, randCosVarR];
            NSString *callString7 = [NSString stringWithFormat:@"%@[%@][%@]=%@;", randMatrixVarR1, randQuiVarR, randQuiVarR, randCosVarR];
            NSString *callString8 = [NSString stringWithFormat:@"%@[%@][%@]=%@;", randMatrixVarR, randPerVarR, randQuiVarR, randSinVarR];
            NSString *callString9 = [NSString stringWithFormat:@"%@[%@][%@]=-%@;", randMatrixVarR1, randQuiVarR, randPerVarR, randSinVarR];
            
            cpp_code.blockEnd = [NSString stringWithFormat:@"}"];
            
            NSArray *callStringArray = @[callString1,callString2,callString3,callString4,callString5,callString6,callString7,callString8,callString9];
            
            cpp_code.varString = [NSString stringWithFormat:@"%@", cpp_var];
            cpp_code.returnVarString = [NSString stringWithFormat:@"%@[0][0]", cpp_var];
            cpp_code.defineString = defineString;
            cpp_code.callStringArray = callStringArray;
        }
            break;
        case ns_char:
        {
            cpp_var = [CodeConfuseRandomCode rand_identifierWithPrefix:@"vecChar"];
            NSString *randVecVarA = [CodeConfuseRandomCode rand_identifierWithPrefix:@"vecChar"];
            NSString *randVecVarZ = [CodeConfuseRandomCode rand_identifierWithPrefix:@"vecCharS"];
            NSString *randNormVar = [CodeConfuseRandomCode rand_identifierWithPrefix:@"normc"];
            NSString *randErrVar = [CodeConfuseRandomCode rand_identifierWithPrefix:@"errc"];
            NSString *randSumVar = [CodeConfuseRandomCode rand_identifierWithPrefix:@"sumc"];
            NSString *randCalSizeVar = [CodeConfuseRandomCode rand_identifierWithPrefix:@"sizeCh"];
            
            NSString *defineString = [NSString stringWithFormat:@"char %@ = 6;\n\
\tvector<char> %@;\n\
\tvector<vector<char>> %@;\n\
\tchar %s = 0;\n\
\tchar %s = 0;\n\
\tvector<char> %@(%@);\n\
\tchar %s = 0;", randCalSizeVar, cpp_var, randVecVarA, randNormVar.UTF8String, randErrVar.UTF8String, randVecVarZ, randCalSizeVar, randSumVar.UTF8String];
            
            cpp_code.blockBegin = [NSString stringWithFormat:@"\tfor (char i = 0; i < %d; ++i) {", [CodeConfuseRandomCode rand_num:15 max:200]];
            
            NSString *callString1 = [NSString stringWithFormat:@"\tfor (char j = 0; j < %@; ++j) {\n\
\t\t%@.assign(%@, vector<char>(%@, 1));\n\
\t\tfor (char j = 0; j < %@; ++j) {\n\
\t\t\t%@[j][j] = %@-1;\n\
\t\t}\n\
\t}\n", randCalSizeVar, randVecVarA, randCalSizeVar, randCalSizeVar, randCalSizeVar, randVecVarA, randCalSizeVar];
            
            NSString *callString2 = [NSString stringWithFormat:@"\t%s = 0;\n\
\tfor (char j = 0; j < %@; ++j) {\n\
\t\tif (i != j) {\n\
\t\t\t%s += (%@[i][j] + %@[j][i]) / (%@[i] + %@[j]);\n\
\t\t}\n\
\t\t%@[i] = %@[i][i] / %s;\n\
\t\t%s += %@[i];\n\
\t}\n", randSumVar.UTF8String, randCalSizeVar, randSumVar.UTF8String, randVecVarA, randVecVarA, cpp_var, cpp_var, cpp_var, randVecVarA, randSumVar.UTF8String, randNormVar.UTF8String, randVecVarZ];
            
            NSString *callString3 = [NSString stringWithFormat:@"\n\
\tfor (char i = 0; i < %@; ++i)  {\n\
\t\t%s += ::abs(%@[i] - %@[i] / %s);\n\
\t\t%@[i] = %@[i] / %s;\n\
\t}\n\
\tif (%s < %d) {\n\
\t\t%@;\n\
\t}\n", randCalSizeVar, randErrVar.UTF8String, randVecVarZ, randVecVarZ, randNormVar.UTF8String, cpp_var, cpp_var, randNormVar.UTF8String,  randErrVar.UTF8String, [CodeConfuseRandomCode rand_num:1 max:10], [CodeConfuseRandomCode rand_bool] ? @"break":@"continue"];
            
            cpp_code.blockEnd = [NSString stringWithFormat:@"}"];
            
            NSArray *callStringArray = @[callString1,callString2,callString3];
            
            cpp_code.varString = [NSString stringWithFormat:@"%@", cpp_var];
            cpp_code.returnVarString = [NSString stringWithFormat:@"%@[0]", cpp_var];
            cpp_code.defineString = defineString;
            cpp_code.callStringArray = callStringArray;
        }
            break;
        default:
        {
            break;
        }
    }
    
    return cpp_code;
}

+ (NSString *)random_yes_no
{
    return (arc4random()%2==0)?@"YES":@"NO";
}

+ (NSString *)random_textalignment_string
{
    NSArray *textAlignments = @[@"NSTextAlignmentLeft",
                               @"NSTextAlignmentCenter",
                               @"NSTextAlignmentRight",
                               @"NSTextAlignmentJustified",
                               @"NSTextAlignmentNatural"];
    int rand_index = arc4random() % textAlignments.count;
    if (rand_index < textAlignments.count) {
        return textAlignments[rand_index];
    }
    else {
        return @"NSTextAlignmentLeft";
    }
}

+ (NSString *)rand_for_key:(NSUInteger)seed
{
    
    NSArray *forKeyArr = @[@"forKey",
                           @"forUndefinedKey",
                           @"forKeyPath"];
    
    int rand_index = arc4random() % forKeyArr.count;
    if (rand_index < forKeyArr.count) {
        return forKeyArr[rand_index];
    }
    else {
        if (seed % 2 == 0)
        {
            return @"forKey";
        }
        else
        {
            return @"forUndefinedKey";
        }
    }
}

+ (NSString *)random_alertview_style
{
    NSArray *alertViewStyles = @[@"UIAlertViewStyleDefault",
                                  @"UIAlertViewStyleSecureTextInput",
                                  @"UIAlertViewStylePlainTextInput",
                                  @"UIAlertViewStyleLoginAndPasswordInput"];
    
    int rand_index = arc4random() % alertViewStyles.count;
    if (rand_index < alertViewStyles.count) {
        return alertViewStyles[rand_index];
    }
    else {
        return @"UIAlertViewStyleDefault";
    }
    
}

+ (NSString *)random_view_contentmode_string
{
    NSArray *viewContentModes = @[@"UIViewContentModeScaleToFill",
                                  @"UIViewContentModeScaleAspectFit",
                                  @"UIViewContentModeScaleAspectFill",
                                  @"UIViewContentModeRedraw",
                                  @"UIViewContentModeCenter",
                                  @"UIViewContentModeTop",
                                  @"UIViewContentModeBottom",
                                  @"UIViewContentModeLeft",
                                  @"UIViewContentModeRight",
                                  @"UIViewContentModeTopLeft",
                                  @"UIViewContentModeTopRight",
                                  @"UIViewContentModeBottomLeft",
                                  @"UIViewContentModeBottomRight"];
    int rand_index = arc4random() % viewContentModes.count;
    if (rand_index < viewContentModes.count) {
        return viewContentModes[rand_index];
    }
    else {
        return @"UIViewContentModeCenter";
    }
}

+ (NSString *)random_color_string
{
    NSArray *colorCollection = @[@"[UIColor clearColor]",
                                 @"[UIColor blackColor]",
                                 @"[UIColor blueColor]",
                                 @"[UIColor brownColor]",
                                 @"[UIColor clearColor]",
                                 @"[UIColor cyanColor]",
                                 @"[UIColor darkGrayColor]",
                                 @"[UIColor grayColor]",
                                 @"[UIColor greenColor]",
                                 @"[UIColor lightGrayColor]",
                                 @"[UIColor magentaColor]",
                                 @"[UIColor orangeColor]",
                                 @"[UIColor purpleColor]",
                                 @"[UIColor redColor]",
                                 @"[UIColor whiteColor]",
                                 @"[UIColor yellowColor]"];
    
    int rand_index = arc4random() % colorCollection.count;
    
    if (rand_index < colorCollection.count) {
        return colorCollection[rand_index];
    }
    else {
        NSString *colorString = [NSString stringWithFormat:@"[UIColor colorWithRed:%lf/255.0 green:%lf/255.0 blue:%lf/255.0 alpha:1.0];", [CodeConfuseRandomCode random_float:20 max:230], [CodeConfuseRandomCode random_float:30 max:240],[CodeConfuseRandomCode random_float:25 max:235]];
        return colorString;
    }
}

+ (NSString *)random_cpp_value_by_type:(mix_ns_type)nstype
{
    switch (nstype) {
        case ns_void:
            return @"NULL";
        case ns_char:
            return [NSString stringWithFormat:@"'%c'", [CodeConfuseRandomCode rand_num_range:26] + ([CodeConfuseRandomCode rand_bool] ? 64 : 96)];
        case ns_int:
            return [NSString stringWithFormat:@"%d", [CodeConfuseRandomCode rand_num:10 max:65535]];
        case ns_float:
            return [NSString stringWithFormat:@"%f", [CodeConfuseRandomCode random_float:3.0f max:3000.0f]];
        case ns_double:
            return [NSString stringWithFormat:@"%lf", [CodeConfuseRandomCode random_double:20.0 max:5000.0]];
        default:
            return @"NULL";
    }
    return @"NULL";
}

//获取Objective C随机的类型名
+ (mix_ns_type)rand_oc_ns_type:(int)startpos
{
    NSLog(@"ns_oc_type_max: %d", ns_oc_type_max);
    return (mix_ns_type)[self rand_num:startpos max:ns_oc_type_max];
}

//获取C++随机的类型名
+ (mix_ns_type)rand_cpp_ns_type:(int)startpos
{
    NSLog(@"ns_cpp_type_max: %d", ns_cpp_type_max);
    return (mix_ns_type)[self rand_num:startpos max:ns_cpp_type_max];
}

//获取随机标识符
+ (NSString *)rand_identifier
{
    NSString * rand_str = [NSString code_randomStringWithoutDigital];
    return rand_str;
}

//获取随机标识符，添加指定前缀
+ (NSString *)rand_identifierWithPrefix:(NSString *)idPrefix
{
    NSString * rand_str = [NSString code_randomStringWithoutDigital:idPrefix];
    return rand_str;
}

//获取随机标识符 首字母大写
+ (NSString *)rand_identifier_capitalized
{
    NSString * rand_str = [NSString captializedFirstCharOfString:[NSString code_randomStringWithoutDigital]];
    return rand_str;
}

//获取随机字符串
+ (NSString *)rand_string:(int)mix max:(int)max
{
    NSString *rand_str = @"";
    char ch;
    for (int i=0; i<[self rand_num:mix max:max]; i++) {
        ch = [self rand_num_range:26] + ([self rand_bool] ? 64 : 96);
        rand_str = [rand_str stringByAppendingFormat:@"%c", ch];
    }
    return rand_str;
}

+ (char)rand_char
{
    char ch = [self rand_num_range:26] + ([self rand_bool] ? 64 : 96);
    return ch;
}

//随机数字
+ (char)rand_num_range:(int)range
{
    return arc4random()%range+1;
}

+ (int)rand_num:(int)min max:(int)max
{
    return min + arc4random()%(max - min + 1);
}

//随机运算符
+ (NSString *)rand_operator
{
    mix_operator_type op_type = (mix_operator_type)[self rand_num:1 max:4];
    switch (op_type) {
        case op_add:
            return @" + ";
        case op_minus:
            return @" - ";
        case op_multiply:
            return @" * ";
        default:
            return @" - ";
    }
    return @" - ";
}

+ (NSString *)rand_compare_operator
{
    mix_compare_operator_type cpm_op_type = (mix_compare_operator_type)[self rand_num:1 max:6];
    switch (cpm_op_type) {
        case op_equal:
            return @"==";
        case op_greater_than:
            return @">";
        case op_less_than:
            return @"<";
        case op_greater_than_or_equal:
            return @">=";
        case op_less_than_or_equal:
            return @"<=";
        case op_not_equal:
            return @"!=";
        default:
            return @"==";
    }
    return @"==";
}

//随机符合赋值运算符
+ (NSString *)rand_assign_operator
{
    mix_assign_operator_type op_type = (mix_assign_operator_type)[self rand_num:1 max:4];
    switch (op_type) {
        case op_add_assign:
            return @" += ";
        case op_minus_assign:
            return @" -= ";
        case op_multiply_assign:
            return @" *= ";
        default:
            return @" = ";
    }
    return @" = ";
}

+ (bool)rand_bool
{
    return 2 == [self rand_num_range:2];
}

+ (float)random_float:(float)min max:(float)max
{
    float diff = max - min;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + min;
}

+ (double)random_double:(double)min max:(double)max
{
    double diff = max - min;
    return (((double) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + min;
}

@end
