Shader "Hidden/ColorLookupShader"
{
	Properties
	{
		_MainTex ("Voronoi Cell Texture", 2D) = "white" {}		// This is the lookup location texture (result of voronoi tessellation)
		_ColorTex ("Color Lookup Texture", 2D) = "white" {}		// This is the texture that colors are read from.
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			Texture2D _MainTex;
			Texture2D _ColorTex;

			SamplerState trilinear_clamp_sampler;
			SamplerState linear_clamp_sampler;
			SamplerState point_clamp_sampler;

			float4 frag (v2f i) : SV_Target
			{
				return _ColorTex.Sample(point_clamp_sampler, _MainTex.Sample(point_clamp_sampler, i.uv).xy);
			}
			ENDCG
		}
	}
}
