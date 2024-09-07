Shader "_MX/MX_C-Body"
{
    Properties
    {
        [Header(Textures)]
        [NoScaleOffset]_MainTex     ("Base", 2D)                        = "white" {}
        [NoScaleOffset]_MaskTex     ("Mask", 2D)                        = "black" {}

        [Header(Colors)]
        _Tint                       ("Tint", Color)                     = (0.9528302, 0.9349014, 0.7685564, 1)
        _ShadowTint                 ("ShadowTint", Color)               = (0.8490566, 0.7651243, 0.6928622, 1)
        _ShadowThreshold            ("ShadowThreshold", Float)          = 0.4
        _LightSharpness             ("LightSharpness", Float)           = 0.03
        
        [Header(Rim Light)]
        _RimAreaMultiplier          ("RimAreaMultiplier", Float)        = 10
        _RimStrength                ("RimStrength", Float)              = 1
        _RimLight_Color             ("RimLight Color", Color)           = (0.5, 0.5, 0.5, 0)
        
        [Header(Adjust Color)]
        _GrayBrightness             ("GrayBrightness", Float)           = 1
        _CodeMultiplyColor          ("CodeMultiplyColor", Color)        = (1, 1, 1, 0)
        _CodeAddColor               ("CodeAddColor", Color)             = (0, 0, 0, 0)
        _CodeAddRimColor            ("CodeAddRimColor", Color)          = (0, 0, 0, 0)
        _DitherThreshold            ("DitherThreshold", Float)          = 0
        
        [Header(Outline)]
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

            TEXTURE2D(_MainTex); 
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_MaskTex);
            SAMPLER(sampler_MaskTex);

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
                float4 albedo = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
                float4 maskSample = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, input.uv);

                // 음영 계산
                float3 mainLightDir = mainLight.direction;
                float3 mainLightColor = mainLight.color;
                float3 mainLightAttenuation = mainLight.shadowAttenuation * mainLight.distanceAttenuation;
                mainLightColor = mainLightColor * mainLightAttenuation;
                float dotResult = dot(mainLightDir, input.normalWS.xyz);
                // 디테일 마스크 적용 G: 오클루전
                dotResult = dotResult - (maskSample.g) * (maskSample.a);
                float brightness = smoothstep(_ShadowThreshold, _ShadowThreshold + _LightSharpness, (dotResult + 1) * 0.5);

                // Specular 계산
                float3 halfVector = normalize(mainLightDir + input.viewDirWS);
                float spec = saturate(dot(halfVector, input.normalWS.xyz));
                spec = pow(spec, 10);
                // 디테일 마스크 적용 R: 메탈릭
                spec = spec * maskSample.r;
                // albedo = lerp(albedo, (mainLightColor, 1), maskSample.r * 0.1);
                //albedo = albedo * (1- maskSample.r);

                // 틴트 적용
                float4 shadeTint = brightness * _Tint + abs(1-brightness) * _ShadowTint;
                float4 tintedAlbedo = float4(mainLightColor.xyz, 1) * albedo * shadeTint;

                // 코드로 색상 조정 1
                float4 adjustedAlbedo = tintedAlbedo * _CodeMultiplyColor + _CodeAddColor;

                // 림라이팅
                float rim_base = pow((1.0 - saturate(dot(normalize(input.normalWS.xyz), normalize(input.viewDirWS)))), _RimAreaMultiplier);
                float4 rimlight = rim_base * _RimLight_Color * _RimStrength;
                // 디테일 마스크 적용 B: 림라이팅?
                rimlight = rimlight * (1 - maskSample.b);

                // 코드로 색상 조정 2
                rimlight = rimlight * (1 + _CodeAddRimColor);
            
                // 최종 색상 조정 (_GrayBrightness)
                float4 finalColor = (adjustedAlbedo + rimlight + spec) * _GrayBrightness;

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
                float4 color : COLOR;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos          : SV_POSITION;
            };
            
            float _OutlineWidth;
            float _DitherThreshold;
            float4 _OutlineColor;
            float _OutlineZCorrection;
            
            v2f vert(appdata v)
            {
                v2f o;
                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);

                // 카메라와의 거리에 따라 외곽선 두께 조정
                float3 viewDirWS = GetCameraPositionWS() - vertexInput.positionWS;

                // vertex color에 저장된 외곽선 정보 적용
                float outlineOffset = v.color.a * _OutlineWidth * 0.1 * length(viewDirWS);

                // 외곽선 최대 두께 설정
                outlineOffset = min(outlineOffset, _OutlineWidth * 0.1);

                o.pos = TransformObjectToHClip(float3(v.vertex.xyz + v.normal * outlineOffset ) + _OutlineZCorrection);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                // 디더링
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
