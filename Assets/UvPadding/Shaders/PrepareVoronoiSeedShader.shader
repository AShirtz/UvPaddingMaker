Shader "Hidden/PrepareVoronoiSeedShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
			SamplerState point_clamp_sampler;

			float4 frag (v2f i) : SV_Target
			{
				int seedIndicator = _MainTex.Sample(point_clamp_sampler, i.uv).r;

				// Note that the blue channel is used as an indicator for whether or not the point has a valid seed index (avoids (0,0) rogue value issue)
				return (seedIndicator > 0) ? (float4(i.uv.r, i.uv.g, 0, 0)) : (float4(0, 0, 1, 0));
			}
			ENDCG
		}
	}
}
