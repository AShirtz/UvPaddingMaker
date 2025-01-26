Shader "Hidden/SeedGenerationShader"
{
    Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_MaskColor ("Mask Color", Color) = (0, 0, 0, 0)
		_Threshold ("Mask Threshold", float) = 0.1
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

			inline float SqrMagnitude (float3 lhs, float3 rhs)
			{
				float3 s = float3 ((lhs.x - rhs.x), (lhs.y - rhs.y), (lhs.z - rhs.z));
				return (s.x*s.x) + (s.y*s.y) + (s.z*s.z);
			}

			Texture2D _MainTex;
			SamplerState point_clamp_sampler;
			float4 _MaskColor;
			float _MaskThreshold;

			float4 frag (v2f i) : SV_Target
			{
				// Sample color from Texture
				float4 clr = _MainTex.Sample(point_clamp_sampler, i.uv);

				return SqrMagnitude(clr, _MaskColor) > _MaskThreshold ? float4(1, 0, 0, 1) : float4(0, 0, 0, 1);
			}
			ENDCG
		}
	}
}
