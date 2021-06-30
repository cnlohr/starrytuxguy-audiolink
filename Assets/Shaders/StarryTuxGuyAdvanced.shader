Shader "Custom/StarryTuxGuyAdvanced"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _FunctionTex ("Function", 2D) = "white" {}
        _NormalTex ("Normal", 2D) = "white" {}
        _DiffuseTex ("Diffuse", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
		Tags { "RenderQueue"="AlphaTest" "RenderType"="TransparentCutout" }
	   
		AlphaToMask On
		
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows vertex:vert keepalpha

        #pragma target 4.0

		#include "/Assets/AudioLink/Shaders/AudioLink.cginc"

        sampler2D _FunctionTex;
        sampler2D _NormalTex;
        sampler2D _DiffuseTex;
		float4 _FunctionTex_TexelSize;
		float4 _NormalTex_TexelSize;
		float4 _DiffuseTex_TexelSize;


        struct Input
        {
            float4 screenPos:SV_POSITION;
            float2 uv_FunctionTex;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

 
		void vert (inout appdata_full v, out Input o) {
			UNITY_INITIALIZE_OUTPUT(Input,o);
			o.screenPos = ComputeScreenPos( UnityObjectToClipPos( v.vertex ) );
		}
 
        void surf (Input IN, inout SurfaceOutputStandard o )
        {
            // Albedo comes from a texture tinted by color
			fixed4 diffuse = tex2D (_DiffuseTex, IN.uv_FunctionTex);
            fixed4 function = tex2D (_FunctionTex, IN.uv_FunctionTex);
			fixed4 normal = tex2D (_NormalTex, IN.uv_FunctionTex);
			
			diffuse *= _Color;

            o.Metallic = _Metallic;

            o.Albedo = diffuse.rgb;

			if( length( function.xyz ) > 1.7 )
			{
				// Shiny.
				o.Normal = normal;
				o.Metallic = 1.;
				o.Albedo = .1;
			}
			else if( function.b > function.r && function.b > function.g && function.b > 0.5 )
			{
				//Emissive.
				o.Emission = diffuse;
			}
			else if( function.r > function.g && function.r > 0.5)
			{
				// ColorChord, Linear
				o.Emission = AudioLinkLerp( ALPASS_CCSTRIP + float2( normal.x, 0 ) * 128 );
				o.Albedo = o.Emission;
			}
			else if( function.g > function.r && function.g > 0.5 )
			{
				// AudioLink, Scan
				o.Emission = AudioLinkLerp( ALPASS_AUDIOLINK + float2( normal.x, 0 ) * 128 );
				o.Albedo = o.Emission;
			}
			
            // Metallic and smoothness come from slider variables
            o.Smoothness = _Glossiness;
            o.Alpha = diffuse.a;

        }
        ENDCG
    }
    FallBack "Diffuse"
}
