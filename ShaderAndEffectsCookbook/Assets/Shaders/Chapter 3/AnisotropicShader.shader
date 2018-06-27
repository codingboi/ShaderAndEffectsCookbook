Shader "CookbookShaders/Chapter 3/AnisotropicShader" {
	Properties {
		_MainTint ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_SpecularColor ("Specular Color", Color) = (1,1,1,1)
		_Specular ("Specular Amount", Range(0,1)) = 0.5
		_SpecPower ("Specular Power", Range(0,1)) = 0.5
		_AnisoDir ("Anisotropic Direction", 2D) = "" {}
		_AnisoOffset ("Anisotropic Offset", Range(-1,1)) = -0.2
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Anisotropic fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _AnisoDir;
		half _AnisoOffset;
		half4 _MainTint;
		half4 _SpecularColor;
		half _Specular;
		half _SpecPower;


		struct Input {
			float2 uv_MainTex;
			float2 uv_AnisoDir;
		};

		struct SurfaceAnisoOutput {
			fixed3 Albedo;
			fixed3 Normal;
			fixed3 Emission;
			fixed3 AnisoDirection;
			half Specular;
			fixed Gloss;
			fixed Alpha;
		};

		void surf (Input IN, inout SurfaceAnisoOutput o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _MainTint;
			float3 anisoTex = UnpackNormal(tex2D(_AnisoDir, IN.uv_AnisoDir));

			o.AnisoDirection = anisoTex;
			o.Specular = _Specular;
			o.Gloss = _SpecPower;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}

		

		half4 LightingAnisotropic(SurfaceAnisoOutput i, half3 lightDir, half3 viewDir, half atten) {
			fixed3 halfVector = normalize(normalize(lightDir) + normalize(viewDir));
			float NDotL = saturate(dot(i.Normal, lightDir));
			fixed HDotA = dot(normalize(i.Normal + i.AnisoDirection), halfVector);
			float aniso = max(0, sin(radians((HDotA + _AnisoOffset) * 180)));
			float spec = saturate(pow(aniso, i.Gloss * 128) * i.Specular);

			fixed4 c;
			c.rgb = ((i.Albedo * _LightColor0.rgb * NDotL) + (_LightColor0.rgb * _SpecularColor.rgb * spec)) * atten;
			c.a = i.Alpha;

			return c;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
