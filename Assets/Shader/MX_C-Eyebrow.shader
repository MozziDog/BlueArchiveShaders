Shader "_MX/MX_C-Eyebrow"
{
    Properties
    {
        [Header(Colors)]
        _Tint                       ("Tint", Color)                     = (0.9528302, 0.9349014, 0.7685564, 1)

        [Header(Adjust Color)]
        _GrayBrightness             ("GrayBrightness", Float)           = 1
        _CodeMultiplyColor          ("CodeMultiplyColor", Color)        = (1, 1, 1, 0)
        _CodeAddColor               ("CodeAddColor", Color)             = (0, 0, 0, 0)
        _CodeAddRimColor            ("CodeAddRimColor", Color)          = (0, 0, 0, 0)
        _DitherThreshold            ("DitherThreshold", Range(0, 1))          = 0

        _Zcorrection                ("ZbufferCorrection", Range(0, 1))  = 0.1

        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags { 
            "RenderPipeline" = "UniversalPipeline" 
            "RenderType" = "Opaque" 
        }
        
        Pass
        {
            Name "UniversalForward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
            Cull Back
            // ZTest Always
            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x

            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _ALPHATEST_ON
            // #pragma shader_feature _ALPHAPREMULTIPLY_ON
            // #pragma multi_compile _ _SHADOWS_SOFT
            // #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            // -------------------------------------
            // Unity defined keywords
            // #pragma multi_compile_fog
            #pragma multi_compile_instancing
             
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4 _Tint;
                float _GrayBrightness;
                float4 _CodeMultiplyColor;
                float4 _CodeAddColor;
                float4 _CodeAddRimColor;
                float _DitherThreshold;
                float _Zcorrection;
            CBUFFER_END

            struct Attributes
            {     
                float4 positionOS   : POSITION;
                float3 normalOS     : NORMAL;
                float4 tangentOS    : TANGENT;
                float2 uv           : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            }; 

            struct Varyings
            {
                float2 uv            : TEXCOORD0;
				float3 positionWS	 : TEXCOORD7;	
                float4 ScreenPos     : TEXCOORD8;
                float4 positionCS    : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            Varyings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                    
                UNITY_SETUP_INSTANCE_ID(input);
                UNITY_TRANSFER_INSTANCE_ID(input, output);

                VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

                output.positionWS = vertexInput.positionWS;
                output.positionCS = vertexInput.positionCS;
                output.positionCS.z += _Zcorrection;
                output.ScreenPos = ComputeScreenPos(TransformWorldToHClip(output.positionWS));
                output.uv = input.uv;
                return output;
            }
            
            float4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);
                
                // 텍스쳐 없이 틴트 값을 그대로 색상으로 사용
                // 코드로 색상 조정 1
                float4 baseColor = _Tint * _CodeMultiplyColor + _CodeAddColor;
            
                // 최종 색상 조정 (_GrayBrightness)
                float4 finalColor = baseColor * _GrayBrightness;

                // 디더링
                float4 screenPos = input.ScreenPos;
                float pesudoRandom = frac(sin(screenPos.y / screenPos.w) * 43758) + 0.01;
                clip(pesudoRandom - _DitherThreshold);
            
                return finalColor;
            }
            ENDHLSL
        }
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
    }
}
