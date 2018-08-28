// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "CookbookShaders/Chapter 6/GlassShader"
{
	Properties{
		_MainTex("Base (RGB) Trans (A)", 2D) = "white" {}
		_BumpMap ("Noise tex", 2D) = "bump" {}
		_Magnitude ("Magnitude", Range(0,1)) = 0.05
		_Tint ("Tint", Color) = (1,1,1,1)
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		GrabPass { }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			// automatically created by GrabPass
			sampler2D _GrabTexture;
			sampler2D _MainTex;
			sampler2D _BumpMap;
			float _Magnitude;
			float4 _Tint;

			struct appdata
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 texcoord : TEXCOORD0;
				float4 uvGrab : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = v.texcoord	;
				o.uvGrab = ComputeGrabScreenPos(o.vertex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 mainColour = tex2D(_MainTex, i.texcoord);

				// using the bump map data to offset the grab texture uv and simulate glass distortion
				fixed2 distortion = UnpackNormal(tex2D(_BumpMap, i.texcoord)).rg;
				i.uvGrab.xy += distortion * _Magnitude;

				fixed4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.uvGrab));

				return col * mainColour * _Tint;
			}
			ENDCG
		}
	}
}
