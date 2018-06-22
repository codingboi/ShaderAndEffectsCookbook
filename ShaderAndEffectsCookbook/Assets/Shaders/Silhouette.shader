Shader "CookbookShaders/Silhouette" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_DotProduct("Rim Effect", Range(-1,1)) = 0
	}
	SubShader {
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Lambert alpha:fade nolighting

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		struct Input {
			float3 worldNormal;
			float3 viewDir;
		};

		fixed4 _Color;
		float _DotProduct;

		void surf (Input IN, inout SurfaceOutput o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = _Color;
			o.Albedo = c.rgb;
			float border = 1 - abs(dot(IN.worldNormal, IN.viewDir));
			// Metallic and smoothness come from slider variables
			float alpha = (border * (1 - _DotProduct) + _DotProduct);
			o.Alpha = c.a * alpha;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
