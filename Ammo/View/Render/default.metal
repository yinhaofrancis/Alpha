//
//  default.metal
//  Ammo
//
//  Created by hao yin on 2022/8/29.
//

#include <metal_stdlib>
using namespace metal;
struct CokeRenderState{
    float3x3 tranform;

};
struct DrawState{
    float sum;
};

kernel void imageBuild(texture2d<half, access::write> to [[texture(0)]],uint2 gid [[thread_position_in_grid]]){
    if (gid.x % 10 > 4){
        to.write(half4(1,0,0,1), gid);
    }else{
        to.write(half4(0,0,0,1), gid);
    }
}

uint arrangement(uint top,uint all){
    if (top == 0){
        return 1;
    }else{
        return arrangement(top - 1, all - 1) * all;
    }
}

uint combination(uint top,uint all){
    return arrangement(top, all) / arrangement(top, top);
}

float2 bezierItem(device float2* points,float3x3 matrix,int n,int i,float t){
    float3 point3 = float3(points[i],1) * matrix;
    return (combination(i, n) * pow((1 - t), float(n - i)) * pow(t, i) * point3).xy;
}
float2 bezier(device float2* points,float3x3 matrix,int n,float t){
    float2 result = float2(0,0);
    for (int i = 0; i <= n;i++){
        result = result + bezierItem(points,matrix,n,i,t);
    }
    return result;
}

void plot(texture2d<half, access::write> texture,float x,float y,float alpha){
    texture.write(half4(1,0,0,alpha), uint2(x,y));
}
float ipart(float x){
    return floor(x);
}

// fractional part of x
float fpart(float x){
    return x - floor(x);
}

float rfpart(float x){
    return 1 - fpart(x);
}
float2 steepPoint (float2 v1){
    return float2(v1.y,v1.x);
}

void drawline(texture2d<half, access::write> texture,float2 point0,float2 point1){
    bool steep = abs(point1.y - point0.y) > abs(point1.x - point0.x);
    if (steep){
        point0 = steepPoint(point0);
        point1 = steepPoint(point1);
    }
    if (point0.x > point1.x){
        float2 temp = point0;
        point0 = point1;
        point1 = temp;

    }
    float dx = point1.x - point0.x;
    float dy = point1.y - point0.y;
    float gradient = dy / dx;
    if (dx == 0.0)
        gradient = 1.0;
    float xend = round(point0.x);
    float yend = point0.y + gradient * (xend - point0.x);
    float xgap = rfpart(point0.x + 0.5);
    float xpxl1 = xend;
    float ypxl1 = ipart(yend);
    if(steep){
        plot(texture,ypxl1,xpxl1, rfpart(yend) * xgap);
        plot(texture,ypxl1+1, xpxl1,  fpart(yend) * xgap);
    }else{
//        plot(texture,xpxl1, ypxl1  , rfpart(yend) * xgap);
//        plot(texture,xpxl1, ypxl1+1,  fpart(yend) * xgap);
    }
//    float intery = yend + gradient;
    xend = round(point1.x);
    yend = point1.y + gradient * (xend - point1.x);
    xgap = fpart(point1.x + 0.5);
//    float xpxl2 = xend; //this will be used in the main loop
//    float ypxl2 = ipart(yend);
}


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
    float size = max(to.get_width(), to.get_height());
    float t = gid / size;
    if(t >= 0 && t <= 1){
        float2 result = round(pow((1 - t),2) * point[0] + 2 * t * (1 - t) * point[1] + pow(t, 2) * point[2]);
        to.write(half4(1,0,0,1), uint2(result.x,result.y));
    }
}

kernel void cubicBezier(device float2* point [[buffer(0)]],
                        device CokeRenderState* state [[buffer(1)]],
                        device DrawState * drawState [[buffer(2)]],
                         texture2d<half, access::write> to [[texture(0)]],
                         uint gid [[thread_position_in_grid]]){
    float size = drawState->sum;
    float t = gid / size;
    if(t >= 0 && t <= 1){
        float2 result = round(bezier(point,state->tranform, 3, t));
        to.write(half4(1,0,0,1), uint2(result.x,result.y));
    }
}

