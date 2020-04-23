// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Shadertoy/BloodRain" { 
    Properties{
        iMouse ("Mouse Pos", Vector) = (100, 100, 0, 0)
        iChannel0("iChannel0", 2D) = "white" {}  
        iChannel1("iChannel1", 2D) = "white" {}  
        iChannelResolution0 ("iChannelResolution0", Vector) = (100, 100, 0, 0)
    }
    SubShader {    
        Pass {    
            HLSLPROGRAM  
            #pragma vertex vert    
            #pragma fragment frag 
			//使用低精度来提升片段着色器的运行速度 一般指fp16 半精度
            #pragma fragmentoption ARB_precision_hint_fastest     
			#include "UnityCG.cginc"   
			#pragma target 3.0      
			//定义各种常用宏
			#define vec2 float2
			#define vec3 float3
			#define vec4 float4
			#define mat2 float2x2
			#define mat3 float3x3
			#define mat4 float4x4
			#define iTime _Time.y
			#define mod fmod
			#define mix lerp
			#define fract frac
			#define texture2D tex2D
			//_ScreenParams为屏幕的分辨率
			#define iResolution _ScreenParams
  			
 
			#define PI2 6.28318530718
			#define pi 3.14159265358979
			#define halfpi (pi * 0.5)
			#define oneoverpi (1.0 / pi)
 
			fixed4 iMouse;
			sampler2D iChannel0;
		    sampler2D iChannel1;
			fixed4 iChannelResolution0;
 
			struct v2f {    
				float4 pos : SV_POSITION;    
				float4 scrPos : TEXCOORD0;   
			};              
 
			v2f vert(appdata_base v) {  
				v2f o;
				o.pos = UnityObjectToClipPos (v.vertex);
				//将顶点转成屏幕坐标
				o.scrPos = ComputeScreenPos(o.pos);
				return o;
			}  
			/*代码是从上到下读取的，要想在方法前面调用还没定义好的main函数，需要先声main方法
			  或者将main方法写在调用之前，这里将main方法写在后面是为了代码的可观性 因这之后逻辑大都在main方法上编写
			*/
			vec4 main(vec2 fragCoord);
 	
			
            #define PI 3.141592653589793
            
            float hash21(vec2 p)
            {
                uint2 q = uint2(int2(p)) * uint2(1597334673U, 3812015801U);
                uint n = (q.x ^ q.y) * 1597334673U;
                return float(n) / float(0xffffffffU);
            }
            
            vec3 hash13(float p) {
               vec3 p3 = fract(vec3(p,p,p) * vec3(.1031,.11369,.13787));
               p3 += dot(p3, p3.yzx + 19.19);
               return fract(vec3((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y, (p3.y+p3.z)*p3.x));
            }
            //小圆形雨滴
            float rainDrops(vec2 st, float time, float size)
            {
                vec2 uv = st * size;
                uv.x *= iResolution.x / iResolution.y;
                vec2 gridUv = fract(uv) - .5; // grid
                vec2 id = floor(uv);
                vec3 h = (hash13(id.x * 467.983 + id.y * 1294.387) - .5) * .8;
                vec2 dropUv = gridUv - h.xy;
                vec4 noise = tex2Dlod(iChannel1, vec4(id.x * .05,id.y * 0.5,0,0));
                float drop = smoothstep(.25, 0., length(dropUv)) *
                    max(0., 1. - fract(time * (noise.b + .1) * .2 + noise.g) * 2.);
                return drop;
            }
            
            vec2 wigglyDrops(vec2 st, float time, float size)
            {
                vec2 wigglyDropAspect = vec2(2., 1.);
                vec2 uv = st * size * wigglyDropAspect;
                uv.x *= iResolution.x / iResolution.y;
                //y moves by time
                uv.y += time * .23;
                // the uv in a grid at center
                vec2 gridUv = fract(uv) - .5; // rectangular grid
                //get grid id
                vec2 id = floor(uv);
                
                float h = hash21(id);
                time += h * 2. * PI;
                float w = st.y * 10.;
                float dx = (h - .5) * .8;
                dx += (.3 - abs(dx)) * pow(sin(w), 2.) * sin(2. * w) *
                    pow(cos(w), 3.) * 1.05; // wiggle
                float dy = -sin(time + sin(time + sin(time) * .5)) * .45; // slow down drop before continuing falling
                dy -= (gridUv.x - dx) * (gridUv.x - dx);
                vec2 dropUv = (gridUv - vec2(dx, dy)) / wigglyDropAspect;
                // describe rain drop
                float drop = smoothstep(.06, .0, length(dropUv));
                //拖尾的一串雨滴
                vec2 trailUv = (gridUv - vec2(dx, time * .23)) / wigglyDropAspect;
                trailUv.y = (fract((trailUv.y) * 8.) - .5) / 8.;
                float trailDrop = smoothstep(.03, .0, length(trailUv));
                trailDrop *= smoothstep(-.05, .05, dropUv.y) * smoothstep(.4, dy, gridUv.y) *
                        (1.-step(.4, gridUv.y));
                //玻璃拖尾效果
                float fogTrail = smoothstep(-.05, .05, dropUv.y) * smoothstep(.4, dy, gridUv.y) *
                        smoothstep(.05, .01, abs(dropUv.x)) * (1.-step(.4, gridUv.y));
                
                return vec2(drop + trailDrop, fogTrail);
            }
            
            vec2 getDrops(vec2 st, float time)
            {
                //三种大小的雨滴
                vec2 largeDrops = wigglyDrops(st, time * 2., 1.6);
                vec2 mediumDrops = wigglyDrops(st + 2.65, (time + 1296.675) * 1.4, 2.5);
                vec2 smallDrops = wigglyDrops(st - 1.67, time - 896.431, 3.6);
                float rain = rainDrops(st, time, 20.);
                
                vec2 drops;
                //y 存储拖尾效果
                drops.y = max(largeDrops.y, max(mediumDrops.y, smallDrops.y));
                //x 存储雨滴
                drops.x = smoothstep(.4, 2., (1. - drops.y) * rain + largeDrops.x +
                               mediumDrops.x + smallDrops.x); // drops kinda blend together
               // drops.y = 0;
               // drops.x = smoothstep(.4, 2., (1. - drops.y) * rain); // drops kinda blend together                     
            
                return drops;
            } 
			fixed4 frag(v2f _iParam) : COLOR0 { 
			  /*
			  1.在四维中有xyzw四个分量 其中xyz三个点与w相除得到归一化的点
			  2.(_iParam.srcPos.xy/_iParam.srcPos.w)将得到在屏幕中归一化后的屏幕位置
			  3.最后与屏幕的分辨率相乘获得具体的位置
			  */
			   vec2 fragCoord = ((_iParam.scrPos.xy/_iParam.scrPos.w) * _ScreenParams.xy);
				return main(fragCoord);
			}  
 
			vec4 main(vec2 fragCoord)
			 {
				vec2 st = fragCoord / iResolution.xy;
                float time = mod(iTime + 100., 7200.);
                
                vec2 drops = getDrops(st, time);
                vec2 offset = drops.xy;
                float lod = (1. - drops.y) * 4.8;
                
                // This is kinda expensive, would love to use a cheaper method here.
                vec2 dropsX = getDrops(st + vec2(.001, 0.), time);
                vec2 dropsY = getDrops(st + vec2(0., .001), time);
                vec3 normal = vec3(dropsX.x - drops.x, dropsY.x - drops.x, 0.);
                normal.z = sqrt(1. - normal.x * normal.x - normal.y * normal.y);
                normal = normalize(normal);
                
                float lightning = sin(time * sin(time * 18.)); // screen flicker
                float lightningTime = mod(time, 10.) / 9.9;
                lightning *= 1. - smoothstep(.0, .1, lightningTime)
                    + smoothstep(.9, 1., lightningTime); // lightning flash mask
                
                //vec3 col = textureLod(iChannel0, st+normal.xy * 3., lod).rgb;
                vec4 col4 = tex2Dlod(iChannel0, vec4((st+normal.xy * 3).x,(st+normal.xy * 3).y,0,lod));
                vec3 col = vec3(col4.x,col4.y,col4.z);
               
               
                col *= (1. + lightning);
                
                col *= vec3(1., .8, .7); // slight red-ish tint
                col += (drops.y > 0. ? vec3(.5, -.1, -.15)*drops.y : vec3(0,0,0)); // bloody trails
                col *= (drops.x > 0. ? vec3(.8, .2, .1) * (1.-drops.x) : vec3(1,1,1)); // blood colored drops
                
                col = mix(col, col*smoothstep(.8, .35, length(st - .5)), .6); // vignette
                return vec4(col, 1.0);
			}
			
			
		
ENDHLSL    
        }    
    }     
    FallBack Off    
}
      