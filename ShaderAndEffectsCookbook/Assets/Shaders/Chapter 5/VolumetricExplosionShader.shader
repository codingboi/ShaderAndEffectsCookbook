Shader "CookbookShaders/Chapter 5/VolumetricExplosionShader" {
		Properties {
			_RampTex ("Color Ramp", 2D) = "white" {}
			_RampOffset ("Ramp offset", Range(-0.5, 0.5)) = 0

			_NoiseTex("Noise tex", 2D) = "gray" {}
			_Period("Period", Range(0,1)) = 0.1

			_Amount("Amount", Range(0,1.0)) = 0.1
			_ClipRange("ClipRange", Range(0,1)) = 1
		}

		SubShader{
			Tags { "RenderType" = "Opaque" }
			LOD 200

			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma surface surf Lambert vertex:vert nolightmap

			sampler2D _RampTex;
			half _RampOffset;

			sampler2D _NoiseTex;
			half _Period;

			half _Amount;
			half _ClipRange;

			struct Input {
				half2 uv_NoiseTex;
			};

			fixed4 _Color;

			void vert(inout appdata_full v) {
				// sampling the noise texture
				float3 disp = tex2Dlod(_NoiseTex, float4(v.texcoord.xy, 0, 0));
				// _Period determines the frequency of the sinus function (and thus the movement of the explosion)
				// disp determines the phase of the sinus, which offsets the movement depending on the whiteness of the pixel sampled on the texture
				// the more the noise pixel sampled is white, the more the phase will be big
				float time = sin(_Time[3] * _Period + disp.r * 10);
				// normal extrusion depending on the previously computed values
				v.vertex.xyz += v.normal * disp.r * _Amount * time;
			}

			void surf (Input IN, inout SurfaceOutput o) {
				// sampling the noise texture
				float3 noise = tex2D(_NoiseTex, IN.uv_NoiseTex);
				// n is the u value that will be used to sample the explosion ramp tex (which is why we clamp it to 0-1)
				// thus _RampOffset allows control over the overall color of the explosion, as well as the value of the sampled color
				float n = saturate(noise.r + _RampOffset);
				// clips the darker parts of the explosion (those that sampled the rightmost parts of the texture) according to _ClipRange
				clip(_ClipRange - n);
				// sampling the color, the more the noise color is white and _RampOffset is high, the higher n is, the more offset to the right the color will be
				half4 c = tex2D(_RampTex, float2(n, 0.5));
				o.Albedo = c.rgb;
				o.Alpha = c.a;
			}
			ENDCG
		}
	FallBack "Diffuse"
}
