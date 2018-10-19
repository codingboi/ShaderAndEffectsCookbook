Shader "CookbookShaders/Chapter 8/Overlay_Effect"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_BlendTex("Blend Texture", 2D) = "white" {}
		_Opacity("Blend Opacity", Range(0,1)) = 1
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

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			uniform sampler2D _MainTex;
			uniform sampler2D _BlendTex;
			fixed _Opacity;

			fixed OverlayBlendMode(fixed basePixel, fixed blendPixel) {
				if (basePixel < 0.5)
				{
					return (2.0 * basePixel * blendPixel);
				}
				else
				{
					return (1.0 - 2.0 * (1.0 - basePixel) * (1.0 - blendPixel));
				}
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 blend = tex2D(_BlendTex, i.uv);

				fixed4 blendedImage = col;

				blendedImage.r = OverlayBlendMode(col.r, blend.r);
				blendedImage.g = OverlayBlendMode(col.g, blend.g);
				blendedImage.b = OverlayBlendMode(col.b, blend.b);

				col = lerp(col, blendedImage, _Opacity);
				return col;
			}
				ENDCG
		}
	}
}