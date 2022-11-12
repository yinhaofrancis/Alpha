//
//  module_loader.m
//  butterfly
//
//  Created by wenyang on 2022/11/12.
//

#include <stdio.h>
#include <mach-o/getsect.h>
#include <mach-o/loader.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>
#include <mach-o/ldsyms.h>

@import Foundation;


void readSection(const struct mach_header_64 *mhp){
    struct segment_command_64 *m = getsegbyname("data?");
    m->vmaddr;
    
}
static void dyld_callback(const struct mach_header_64 *mhp, intptr_t vmaddr_slide){
    readSection(mhp);
}

__attribute__((constructor(100)))
void initModule(void) {
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
    _dyld_register_func_for_add_image(dyld_callback);
}
