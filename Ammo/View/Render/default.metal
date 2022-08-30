//
//  default.metal
//  Ammo
//
//  Created by hao yin on 2022/8/29.
//

#include <metal_stdlib>
using namespace metal;

kernel void imageBuild(texture2d<half, access::write> to [[texture(0)]],uint2 gid [[thread_position_in_grid]]){
    if (gid.x % 10 > 4){
        to.write(half4(1,0,0,1), gid);
    }else{
        to.write(half4(0,0,0,1), gid);
    }
}


//{\mathbf  {B}}(t)={\mathbf  {P}}_{0}+({\mathbf  {P}}_{1}-{\mathbf  {P}}_{0})t=(1-t){\mathbf  {P}}_{0}+t{\mathbf  {P}}_{1}{\mbox{ , }}t\in [0,1]
kernel void linearBezier(device float2* point [[buffer(0)]],
                         texture2d<half, access::write> to [[texture(0)]],
                         uint gid [[thread_position_in_grid]]){
    float size = max(to.get_width(), to.get_height());
    float t = gid / size;
    if(t >= 0 && t <= 1){
        float2 result = round((1 - t) * point[0] + t * point[1]);
        to.write(half4(1,0,0,1), uint2(result.x,result.y));
    }
}
kernel void quadraticBezier(device float2* point [[buffer(0)]],
                         texture2d<half, access::write> to [[texture(0)]],
                         uint gid [[thread_position_in_grid]]){
    float size = max(to.get_width(), to.get_height()) * 2;
    float t = gid / size;
    if(t >= 0 && t <= 1){
        float2 result = round(pow((1 - t),2) * point[0] + 2 * t * (1 - t) * point[1] + pow(t, 2) * point[2]);
        to.write(half4(1,0,0,1), uint2(result.x,result.y));
    }
}

kernel void cubicBezier(device float2* point [[buffer(0)]],
                         texture2d<half, access::write> to [[texture(0)]],
                         uint gid [[thread_position_in_grid]]){
    float size = max(to.get_width(), to.get_height()) * 3;
    float t = gid / size;
    if(t >= 0 && t <= 1){
        
        float2 result = round(pow((1 - t),3) * point[0] + 3 * t * pow((1 - t),2) * point[1] + 3 * (1 - t) * pow(t,2) * point[2] + pow(t, 3) * point[3]);
        to.write(half4(1,0,0,1), uint2(result.x,result.y));
    }
}
