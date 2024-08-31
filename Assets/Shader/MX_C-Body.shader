Shader "_MX/MX_C-Body"
{
    Properties
    {
        [NoScaleOffset]Tex_Base     ("Base", 2D)                        = "white" {}
        [NoScaleOffset]Tex_normal   ("Normal", 2D)                      = "white" {}
        [NoScaleOffset]Tex_mask     ("Mask", 2D)                        = "white" {}
        _Tint                       ("Tint", Color)                     = (0.9528302, 0.9349014, 0.7685564, 0)
        _ShadowTint                 ("ShadowTint", Color)               = (0.1603774, 0.1603774, 0.1603774, 0)
        _ShadowThreshold            ("ShadowThreshold", Float)          = 0.4
        _LightSharpness             ("LightSharpness", Float)           = 0.06
        _RimAreaMultiplier          ("RimAreaMultiplier", Float)        = 3
        _RimStrength                ("RimStrength", Float)              = 1
        _RimLight_Color             ("RimLight Color", Color)           = (0.9245283, 0.9245283, 0.9245283, 0)
        _GrayBrightness             ("GrayBrightness", Float)           = 1
        _CodeMultiplyColor          ("CodeMultiplyColor", Color)        = (1, 1, 1, 0)
        _CodeAddColor               ("CodeAddColor", Color)             = (0, 0, 0, 0)
        _CodeAddRimColor            ("CodeAddRimColor", Color)          = (0, 0, 0, 0)
        _DitherThreshold            ("DitherThreshold", Float)          = 0
        _OutlineWidth               ("OutlineWidth", Range(0.0, 1.0))   = 0.05
        _OutlineColor               ("OutlineColor", Color)             = (0.0, 0.0, 0.0, 1)

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

            SAMPLER(samplerTex_Base);
            TEXTURE2D(Tex_Base); 
            SAMPLER(samplerTex_Normal);
            TEXTURE2D(Tex_normal);
            SAMPLER(samplerTex_Mask);
            TEXTURE2D(Tex_mask);

            CBUFFER_START(UnityPerMaterial)
                float4 _Tint;
                float4 _ShadowTint;
                float _ShadowThreshold;
                float _LightSharpness;
                float _RimAreaMultiplier;
                float _RimStrength;
                float4 _RimLight_Color;
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
                //UnityTexture2D mainTex2D = UnityBuildTexture2DStructNoScale(Tex_Base);
                float4 albedo = SAMPLE_TEXTURE2D(Tex_Base, samplerTex_Base, input.uv);
                //UnityTexture2D normalTex2D = UnityBuildTexture2DStructNoScale(Tex_normal);
                float4 normalSample = SAMPLE_TEXTURE2D(Tex_normal, samplerTex_Normal, input.uv);
                //UnityTexture2D maskTex2D = UnityBuildTexture2DStructNoScale(Tex_mask);
                float4 maskSample = SAMPLE_TEXTURE2D(Tex_mask, samplerTex_Normal, input.uv);

                // 음영 계산
                // float3 mainLightDir, mainLightColor;
                // MainLight_float(mainLightDir, mainLightColor);
                float3 mainLightDir = mainLight.direction;
                float3 mainLightColor = mainLight.color;
                float3 mainLightAttenuation = mainLight.shadowAttenuation * mainLight.distanceAttenuation;
                mainLightColor = mainLightColor * mainLightAttenuation;
                float dotResult = dot(mainLightDir, input.normalWS.xyz);
                float brightness = smoothstep(_ShadowThreshold, _ShadowThreshold + _LightSharpness, (dotResult + 1) * 0.5);

                // 틴트 적용
                float4 shadeTint = brightness * _Tint + abs(1-brightness) * _ShadowTint;
                float4 tintedAlbedo = float4(mainLightColor.xyz, 1) * albedo * shadeTint;
                // float4 tintedAlbedo = (brightness, brightness, brightness, 1) * albedo * shadeTint;
                //float4 tintedAlbedo = albedo * shadeTint;

                // 코드로 색상 조정 1
                float4 adjustedAlbedo = tintedAlbedo * _CodeMultiplyColor + _CodeAddColor;

                // 림라이팅
                float rim_base = pow((1.0 - saturate(dot(normalize(input.normalWS.xyz), normalize(input.viewDirWS)))), _RimAreaMultiplier);
                float4 rimlight = rim_base * _RimLight_Color * _RimStrength;

                // 코드로 색상 조정 2
                rimlight = rimlight * _CodeAddRimColor;
            
                // 최종 색상 조정 (_GrayBrightness)
                float4 finalColor = (adjustedAlbedo + rimlight) * _GrayBrightness;

                // #if _ALPHATEST_ON
                //     half alpha = surfaceDescription.Alpha;
                //     clip(alpha - surfaceDescription.AlphaClipThreshold);
                // #elif _SURFACE_TYPE_TRANSPARENT
                //     half alpha = surfaceDescription.Alpha;
                // #else
                //     half alpha = 1;
                // #endif

                // 디더링
                float4 screenPos = input.ScreenPos;
                float pesudoRandom = frac(sin(screenPos.y / screenPos.w) * 43758) + 0.01;
                clip(pesudoRandom - _DitherThreshold);
            
                return finalColor;
            }
            ENDHLSL
        }
        
        //Outline
        Pass
        {
            Name "Outline"
            Cull Front
            Tags
            {
                "LightMode" = "SRPDefaultUnlit"
            }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _ALPHATEST_ON
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos          : SV_POSITION;
            };
            
            float _OutlineWidth;
            float _DitherThreshold;
            float4 _OutlineColor;
            
            v2f vert(appdata v)
            {
                v2f o;
                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
                o.pos = TransformObjectToHClip(float3(v.vertex.xyz + v.normal * _OutlineWidth * 0.1));

                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float4 screenPos = i.pos;
                float pesudoRandom = frac(sin(screenPos.y / screenPos.w) * 43758) + 0.01;
                clip(pesudoRandom - _DitherThreshold);

                return _OutlineColor;
            }
            
            ENDHLSL
        }
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
    }
}
