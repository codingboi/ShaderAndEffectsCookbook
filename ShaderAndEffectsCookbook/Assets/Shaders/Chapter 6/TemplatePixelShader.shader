// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "CookbookShaders/Chapter 6/TemplatePixelShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,0,0,1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				// using binding semantics (POSITION, TEXCOORD0...) so that the GPU initializes the fields with proper data
				// these are input semantics, used for data provided by Unity to the shader
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				// binding semantics are still necessary even though we need to initialize those values ourselves in the vert function
				// these are output semantics, used for data provided by the vert function to the frag function
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			// more info on semantics: https://docs.microsoft.com/fr-fr/windows/desktop/direct3dhlsl/dx-graphics-hlsl-semantics

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _Color;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				return col * _Color;
			}
			ENDCG
		}
	}
}
