Shader "CookbookShaders/Chapter 5/AnimatedVertexShader" {
	Properties{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_TintAmount("Tint Amount", Range(0,1)) = 0.5
		_ColorA("Color A", Color) = (1,1,1,1)
		_ColorB("Color B", Color) = (1,1,1,1)
		_Speed("Wave Speed", Range(0.1, 80)) = 5
		_Frequency("Wave Frequency", Range(0,5)) = 2
		_Amplitude("Wave Amplitude", Range(-1, 1)) = 1
	}
		SubShader{
			Tags { "RenderType" = "Opaque" }
			LOD 200

			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma surface surf Lambert vertex:vert

			sampler2D _MainTex;
			half _TintAmount;
			half4 _ColorA;
			half4 _ColorB;
			half _Speed;
			half _Frequency;
			half _Amplitude;

			struct Input {
				float2 uv_MainTex;
				float4 vertColor;
			};

			//vertex data (such as color) is in the appdata_full parameter
			//the Input parameter will be passed on to surf()
			void vert(inout appdata_full v, out Input o) {
				// Initializes the variable o of type Input to zero. Necessary for DX11 compatibility.
				UNITY_INITIALIZE_OUTPUT(Input, o);

				float time = _Time * _Speed;
				float waveValueA = sin(time + v.vertex.x * _Frequency) * _Amplitude;
				v.vertex.xyz = float3(v.vertex.x, v.vertex.y + waveValueA, v.vertex.z);
				v.normal = normalize(float3(v.normal.x + waveValueA, v.normal.y, v.normal.z));
				o.vertColor.rgb = float3(waveValueA, waveValueA, waveValueA);
			}

			void surf (Input IN, inout SurfaceOutput o) {
				half4 c = tex2D(_MainTex, IN.uv_MainTex);
				float3 tintColor = lerp(_ColorA, _ColorB, IN.vertColor).rgb;
				o.Albedo = c * (tintColor * _TintAmount);
				o.Alpha = c.a;
			}
		ENDCG
	}
	FallBack "Diffuse"
}
