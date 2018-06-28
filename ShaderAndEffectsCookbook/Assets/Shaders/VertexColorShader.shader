Shader "CookbookShaders/Chapter 5/VertexColorShader" {
	Properties{
		_MainTint("Global Color Tint", Color) = (1,1,1,1)
	}
		SubShader{
			Tags { "RenderType" = "Opaque" }
			LOD 200

			CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Lambert vertex:vert

		float4 _MainTint;

		struct Input {
			float4 vertColor;
		};

		//vertex data (such as color) is in the appdata_full parameter
		//the Input parameter will be passed on to surf()
		void vert(inout appdata_full v, out Input o) {
			// Initializes the variable o of type Input to zero. Necessary for DX11 compatibility.
			UNITY_INITIALIZE_OUTPUT(Input, o);
			o.vertColor = v.color;
		}

		void surf (Input IN, inout SurfaceOutput o) {
			o.Albedo = IN.vertColor.rgb * _MainTint.rgb;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
