//
//  CodeConfuseRandomCode.h
//  CodeConfuse
//
//  Created by ConfuseCode on 2018/12/24.
//  Copyright © 2018年 fkd All rights reserved.
//

#import <Foundation/Foundation.h>
#include "CodeConfuseMixOCModel.h"
#include "CodeConfuseMixCppModel.h"

@interface CodeConfuseRandomCode : NSObject

+ (string)get_oc_ns_type:(mix_ns_type)nstype;

+ (string)get_cpp_ns_type:(mix_ns_type)nstype;

+ (NSString *)random_value_by_type:(mix_ns_type)nstype;

+ (NSString *)random_cpp_value_by_type:(mix_ns_type)nstype;

+ (OC_Define_Code *)random_oc_var_define;

+ (Cpp_Define_Code *)random_cpp_var_define;

+ (OC_Define_Code *)generate_oc_var_by_type:(mix_ns_type)generate_type;

+ (Cpp_Define_Code *)generate_cpp_var_by_type:(mix_ns_type)generate_type;

+ (mix_ns_type)rand_oc_ns_type:(int)startpos;

+ (mix_ns_type)rand_cpp_ns_type:(int)startpos;

+ (NSString *)rand_identifier;

+ (NSString *)rand_identifierWithPrefix:(NSString *)idPrefix;

+ (NSString *)rand_identifier_capitalized;

+ (NSString *)rand_string:(int)mix max:(int)max;

+ (char)rand_num_range:(int)range;

+ (int)rand_num:(int)min max:(int)max;

+ (bool)rand_bool;

+ (char)rand_char;

+ (float)random_float:(float)min max:(float)max;

+ (double)random_double:(double)min max:(double)max;

+ (NSString *)rand_operator;

+ (NSString *)rand_compare_operator;

+ (NSString *)rand_assign_operator;

+ (NSString *)rand_for_key:(NSUInteger)seed;

+ (string)rand_oc_property_attributes:(mix_ns_type)nstype;

+ (string)get_prefix_from_ns_type:(mix_ns_type)nstype;

@end
