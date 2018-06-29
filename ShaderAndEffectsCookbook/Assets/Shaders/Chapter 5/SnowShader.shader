// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "CookbookShaders/Chapter 5/SnowShader" {
	Properties {
		_MainColor ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Bump ("Bump", 2D) = "bump" {}
		_Snow("Level of snow", Range(1,-1)) = 1
		_SnowColor("Color of snow", Color) = (1,1,1,1)
		_SnowDirection("Direction of snow", Vector) = (0,1,0)
		_SnowDepth("Depth of snow", Range(0,1)) = 0
	}
		SubShader{
			Tags { "RenderType" = "Opaque" }
			LOD 200

			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma surface surf Standard vertex:vert

			// Use shader model 3.0 target, to get nicer looking lighting
			#pragma target 3.0

			sampler2D _MainTex;
			sampler2D _Bump;
			half _Snow;
			half4 _SnowColor;
			half3 _SnowDirection;
			half _SnowDepth;

			struct Input {
				float2 uv_MainTex;
				float2 uv_Bump;
				float3 worldNormal;
				INTERNAL_DATA
			};

			fixed4 _MainColor;

			void vert(inout appdata_full v) {
				float4 sn = mul(unity_WorldToObject, _SnowDirection);
				if (dot(v.normal, sn.xyz) >= _Snow)
					v.vertex.xyz += (sn.xyz + v.normal) * _SnowDepth * _Snow;
			}

			void surf (Input IN, inout SurfaceOutputStandard o) {
				// Albedo comes from a texture tinted by color
				fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
				o.Normal = UnpackNormal(tex2D(_Bump, IN.uv_Bump));

				// here we compare the snow direction to the normal direction to determine if it's to be colored in _SnowColor
				// before dotting the normal, we convert it to world space with WorldNormalVector(), which is the equivalent of
				// mul(_Object2World, vertex) except here we're dealing with vectors instead of positions, necessitating another function
				if (dot(WorldNormalVector(IN, o.Normal), _SnowDirection.xyz) >= _Snow)
					o.Albedo = _SnowColor.rgb;
				else
					o.Albedo = c.rgb * _MainColor;
				// Metallic and smoothness come from slider variables
				o.Alpha = 1;
			}
			ENDCG
	}
	FallBack "Diffuse"
}
