//
//  HMAnnotation.m
//  Himalaya
//
//  Created by KnowChat02 on 2019/6/3.
//  Copyright © 2019 KnowChat02. All rights reserved.
//
#include <mach-o/getsect.h>
#include <mach-o/loader.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>
#import <objc/runtime.h>
#import <objc/message.h>
#include <mach-o/ldsyms.h>

#import "HMAnnotation.h"
#import "HMModuleManager.h"
#import "HMAnotationStorage.h"

@implementation HMAnnotation

@end
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
NSArray<NSString*>* HMReadSlot(char* sectionName,const struct mach_header* mhd){
    unsigned long size = 0;
    NSMutableArray* slots = [[NSMutableArray alloc] init];
    const struct mach_header_64 *mhp64 = (struct mach_header_64 *)mhd;
    uintptr_t *memory = (uintptr_t*)getsectiondata(mhp64, SEG_DATA, sectionName, &size);
    
    NSUInteger count = size / sizeof(void*);
    
    for(int idx = 0; idx < count; ++idx){
        char *string = (char*)memory[idx];
        if(string == NULL) break;
        NSString *str = [NSString stringWithUTF8String:string];
        if(str.length == 0)break;
        if(str) [slots addObject:str];
    }
    return [slots copy];
}
static void dyld_callback(const struct mach_header *mhp, intptr_t vmaddr_slide){
    NSArray<NSString*>* mods = HMReadSlot(HMSectModuleName, mhp);
    for (NSString* desc in mods) {
        NSData* jsonData = [desc dataUsingEncoding:NSUTF8StringEncoding];
        NSError* e = nil;
        id json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
        if(!e){
            if([json isKindOfClass:NSDictionary.class] && [json allKeys].count){
                NSString *name = [json allKeys][0];
                NSString *clsName  = ((NSDictionary *)json)[name];
                if(name.length > 0 && clsName.length > 0){
                    [HMModuleManager.shared regModuleWithName:name implement:NSClassFromString(clsName)];
                }
            }
        }
    }
    NSArray<NSString*>* cu = HMReadSlot(HMSectCustom, mhp);
    for (NSString* desc in cu) {
        NSData* jsonData = [desc dataUsingEncoding:NSUTF8StringEncoding];
        NSError* e = nil;
        id json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
        if(!e){
            if([json isKindOfClass:NSDictionary.class] && [json allKeys].count){
                NSString *info = [json allKeys][0];
                NSDictionary *configure = ((NSDictionary *)json)[info];
                if(info.length > 0 && configure.count > 0){
                    [[HMAnotationStorage shared] addName:info key:configure.allKeys[0] value:configure.allValues[0]];
                }
            }
        }
    }
}

__attribute__((constructor(100)))
void initModule() {
    _dyld_register_func_for_add_image(dyld_callback);
}
