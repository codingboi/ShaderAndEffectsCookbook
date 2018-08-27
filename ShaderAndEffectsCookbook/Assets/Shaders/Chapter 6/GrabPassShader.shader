// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "CookbookShaders/Chapter 6/GrabPassShader"
{
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		GrabPass { }

		// Here, we could optionally use GrabPass { "TextureName" } for better performance. From the reference:
		//"GrabPass { "TextureName" } grabs the current screen contents into a texture, but will only do that once per frame for the first object that uses the given texture name.
		//The texture can be accessed in further passes by the given texture name. This is a more performant method when you have multiple objects using GrabPass in the scene."

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			// automatically created by GrabPass
			sampler2D _GrabTexture;

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 uvGrab : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				// from shader reference, this function "Computes texture coordinate for sampling a GrabPass texure. Input is clip space position."
				o.uvGrab = ComputeGrabScreenPos (o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the grabbed texture using tex2DProj and UNITY_PROJ_COORD so as to take into account the orientation and position of the projector (in this case, the camera)
				// in order to sample the correct part of the texture, process without which the transparency illusion created by the GrabPass would be broken by the perspective
				fixed4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.uvGrab));
				return col + half4(0.5, 0, 0, 0);
			}
			ENDCG
		}
	}
}
