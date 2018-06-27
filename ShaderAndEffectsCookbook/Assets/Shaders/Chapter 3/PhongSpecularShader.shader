Shader "CookbookShaders/Chapter 3/PhongSpecularShader" {
	Properties {
		_MainTint ("Tint", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_SpecularColor ("Specular Color", Color) = (1,1,1,1)
		_SpecPower ("Specular Power", Range(1,30)) = 1
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Phong

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		half4 _SpecularColor;
		half _SpecPower;

		struct Input {
			float2 uv_MainTex;
		};

		half4 _MainTint;

		void surf (Input IN, inout SurfaceOutput o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _MainTint;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}

		fixed4 LightingPhong(SurfaceOutput i, half3 lightDir, half3 viewDir, half atten) {
			float NDotL = dot(i.Normal, lightDir);

			// computing the reflection vector by projecting the light direction vector on the Normal
			// explainations :
			// - https://www.3dkingdoms.com/weekly/weekly.php?a=2
			// - https://www.fabrizioduroni.it/2017/08/25/how-to-calculate-reflection-vector.html (division by the vector length squared omitted in vector projection formula because the normal vector is a unit vector)
			// - https://en.wikipedia.org/wiki/Vector_projection#Vector_projection_3
			float reflectionVector = normalize(2.0 * i.Normal * NDotL - lightDir);
			// the more aligned the reflection vector and the view direction, the more the specular light is strong
			float spec = pow(max(0, dot(reflectionVector, viewDir)), _SpecPower);
			float3 finalSpec = _SpecularColor.rgb * spec;
				
			fixed4 c;
			// color = diffuse value + specular value
			c.rgb = (i.Albedo * _LightColor0.rgb * max(0, NDotL) * atten) + (_LightColor0 * finalSpec);
			c.a = i.Alpha;
			return c;
		}

		ENDCG
	}
	FallBack "Diffuse"
}
