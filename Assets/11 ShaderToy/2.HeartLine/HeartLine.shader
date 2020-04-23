// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Shadertoy/HeartLine" { 
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
			#define iGlobalTime _Time.y
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
 
            float hash( uint n );

// Basic noise
float bnoise( in float x )
{
    float i = floor(x);
    float f = fract(x);
    float s = sign(fract(x/2.0)-0.5);
    
    // use some hash to create a random value k in [0..1] from i
    float k = hash(uint(i));
  //float k = 0.5+0.5*sin(i);
  //float k = fract(i*.1731);

    return s*f*(f-1.0)*((16.0*k-4.0)*f*(f-1.0)-1.0);
}

// Traditional gradient noise
float gnoise( in float p )
{
    uint  i = uint(floor(p));
    float f = fract(p);
	float u = f*f*(3.0-2.0*f);

    float g0 = hash(i+0u)*2.0-1.0;
    float g1 = hash(i+1u)*2.0-1.0;
    return 2.4*mix( g0*(f-0.0), g1*(f-1.0), u);
}

////////////////////////////////////

float fbm( in float x )
{    
    float n = 0.0;
    float s = 1.0;
    for( int i=0; i<9; i++ )
    {
        n += s*bnoise(x);
        s *= 0.5;
        x *= 2.0;
        x += 0.131;
    }
    return n;
}


vec4 main(vec2 fragCoord)
{	
    float px = 1.0/iResolution.y;
    vec2 p = fragCoord*px;
	
    vec3 col = vec3( 0.0,0.0,0.0 );
    col = mix( col, vec3(0.7,0.7,0.7), 1.0 - smoothstep( 0.0, 2.0*px, abs( p.y - 0.75 ) ) );
    col = mix( col, vec3(0.7,0.7,0.7), 1.0 - smoothstep( 0.0, 2.0*px, abs( p.y - 0.25 ) ) );
    p.x += iGlobalTime*0.1;
    
    {
        float y = 0.75+0.25*gnoise( 6.0*p.x );
        col = mix( col, vec3(0.3,0.3,0.3), 1.0 - smoothstep( 0.0, 4.0*px, abs(p.y-y) ) );
    }

    {
        float y = 0.75+0.25*bnoise( 6.0*p.x );
        col = mix( col, vec3(1.0,1.0,0.0), 1.0 - smoothstep( 0.0, 4.0*px, abs(p.y-y) ) );
    }

    {
        float y = 0.25+0.15*fbm( 2.0*p.x );
        col = mix( col, vec3(1.0,0.6,0.2), 1.0 - smoothstep( 0.0, 4.0*px, abs(p.y-y) ) );
    }
    return vec4( col, 1.0 );
}

float hash( uint n ) 
{   // integer hash copied from Hugo Elias
	n = (n<<13U)^n; 
    n = n*(n*n*15731U+789221U)+1376312589U;
    return float((n&uint(0x0fffffffU))) / float(0x0fffffff);
}
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
            ENDCG    
        }    
    }     
    FallBack Off    
}
