// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Shadertoy/Template" { 
    Properties{
        iMouse ("Mouse Pos", Vector) = (100, 100, 0, 0)
        iChannel0("iChannel0", 2D) = "white" {}  
        iChannelResolution0 ("iChannelResolution0", Vector) = (100, 100, 0, 0)
    }
    SubShader {    
        Pass {    
            CGPROGRAM    
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
 
			fixed4 frag(v2f _iParam) : COLOR0 { 
			  /*
			  1.在四维中有xyzw四个分量 其中xyz三个点与w相除得到归一化的点
			  2.(_iParam.srcPos.xy/_iParam.srcPos.w)将得到在屏幕中归一化后的屏幕位置
			  3.最后与屏幕的分辨率相乘获得具体的位置
			  */
			   vec2 fragCoord = ((_iParam.scrPos.xy/_iParam.scrPos.w) * _ScreenParams.xy);
				return main(fragCoord);
			}  
 
			vec4 main(vec2 fragCoord) {
				return vec4(1, 1, 1, 1);
			}
 
            ENDCG    
        }    
    }     
    FallBack Off    
}
      