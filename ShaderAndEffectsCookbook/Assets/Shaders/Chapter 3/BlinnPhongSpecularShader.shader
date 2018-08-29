Shader "CookbookShaders/Chapter 3/BlinnPhongSpecularShader" {
	Properties {
		_MainTint("Tint", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_SpecularColor("Specular Color", Color) = (1,1,1,1)
		_SpecPower("Specular Power", Range(1,30)) = 1
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf CustomBlinnPhong

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		half4 _SpecularColor;
		half _SpecPower;

		struct Input {
			float2 uv_MainTex;
		};

		fixed4 _MainTint;

		void surf (Input IN, inout SurfaceOutput o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _MainTint;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}

		half4 LightingCustomBlinnPhong(SurfaceOutput i, half3 lightDir, half3 viewDir, half atten) {
			float NDotL = dot(i.Normal, lightDir);
			// this effectively replaces the reflection vector in the Phong specular shader for much less computing cost
			// it's the half vector (ie, halfway between the view direction and light direction)
			half3 halfVector = normalize(viewDir + lightDir);
			// we dot the normal with the half vector instead of the view vector with the reflection vector (i.e what is done in the phong model)
			float NDotH = max(0, dot(i.Normal, halfVector));
			float spec = pow(NDotH, _SpecPower);

			float4 c;
			c.rgb = (i.Albedo * _LightColor0.rgb * max(0, NDotL)) + (spec * _SpecularColor.rgb * _LightColor0.rgb) * atten;
			c.a = i.Alpha;
			return c;
		}

		ENDCG
	}
	FallBack "Diffuse"
}
