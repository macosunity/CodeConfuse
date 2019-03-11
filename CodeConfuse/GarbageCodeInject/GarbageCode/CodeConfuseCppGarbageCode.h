//
//  CodeConfuseCppGarbageCode.h
//  CodeConfuse
//
//  Created by ConfuseCode on 2018/12/25.
//  Copyright © 2018年 All rights reserved.
//

#import <Foundation/Foundation.h>
#include <string>
#include "CodeConfuseMixOCModel.h"
#import "CodeConfuseMixCppModel.h"

using namespace std;

@interface CodeConfuseCppGarbageCode : NSObject

@property (nonatomic, strong) NSMutableArray *cpp_method_call_list;

- (void)free:(mix_cpp_class*)mc;

//生成C++类
- (string)generate_cpp_class;

- (mix_cpp_method*)create_method;

- (mix_cpp_params*)create_params:(int)index;

- (mix_cpp_class*)create_class;

- (string)get_default_value:(mix_ns_type)nstype;

//生成Cpp垃圾代码
+ (string)generate_cpp_code_with_return_type:(mix_ns_type)return_type;

@end
