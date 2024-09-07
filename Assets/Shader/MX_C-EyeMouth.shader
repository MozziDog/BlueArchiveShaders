Shader "_MX/MX_C-EyeMouth"
{
    Properties
    {
        [Header(Textures)]
        [NoScaleOffset]_MainTex     ("Base", 2D)                        = "white" {}
        [NoScaleOffset]_MouthTex    ("Mouth", 2D)                       = "black" {}
        [NoScaleOffset]_MouthMaskTex("Mouth Mask", 2D)                  = "White" {}

        [Header(Colors)]
        _Tint                       ("Tint", Color)                     = (0.9528302, 0.9349014, 0.7685564, 1)
        // _AdjustiveFaceShadow        ("Apply Mask R", Range(0, 1))       = 0

        [Header(Mouth)]
        [IntRange]_MouthRow         ("Mouth Row", Range(1,8))           = 0
        [IntRange]_MouthCol         ("Mouth Column", Range(1,8))        = 0
        _MouthOffsetX               ("Mouth Offset X", Range(0,1))      = 0
        _MouthOffsetY               ("Mouth Offset Y", Range(0,1))      = 0

        [Header(Adjust Color)]
        _GrayBrightness             ("GrayBrightness", Float)           = 1
        _CodeMultiplyColor          ("CodeMultiplyColor", Color)        = (1, 1, 1, 0)
        _CodeAddColor               ("CodeAddColor", Color)             = (0, 0, 0, 0)
        _CodeAddRimColor            ("CodeAddRimColor", Color)          = (0, 0, 0, 0)
        _DitherThreshold            ("DitherThreshold", Float)          = 0

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

            TEXTURE2D(_MainTex); 
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_MouthTex);
            SAMPLER(sampler_MouthTex);
            TEXTURE2D(_MouthMaskTex);
            SAMPLER(sampler_MouthMaskTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _Tint;
                float _MouthRow;
                float _MouthCol;
                float _MouthOffsetX;
                float _MouthOffsetY;
                float _GrayBrightness;
                float4 _CodeMultiplyColor;
                float4 _CodeAddColor;
                float4 _CodeAddRimColor;
                float _DitherThreshold;
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
                float4 normalWS      : TEXCOORD1;    // xyz: normal, w: viewDir.x
                float4 tangentWS     : TEXCOORD2;    // xyz: tangent, w: viewDir.y
                float4 bitangentWS   : TEXCOORD3;    // xyz: bitangent, w: viewDir.z
                float3 viewDirWS     : TEXCOORD4;
				float4 shadowCoord	 : TEXCOORD5;	// shadow receive 
				float4 fogCoord	     : TEXCOORD6;	
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
                VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
                float3 viewDirWS = GetCameraPositionWS() - vertexInput.positionWS;
                float3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);

                output.positionWS = vertexInput.positionWS;
                output.positionCS = vertexInput.positionCS;
                output.ScreenPos = ComputeScreenPos(TransformWorldToHClip(output.positionWS));
                output.uv = input.uv;
                output.normalWS = float4(normalInput.normalWS, viewDirWS.x);
                output.tangentWS = float4(normalInput.tangentWS, viewDirWS.y);
                output.bitangentWS = float4(normalInput.bitangentWS, viewDirWS.z);
                output.viewDirWS = viewDirWS;
                return output;
            }
            
            half remap(half x, half t1, half t2, half s1, half s2)
            {
                return (x - t1) / (t2 - t1) * (s2 - s1) + s1;
            }
            
            float4 frag(Varyings input) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(input);

                // 메인라이트 가져오기
                Light mainLight = GetMainLight();
                float3 color = mainLight.color;
                color = mainLight.distanceAttenuation * mainLight.shadowAttenuation;

                // 텍스쳐 샘플링
                float4 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
                float2 mouthCellPos = (float2(( ceil( ( _MouthCol - 1.0 ) ) * 0.125 ) , ( ceil( ( _MouthRow - 9.0 ) ) * 0.125 )));
                float2 mouthUV = input.uv - float2(_MouthOffsetX, _MouthOffsetY);
                float4 mouthTexColor = SAMPLE_TEXTURE2D(_MouthTex, sampler_MouthTex, mouthUV * 0.5 + mouthCellPos);
                float mouthMask = SAMPLE_TEXTURE2D(_MouthMaskTex, sampler_MouthMaskTex, input.uv).r;

                // 입과 나머지 텍스쳐 합체
                float4 faceMouthBlendedColor = lerp( albedo , mouthTexColor , mouthMask);

                // 틴트 적용
                float3 mainLightColor = mainLight.color;
                float4 tintedAlbedo = float4(mainLightColor.xyz, 1) * faceMouthBlendedColor * _Tint;

                // 코드로 색상 조정 1
                float4 adjustedAlbedo = tintedAlbedo * _CodeMultiplyColor + _CodeAddColor;
            
                // 최종 색상 조정 (_GrayBrightness)
                float4 finalColor = (adjustedAlbedo) * _GrayBrightness;

                // 디더링
                float4 screenPos = input.ScreenPos;
                float pesudoRandom = frac(sin(screenPos.y / screenPos.w) * 43758) + 0.01;
                clip(pesudoRandom - _DitherThreshold);

                // 입가 클리핑
                // float mouthBlend = ( mouthMask * mouthTexColor.a );
                float cutoutVal = saturate( 1.0 - mouthMask + mouthTexColor.a );
                clip(cutoutVal - 0.5f);
            
                return finalColor;
            }
            ENDHLSL
        }
        
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
    }
}
