//
//  CodeConfuseMixCppModel.h
//  CodeConfuse
//
//  Created by ConfuseCode on 2018/12/25.
//  Copyright © 2018年 All rights reserved.
//

#ifndef CodeConfuseMixCppModel_h
#define CodeConfuseMixCppModel_h

#import "CodeConfuseMixOCModel.h"
#include <string>

using namespace std;

//C++ 方法参数
struct mix_cpp_params
{
    mix_ns_type ret_type;
    std::string param_type;
    std::string param_name;
};
typedef mix_cpp_params mix_cpp_params;

//C++ 方法/函数
struct mix_cpp_method
{
    bool is_static;
    mix_ns_type ret_type;
    std::string name;
    int param_count;
    mix_cpp_params** params;
};
typedef mix_cpp_method mix_cpp_method;

//C++ 类
struct mix_cpp_class
{
    std::string name;
    mix_cpp_method** methods;
    int method_count;
};
typedef mix_cpp_class mix_cpp_class;

#endif /* CodeConfuseMixCppModel_h */
