//
//  CodeConfuseMixOCModel.h
//  CodeConfuse
//
//  Created by ConfuseCode on 2018/12/24.
//  Copyright © 2018年 fkd All rights reserved.
//

#ifndef CodeConfuseMixOCModel_h
#define CodeConfuseMixOCModel_h

#include <string> 

using namespace std;

//运算符类型 +,-,*
enum mix_operator_type {
    op_add = 1,             // +
    op_minus = 2,           // -
    op_multiply = 3,        // *
};
typedef mix_operator_type mix_operator_type;

//比较运算符 ==, >, <, >=, <=, !=
enum mix_compare_operator_type {
    op_equal = 1,                       // ==
    op_greater_than = 2,                // >
    op_less_than = 3,                   // <
    op_greater_than_or_equal = 4,       // >=
    op_less_than_or_equal = 5,          // <=
    op_not_equal = 6,                   // !=
};
typedef mix_compare_operator_type mix_compare_operator_type;

//复合赋值运算符类型 +=,-=,*=
enum mix_assign_operator_type {
    op_add_assign = 1,             // +=
    op_minus_assign = 2,           // -=
    op_multiply_assign = 3,        // *=
};
typedef mix_assign_operator_type mix_assign_operator_type;

//C/C++/Objective C类型
enum mix_ns_type {
    ns_void = 1,            //void
    ns_int,                 //int
    ns_float,               //float
    ns_double,              //double
    ns_char,                //char
    ns_NSObject,            //NSObject
    ns_NSString,            //NSString*
    ns_NSSet,               //NSSet
    ns_NSArray,             //NSArray
    ns_NSDictionary,        //NSDictionary
    ns_UIColor,             //UIColor
    ns_UIWindow,            //UIWindow
    ns_UISlider,            //UISlider
    ns_UITabBar,            //UITabBar
    ns_UISwitch,            //UISwitch
    ns_UIStepper,           //UIStepper
    ns_UITableView,         //UITableView
    ns_UICollectionView,    //UICollectionView
    ns_UIAlertView,         //UIAlertView
    ns_UIImage,             //UIImage
    ns_type_max = ns_UIImage,
    ns_oc_type_max = ns_type_max,
    ns_cpp_type_max = ns_char
};
typedef mix_ns_type mix_ns_type;

//Objective C方法参数
struct mix_oc_params
{
    mix_ns_type ret_type;
    std::string arg_name;
    std::string param_name;
};
typedef mix_oc_params mix_oc_params;

//Objective C方法/函数
struct mix_oc_method
{
    bool is_static;
    mix_ns_type ret_type;
    std::string name;
    int param_count;
    mix_oc_params** params;
};
typedef mix_oc_method mix_oc_method;

//Objective C类
struct mix_oc_class
{
    std::string name;
    mix_oc_method** methods;
    int method_count;
};
typedef mix_oc_class mix_oc_class;

@interface OC_Define_Code : NSObject

@property (nonatomic, strong) NSString *varString;
@property (nonatomic, strong) NSString *defineString;
@property (nonatomic, strong) NSArray *callStringArray;

//表示语句块的开始，语句块可以是if 或者 for、while循环 等 {
@property (nonatomic, strong) NSString *blockBegin;
//表示语句块的结束 }
@property (nonatomic, strong) NSString *blockEnd;

@property (nonatomic, assign) mix_ns_type code_type;
@property (nonatomic, assign) BOOL isVarUsed;

@end

@interface Cpp_Define_Code : NSObject

@property (nonatomic, strong) NSString *varString;
@property (nonatomic, strong) NSString *defineString;
@property (nonatomic, strong) NSString *returnVarString;
@property (nonatomic, strong) NSArray *callStringArray;

//表示语句块的开始，语句块可以是if 或者 for、while循环 等 {
@property (nonatomic, strong) NSString *blockBegin;
//表示语句块的结束 }
@property (nonatomic, strong) NSString *blockEnd;

@property (nonatomic, assign) mix_ns_type code_type;
@property (nonatomic, assign) BOOL isVarUsed;

@end

#endif /* CodeConfuseMixOCModel_h */
