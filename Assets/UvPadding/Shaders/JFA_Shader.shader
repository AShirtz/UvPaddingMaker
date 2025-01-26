Shader "Hidden/JFA_Shader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_JumpDist ("Jump Distance", Float) = 1
		_AspectRatio ("Screen Aspect Ratio", Float) = 1		// width/height
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

			float _JumpDist;
			float _AspectRatio;

			// Note that the 'z' dimension is used as an indicator for whether or not the point has a valid seed index (avoids (0,0) rogue value issue)
			inline float SqrMagnitude (float3 lhs, float3 rhs)
			{
				float2 s = float2 ((lhs.x - rhs.x) * _AspectRatio, (lhs.y - rhs.y));
				return (s.x*s.x) + (s.y*s.y) + (100 * (lhs.z + rhs.z));
			}

			inline float ManhattanMagnitude (float3 lhs, float3 rhs)
			{
				float2 s = float2 ((lhs.x - rhs.x) * _AspectRatio, (lhs.y - rhs.y));
				return abs(s.x) + abs(s.y) + (100 * (lhs.z + rhs.z));
			}

			float4 frag (v2f i) : SV_Target
			{
				// These find the sites to check
				float3 ul = _MainTex.Sample(point_clamp_sampler, i.uv + float2(_JumpDist, _JumpDist)).rgb;
				float3 um = _MainTex.Sample(point_clamp_sampler, i.uv + float2(_JumpDist, 0)).rgb;
				float3 ur = _MainTex.Sample(point_clamp_sampler, i.uv + float2(_JumpDist, -1 * _JumpDist)).rgb;

				float3 ml = _MainTex.Sample(point_clamp_sampler, i.uv + float2(0, _JumpDist)).rgb;
				float3 mm = _MainTex.Sample(point_clamp_sampler, i.uv).rgb;
				float3 mr = _MainTex.Sample(point_clamp_sampler, i.uv + float2(0, -1 * _JumpDist)).rgb;

				float3 ll = _MainTex.Sample(point_clamp_sampler, i.uv + float2(-1 * _JumpDist, _JumpDist)).rgb;
				float3 lm = _MainTex.Sample(point_clamp_sampler, i.uv + float2(-1 * _JumpDist, 0)).rgb;
				float3 lr = _MainTex.Sample(point_clamp_sampler, i.uv + float2(-1 * _JumpDist, -1 * _JumpDist)).rgb;

				// This waterfall of if statements selects the closest valid seed reference
				float3 if_01 = SqrMagnitude(float3(i.uv, 0), ul) < SqrMagnitude(float3(i.uv, 0), um) ? ul : um;
				float3 if_02 = SqrMagnitude(float3(i.uv, 0), if_01) < SqrMagnitude(float3(i.uv, 0), ur) ? if_01 : ur;

				float3 if_03 = SqrMagnitude(float3(i.uv, 0), if_02) < SqrMagnitude(float3(i.uv, 0), ml) ? if_02 : ml;
				float3 if_04 = SqrMagnitude(float3(i.uv, 0), if_03) < SqrMagnitude(float3(i.uv, 0), mm) ? if_03 : mm;
				float3 if_05 = SqrMagnitude(float3(i.uv, 0), if_04) < SqrMagnitude(float3(i.uv, 0), mr) ? if_04 : mr;

				float3 if_06 = SqrMagnitude(float3(i.uv, 0), if_05) < SqrMagnitude(float3(i.uv, 0), ll) ? if_05 : ll;
				float3 if_07 = SqrMagnitude(float3(i.uv, 0), if_06) < SqrMagnitude(float3(i.uv, 0), lm) ? if_06 : lm;
				float3 if_08 = SqrMagnitude(float3(i.uv, 0), if_07) < SqrMagnitude(float3(i.uv, 0), lr) ? if_07 : lr;

				return float4 (if_08.rgb, 0);
			}
			ENDCG
		}
	}
}
