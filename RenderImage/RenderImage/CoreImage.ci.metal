//
//  CoreImage.ci.metal
//  RenderImage
//
//  Created by wenyang on 2022/10/18.
//

#include <metal_stdlib>
#include <CoreImage/CoreImage.h>
using namespace metal;
using namespace coreimage;

extern "C"{
    float4 ZipAlpha(sample_t sample){
        return float4(sample.xyz,1);
    }
}
