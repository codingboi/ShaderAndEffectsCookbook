Shader "CookbookShaders/Chapter 8/BSC_Effect"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BrightnessAmount("Brightness Amount", Range(0.0, 1)) = 1.0
		_satAmount ("Saturation Amount", Range(0.0, 1)) = 1.0
		_conAmount ("Contrast Amount", Range(0.0, 1)) = 1.0
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
			#pragma fragmentoption ARB_precision_hint_fastest
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
			
			uniform sampler2D _MainTex;
			fixed _BrightnessAmount;
			fixed _satAmount;
			fixed _conAmount;

			float3 ContrastSaturationBrightness(float3 color, float brt, float sat, float con) {
				// Increase or decrease these values to
				// adjust r, g and b channels separately
				float AvgLumR = 0.5;
				float AvgLumG = 0.5;
				float AvgLumB = 0.5;

				// Luminance coefficients for getting luminance from the image (CIE 1931 color matching values)
				float3 LuminanceCoeff = float3(0.2125, 0.7154, 0.0721);

				// Operation for Brightness //

				float3 AvgLumin = float3(AvgLumR, AvgLumG, AvgLumB);
				// multiplying the current color by the brightness value
				float3 brtColor = color * brt;
				// computing the overall brightness of the new image
				float intensityf = dot(brtColor, LuminanceCoeff);
				float3 intensity = float3(intensityf, intensityf, intensityf); // grey with a brightness depending on brt

				// Operation for Saturation //

				// lerping between the brightened up grey and the brightened up color
				float3 satColor = lerp(intensity, brtColor, sat);

				// Operation for Contrast //
				// lerping between default grey and the brightened up & saturated color
				float3 conColor = lerp(AvgLumin, satColor, con);
				return conColor;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				// just invert the colors
				col.rgb = ContrastSaturationBrightness(col.rgb,
														_BrightnessAmount,
														_satAmount,
														_conAmount);
				return col;
			}
			ENDCG
		}
	}
}
