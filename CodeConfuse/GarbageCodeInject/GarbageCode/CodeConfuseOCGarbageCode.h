//
//  CodeConfuseOCGarbageCode.h
//  CodeConfuse
//
//  Created by ConfuseCode on 2018/12/24.
//  Copyright © 2018年 fkd All rights reserved.
//
#include "CodeConfuseMixOCModel.h"

using namespace std;

@interface CodeConfuseOCGarbageCode : NSObject

@property (nonatomic, strong) NSMutableArray *class_method_call_list;
@property (nonatomic, strong) NSMutableArray *instance_method_call_list;

- (void)free:(mix_oc_class*)mc;

- (mix_oc_method*)create_method;

- (mix_oc_params*)create_params:(int)index;

- (mix_oc_class*)create_class;

//生成OC类
- (string)generate_oc_class;

- (string)get_default_value:(mix_ns_type)nstype;

//生成OC垃圾代码
+ (string)generate_oc_with_return_type:(mix_ns_type)return_type;

@end
