// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Shadertoy/Flame" { 
    Properties{
        iMouse ("Mouse Pos", Vector) = (100, 100, 0, 0)
        iChannel0("iChannel0", 2D) = "white" {}  
        iChannelResolution0 ("iChannelResolution0", Vector) = (100, 100, 0, 0)
    }
    SubShader {    
        Pass {    
            Tags {"RenderType"="Transparent"}
            ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
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
 
 
 
float noise(vec3 p) //Thx to Las^Mercury
{
	vec3 i = floor(p);
	vec4 a = dot(i, vec3(1., 57., 21.)) + vec4(0., 57., 21., 78.);
	vec3 f = cos((p-i)*acos(-1.))*(-.5)+.5;
	a = mix(sin(cos(a)*a),sin(cos(1.+a)*(1.+a)), f.x);
	a.xy = mix(a.xz, a.yw, f.y);
	return mix(a.x, a.y, f.z);
}

float sphere(vec3 p, vec4 spr)
{
	return length(spr.xyz-p) - spr.w;
}

float flame(vec3 p)
{
	float d = sphere(p*vec3(1.,.5,1.), vec4(.0,-1.,.0,1.));
	return d + (noise(p+vec3(.0,iTime*2.,.0)) + noise(p*3.)*.5)*.25*(p.y) ;
}

float scene(vec3 p)
{
	return min(100.-length(p) , abs(flame(p)) );
}

vec4 raymarch(vec3 org, vec3 dir)
{
	float d = 0.0, glow = 0.0, eps = 0.02;
	vec3  p = org;
	bool glowed = false;
	
	for(int i=0; i<64; i++)
	{
		d = scene(p) + eps;
		p += d * dir;
		if( d>eps )
		{
			if(flame(p) < .0)
				glowed=true;
			if(glowed)
       			glow = float(i)/64.;
		}
	}
	return vec4(p,glow);
}

vec4 main(vec2 fragCoord )
{
	vec2 v = -1.0 + 2.0 * fragCoord.xy / iResolution.xy;
	v.x *= iResolution.x/iResolution.y;
	
	vec3 org = vec3(0., -2.5, 5.);
	vec3 dir = normalize(vec3(v.x*1.6, -v.y, -1.5));
	
	vec4 p = raymarch(org, dir);
	float glow = p.w;
	
	vec4 col = mix(vec4(1.,.5,.1,1.), vec4(0.1,.5,1.,1), p.y*.02+.4);
	//return col;
	vec4 fragColor = mix(vec4(0,0,0,0), col, pow(glow*2.,4.));
	//fragColor.w = 0;
	//fragColor.z = 0;
	//fragColor.y = 0;
	//fragColor.x = 0;
	return fragColor;
	//vec2 st = fragCoord / iResolution.xy;
	//float d = sphere(vec3(v,0), vec4(.5,0.5,.0,0.1));
   // float d = abs(flame(vec3(v,0)));
	//vec4 fragColor = (d,d,d,d);
	//return fragColor;

}


 
            ENDCG    
        }    
    }     
    FallBack Off    
}
      