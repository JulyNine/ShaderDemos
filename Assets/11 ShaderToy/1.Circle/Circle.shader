// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "Custom/circle" {
	Properties {
		//xy表示圆心在屏幕中的uv值,z为半径,w为圆边缘的平滑值
		_parameters("circleParameter",Vector)=(0.5,0.5,10,0)
		_Color("circleColor",COLOR)=(1,1,1,1)
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		Pass{
		CGPROGRAM
		#include "UnityCG.cginc"
		#pragma fragmentoption ARB_precision_hint_fastest   
		#pragma target 3.0
		#pragma vertex vert
		#pragma fragment frag
 
		#define vec2 float2
		#define vec3 float3
		#define vec4 float4
		#define mat2 float2
		#define mat3 float3
		#define mat4 float4
		#define iGlobalTime _Time.y
		#define mod fmod
		#define mix lerp
		#define fract frac
		#define Texture2D tex2D
		#define iResolution _ScreenParams
 
		float4 _parameters;
		float4 _Color;
		float4 _backgroundColor;
 
		struct v2f{
			float4 pos:SV_POSITION;
			float4 srcPos:TEXCOORD0;
		};
 
		v2f vert(appdata_base v){
			v2f o;
			o.pos=UnityObjectToClipPos(v.vertex);
			o.srcPos=ComputeScreenPos(o.pos);
			return o;
		}
		vec4 main(vec2 fragCoord);
		float4 frag(v2f iParam):COLOR{
			//获取uv对应的当前分辨率下的点   uv范围（0-1） 与分辨率相乘
			vec2 fragCoord=((iParam.srcPos.xy/iParam.srcPos.w)*_ScreenParams.xy);
			return main(fragCoord);
		}
		//要先定义方法声明才能使用
		vec4 cicle(vec2 pos,vec2 center,float radius,float3 col,float antialias){
			//求出点到圆心距离，如果为正则在圆外 负在圆内 我们需要对圆内的点进行上色 即对负值进行处理
			float d=length(pos-center)-radius;
			//判断d的大小 如果小于0则返回0 如果大于antialias返回1 返回值在0-1之间
			//smoothstep(a,b,t) 判断t t<a返回0，t>b返回1，t在a-b之间反差值返回0-1 
			float t=smoothstep(0,antialias,d);
			//返回颜色值 在圆外的设置alpha=0透明 
			return vec4(col,1.0-t);
 
		}
		vec4 main(vec2 fragCoord){
			vec2 pos=fragCoord;
			//给背景一个动态的颜色
			vec3 temp = 0.5 + 0.5*cos(iGlobalTime+pos.xyx/_ScreenParams.y+vec3(0,2,4));
			//获取背景的颜色
			vec4 layer1=vec4(temp,1.0);
			//获取圆
			vec4 layer2=cicle(pos,_parameters.xy*iResolution.xy,_parameters.z,_Color.rgb,_parameters.w);
			//插值处理，使边界更模糊化，layer2中的_parameters.w值越大越模糊
			return mix(layer1,layer2,layer2.a);
		}
 
 
 
		ENDCG
		}
	}
	FallBack "Diffuse"
}
