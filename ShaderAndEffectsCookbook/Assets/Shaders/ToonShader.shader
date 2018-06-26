Shader "CookbookShaders/Chapter 3/ToonShader" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_CelShadingLevels ("Cel Shading Levels", Float) = 1
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
	//	_RampTex("Ramp Texture", 2D) = "white" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Toon

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _RampTex;

		struct Input {
			float2 uv_MainTex;
		};

		fixed4 _Color;
		float _CelShadingLevels;

		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}

		half4 LightingToon(SurfaceOutput i, half3 lightDir, half atten) {
			half NDotL = dot(i.Normal, lightDir);
			// ramp tex method : sample the gradient for the discrete reflectance value using the linear value
	//		NDotL = tex2D(_RampTex, fixed2(NDotL, 0.5));
			// flooring method : multiply the reflectance by the number of cel shading levels you want, floor the value to get an integer (that will always be inferior or equal to the number of levels)
			// divide it by the number of subdivisions to go back to the 0-1 reflectance range, which gives you a set of discrete, equidistant reflectance values
			NDotL = floor(NDotL * _CelShadingLevels) / _CelShadingLevels;
			fixed4 c;
			c.rgb = i.Albedo * _LightColor0.rgb * NDotL * atten;
			c.a = i.Alpha;

			return c;
		}

		ENDCG
	}
	FallBack "Diffuse"
}
