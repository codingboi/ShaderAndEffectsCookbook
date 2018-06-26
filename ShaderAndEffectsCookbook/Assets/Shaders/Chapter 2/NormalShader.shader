Shader "CookbookShaders/Chapter 2/NormalShader" {
	Properties {
		_Tint ("Tint", Color) = (1,1,1,1)
		_NormalMap("Normal Map", 2D) = "bump" {}
		_NormalIntensity("Normal Intensity", Range(1,10)) = 1
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Lambert

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		struct Input {
			float2 uv_NormalMap;
		};

		fixed4 _Tint;
		sampler2D _NormalMap;
		float _NormalIntensity;

		void surf (Input IN, inout SurfaceOutput o) {
			// Albedo comes from a texture tinted by color
			o.Albedo = _Tint;
			float3 normalMap = UnpackNormal(tex2D(_NormalMap, IN.uv_NormalMap));
			normalMap.x *= _NormalIntensity;
			normalMap.y *= _NormalIntensity;
			o.Normal = normalize(normalMap);
			o.Alpha = _Tint.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
