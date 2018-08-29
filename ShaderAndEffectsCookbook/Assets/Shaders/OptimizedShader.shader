Shader "CookbookShaders/Chapter 7/OptimizedShader" {
	Properties {
		_Tint ("Tint", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_NormalMap ("Normal Map", 2D) = "bump" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// "exclude_path:prepass": excludes the Legacy Deferred path
		// "noforwardadd": "Disables Forward rendering additive pass. This makes the shader support one full [i.e. per-pixel] directional light,
		// with all other lights computed per-vertex/SH. Makes shaders smaller as well." - from Unity reference
		//		- in editor terms, only one "important" light will be supported by the shader
		#pragma surface surf SimpleLambert exclude_path:prepass noforwardadd

		// removed the normal map uv given that the normal map can use the same UV as the main texture
		// half: medium precision light type, said to be the lowest precision suitable for UV values
		struct Input {
			half2 uv_MainTex;
			//half2 uv_NormalMap;
		};

		// fixed: lowest precision type, suitable for colors, lighting calculations (and maybe positions? should check)
		fixed4 _Tint;
		sampler2D _MainTex;
		sampler2D _NormalMap;

		// changed types accordingly in both functions
		// note: conversions are costly in less powerful platforms such as mobile

		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Tint;
			o.Albedo = c.rgb;
			o.Alpha = c.a;

			o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
		}

		fixed4 LightingSimpleLambert(SurfaceOutput s, fixed3 lightDir, fixed atten) {
			fixed diff = max(0, dot(lightDir, s.Normal));

			fixed4 c;
			c.rgb = s.Albedo * _LightColor0.rgb * (diff * atten * 2);
			c.a = s.Alpha;

			return c;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
