// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "CookbookShaders/Chapter 6/WaterShader"
{
	Properties{
		_NoiseTex("Noise Tex", 2D) = "white" {}
		_Colour("Colour", Color) = (1,1,1,1)
		_Period("Period", Range(0,50)) = 1
		_Magnitude("Magnitude", Range(0,0.5)) = 0.05
		_Scale("Scale", Range(0,10)) = 1
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

			sampler2D _GrabTexture;
			sampler2D _NoiseTex;
			fixed4 _Colour;
			float _Period;
			float _Magnitude;
			float _Scale;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float2 texcoord : TEXCOORD0;
				float4 worldPos : TEXCOORD1;
				float4 uvGrab : TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = v.texcoord;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.uvGrab = ComputeGrabScreenPos (o.vertex);
				return o;
			}
			
			//fixed4 frag (v2f i) : SV_Target
			//{
			//	fixed4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.uvGrab));
			//	return col + half4(0.5, 0, 0, 0);
			//}

			fixed4 frag(v2f i) : COLOR{
				// generating a pseudo-random periodical value using a sine function :
				// - a sine function is dependent on time, allowing us to animate the shader
				// - period is used to control the speed of the distortion animation
				float sinT = sin(_Time.w / _Period);	
				// sampling the noise texture to create a distortion vector:
				// - we use worldPos so that the distortion doesn't "follow" the object's position
				// - _Scale controls the size of the distortion
				// - the sampling is offset by the sine value, in different UV axises for the two components of the distortion vector so as to avoid having the same distortion in both directions
			    //		- the red channel is here an arbitrary choice to get a value, the whiteness of the pîxel actually determines the value
				float2 distortion = float2(tex2D(_NoiseTex, i.worldPos.xy / _Scale + float2(sinT, 0)).r - 0.5, tex2D(_NoiseTex, i.worldPos.xy / _Scale + float2(0, sinT)).r - 0.5);

				// much like in the glass shader, we apply the distortion to the grab texture uv
				i.uvGrab.xy += distortion * _Magnitude;
				fixed4 col = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.uvGrab));
				return col * _Colour;
			}
			ENDCG
		}
	}
}
