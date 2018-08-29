Shader "CookbookShaders/Chapter 7/MobileShader" {
	Properties {
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_SpecIntensity ("Specular intensity", Range(0.01, 1)) = 0.5
		_NormalMap ("Normal map", 2D) = "bump" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// "exclude:prepass": excludes the Legacy Deferred path
		// "nolightmap": skips lightmap check, improves performance
		// "noforwardadd": "Disables Forward rendering additive pass. This makes the shader support one full [i.e. per-pixel] directional light,
		// with all other lights computed per-vertex/SH. Makes shaders smaller as well." - from Unity reference
		// "halfasview": allows us to use the half vector directly in our implementation of the blinn phong model without having to calculate it ourselves
		#pragma surface surf MobileBlinnPhong exclude:prepass nolightmap noforwardadd halfasview

		sampler2D _MainTex;
		sampler2D _NormalMap;
		fixed _SpecIntensity;

		struct Input {
			float2 uv_MainTex;
		};	


		void surf (Input IN, inout SurfaceOutput o) {
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
			o.Albedo = c.rgb;
			o.Gloss = c.a;
			o.Alpha = 0.0;
			o.Specular = _SpecIntensity;
			o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
		}

		fixed4 LightingMobileBlinnPhong(SurfaceOutput s, fixed3 lightDir, fixed3 halfDir, fixed atten) {
			//diffuse coefficient
			fixed diff = max(0, dot(s.Normal, lightDir));
			//specular coefficient
			fixed nh = max(0, dot(s.Normal, halfDir));
			fixed spec = pow(nh, s.Specular * 128) * s.Gloss;

			fixed4 c;
			c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * (atten * 2);
			c.a = 0.0;
			return c;
		}

		ENDCG
	}
	FallBack "Diffuse"
}
