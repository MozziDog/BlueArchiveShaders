Shader "MX/MX_C-Body"
{
    Properties
    {
        [NoScaleOffset]Tex_Base("Base", 2D) = "white" {}
        [NoScaleOffset]Tex_normal("Normal", 2D) = "white" {}
        [NoScaleOffset]Tex_mask("Mask", 2D) = "white" {}
        _Tint("Tint", Color) = (0.9528302, 0.9349014, 0.7685564, 0)
        _ShadowTint("ShadowTint", Color) = (0.1603774, 0.1603774, 0.1603774, 0)
        _ShadowThreshold("ShadowThreshold", Float) = 0.4
        _LightSharpness("LightSharpness", Float) = 0.1
        _RimAreaMultiplier("RimAreaMultiplier", Float) = 3
        _RimStrength("RimStrength", Float) = 1
        _RimLight_Color("RimLight Color", Color) = (0.9245283, 0.9245283, 0.9245283, 0)
        _GrayBrightness("GrayBrightness", Float) = 1
        _CodeMultiplyColor("CodeMultiplyColor", Color) = (1, 1, 1, 0)
        _CodeAddColor("CodeAddColor", Color) = (0, 0, 0, 0)
        _CodeAddRimColor("CodeAddRimColor", Color) = (0, 0, 0, 0)
        _DitherThreshold("DitherThreshold", Float) = 0.1
        [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
    }
    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "UniversalMaterialType" = "Lit"
            "Queue"="AlphaTest"
            "ShaderGraphShader"="true"
            "ShaderGraphTargetId"="UniversalLitSubTarget"
        }
        Pass
        {
            Name "Universal Forward"
            Tags
            {
                "LightMode" = "UniversalForward"
            }
        
            // Render State
            Cull Back
            Blend One Zero
            ZTest LEqual
            ZWrite On
        
            // Debug
            // <None>
        
            // --------------------------------------------------
            // Pass
        
            HLSLPROGRAM
        
            // Pragmas
            #pragma target 4.5
            #pragma exclude_renderers gles gles3 glcore
            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON
            #pragma vertex vert
            #pragma fragment frag
        
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
        
            // Keywords
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DYNAMICLIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ _LIGHT_LAYERS
            #pragma multi_compile_fragment _ DEBUG_DISPLAY
            #pragma multi_compile_fragment _ _LIGHT_COOKIES
            #pragma multi_compile _ _CLUSTERED_RENDERING
            // GraphKeywords: <None>
        
            // Defines
        
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define ATTRIBUTES_NEED_TEXCOORD2
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
            #define VARYINGS_NEED_SHADOW_COORD
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_FORWARD
            #define _FOG_FRAGMENT 1
            #define _ALPHATEST_ON 1
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            //추가
            #define MAIN_LIGHT_CALCULATE_SHADOWS
        
        
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
            // --------------------------------------------------
            // Structs and Packing
        
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
            struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv0 : TEXCOORD0;
                 float4 uv1 : TEXCOORD1;
                 float4 uv2 : TEXCOORD2;
                 #if UNITY_ANY_INSTANCING_ENABLED
                  uint instanceID : INSTANCEID_SEMANTIC;
                 #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                 float3 positionWS;
                 float3 normalWS;
                 float4 tangentWS;
                 float4 texCoord0;
                 float3 viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                     float2 staticLightmapUV;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                     float2 dynamicLightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                     float3 sh;
                    #endif
                     float4 fogFactorAndVertexLight;
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                     float4 shadowCoord;
                    #endif
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
            };
            struct SurfaceDescriptionInputs
            {
                 float3 WorldSpaceNormal;
                 float3 TangentSpaceNormal;
                 float3 WorldSpaceViewDirection;
                 float3 WorldSpacePosition;
                 float4 ScreenPosition;
                 float4 uv0;
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 ObjectSpacePosition;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                    #if defined(LIGHTMAP_ON)
                     float2 staticLightmapUV : INTERP0;
                    #endif
                    #if defined(DYNAMICLIGHTMAP_ON)
                     float2 dynamicLightmapUV : INTERP1;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                     float3 sh : INTERP2;
                    #endif
                    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                     float4 shadowCoord : INTERP3;
                    #endif
                     float4 tangentWS : INTERP4;
                     float4 texCoord0 : INTERP5;
                     float4 fogFactorAndVertexLight : INTERP6;
                     float3 positionWS : INTERP7;
                     float3 normalWS : INTERP8;
                     float3 viewDirectionWS : INTERP9;
                    #if UNITY_ANY_INSTANCING_ENABLED
                     uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                     uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                     uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                     FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
            };
        
            PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                #if defined(LIGHTMAP_ON)
                output.staticLightmapUV = input.staticLightmapUV;
                #endif
                #if defined(DYNAMICLIGHTMAP_ON)
                output.dynamicLightmapUV = input.dynamicLightmapUV;
                #endif
                #if !defined(LIGHTMAP_ON)
                output.sh = input.sh;
                #endif
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                output.shadowCoord = input.shadowCoord;
                #endif
                output.tangentWS.xyzw = input.tangentWS;
                output.texCoord0.xyzw = input.texCoord0;
                output.fogFactorAndVertexLight.xyzw = input.fogFactorAndVertexLight;
                output.positionWS.xyz = input.positionWS;
                output.normalWS.xyz = input.normalWS;
                output.viewDirectionWS.xyz = input.viewDirectionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
        
            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                #if defined(LIGHTMAP_ON)
                output.staticLightmapUV = input.staticLightmapUV;
                #endif
                #if defined(DYNAMICLIGHTMAP_ON)
                output.dynamicLightmapUV = input.dynamicLightmapUV;
                #endif
                #if !defined(LIGHTMAP_ON)
                output.sh = input.sh;
                #endif
                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                output.shadowCoord = input.shadowCoord;
                #endif
                output.tangentWS = input.tangentWS.xyzw;
                output.texCoord0 = input.texCoord0.xyzw;
                output.fogFactorAndVertexLight = input.fogFactorAndVertexLight.xyzw;
                output.positionWS = input.positionWS.xyz;
                output.normalWS = input.normalWS.xyz;
                output.viewDirectionWS = input.viewDirectionWS.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
        
        
            // --------------------------------------------------
            // Graph
        
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 Tex_Base_TexelSize;
            float4 Tex_normal_TexelSize;
            float4 Tex_mask_TexelSize;
            float4 _Tint;
            float4 _ShadowTint;
            float _RimAreaMultiplier;
            float4 _RimLight_Color;
            float _ShadowThreshold;
            float _RimStrength;
            float _LightSharpness;
            float _GrayBrightness;
            float4 _CodeMultiplyColor;
            float4 _CodeAddColor;
            float4 _CodeAddRimColor;
            float _DitherThreshold;
            CBUFFER_END
        
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(Tex_Base);
            SAMPLER(samplerTex_Base);
            TEXTURE2D(Tex_normal);
            SAMPLER(samplerTex_normal);
            TEXTURE2D(Tex_mask);
            SAMPLER(samplerTex_mask);
        
            // Graph Includes
            // GraphIncludes: <None>
        
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
        
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
        
            // Graph Functions

        
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };
        
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
        
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
        
            // Graph Pixel
            struct SurfaceDescription
            {
                float3 BaseColor;
                float3 NormalTS;
                float3 Emission;
                float Metallic;
                float Smoothness;
                float Occlusion;
                float Alpha;
                float AlphaClipThreshold;
            };
        
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
                output.ObjectSpaceNormal =                          input.normalOS;
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.ObjectSpacePosition =                        input.positionOS;
        
                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
                #ifdef HAVE_VFX_MODIFICATION
                    // FragInputs from VFX come from two places: Interpolator or CBuffer.
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                #endif
        
            
        
                // must use interpolated tangent, bitangent and normal before they are normalized in the pixel shader.
                float3 unnormalizedNormalWS = input.normalWS;
                const float renormFactor = 1.0 / length(unnormalizedNormalWS);
        
        
                output.WorldSpaceNormal = renormFactor * input.normalWS.xyz;      // we want a unit length Normal Vector node in shader graph
                output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);
        
        
                output.WorldSpaceViewDirection = normalize(input.viewDirectionWS);
                output.WorldSpacePosition = input.positionWS;
                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                output.uv0 = input.texCoord0;
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                    return output;
            }
        
            // --------------------------------------------------
            // Main
        
            // #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        
            void InitializeInputData(Varyings input, SurfaceDescription surfaceDescription, out InputData inputData)
            {
                inputData = (InputData)0;

                #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                    inputData.shadowCoord = input.shadowCoord;
                #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
                    inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
                #else
                    inputData.shadowCoord = float4(0, 0, 0, 0);
                #endif

                inputData.fogCoord = InitializeInputDataFog(float4(input.positionWS, 1.0), input.fogFactorAndVertexLight.x);
                inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
                #if defined(DYNAMICLIGHTMAP_ON)
                    inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.dynamicLightmapUV.xy, input.sh, inputData.normalWS);
                #else
                    inputData.bakedGI = SAMPLE_GI(input.staticLightmapUV, input.sh, inputData.normalWS);
                #endif
                inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
                inputData.shadowMask = SAMPLE_SHADOWMASK(input.staticLightmapUV);

                #if defined(DEBUG_DISPLAY)
                #if defined(DYNAMICLIGHTMAP_ON)
                inputData.dynamicLightmapUV = input.dynamicLightmapUV.xy;
                #endif
                #if defined(LIGHTMAP_ON)
                inputData.staticLightmapUV = input.staticLightmapUV;
                #else
                inputData.vertexSH = input.sh;
                #endif
                #endif
            }

            #if defined(FEATURES_GRAPH_VERTEX)
            #if defined(HAVE_VFX_MODIFICATION)
            VertexDescription BuildVertexDescription(Attributes input, AttributesElement element)
            {
                GraphProperties properties;
                ZERO_INITIALIZE(GraphProperties, properties);
                // Fetch the vertex graph properties for the particle instance.
                GetElementVertexProperties(element, properties);

                // Evaluate Vertex Graph
                VertexDescriptionInputs vertexDescriptionInputs = BuildVertexDescriptionInputs(input);
                VertexDescription vertexDescription = VertexDescriptionFunction(vertexDescriptionInputs, properties);
                return vertexDescription;
            }
            #else
            VertexDescription BuildVertexDescription(Attributes input)
            {
                // Evaluate Vertex Graph
                VertexDescriptionInputs vertexDescriptionInputs = BuildVertexDescriptionInputs(input);
                VertexDescription vertexDescription = VertexDescriptionFunction(vertexDescriptionInputs);
                return vertexDescription;
            }
            #endif
            #endif

            Varyings BuildVaryings(Attributes input)
            {
                Varyings output = (Varyings)0;

                UNITY_SETUP_INSTANCE_ID(input);

                    #if defined(HAVE_VFX_MODIFICATION)
                        AttributesElement element;
                        ZERO_INITIALIZE(AttributesElement, element);

                        if (!GetMeshAndElementIndex(input, element))
                            return output; // Culled index.

                        if (!GetInterpolatorAndElementData(output, element))
                            return output; // Dead particle.

                        SetupVFXMatrices(element, output);
                    #endif

                        UNITY_TRANSFER_INSTANCE_ID(input, output);
                        UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

                    #if defined(FEATURES_GRAPH_VERTEX)

                    #if defined(HAVE_VFX_MODIFICATION)
                        VertexDescription vertexDescription = BuildVertexDescription(input, element);
                    #else
                        VertexDescription vertexDescription = BuildVertexDescription(input);
                    #endif

                        #if defined(CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC)
                            CustomInterpolatorPassThroughFunc(output, vertexDescription);
                        #endif

                        // Assign modified vertex attributes
                        input.positionOS = vertexDescription.Position;
                        #if defined(VARYINGS_NEED_NORMAL_WS)
                            input.normalOS = vertexDescription.Normal;
                        #endif //FEATURES_GRAPH_NORMAL
                        #if defined(VARYINGS_NEED_TANGENT_WS)
                            input.tangentOS.xyz = vertexDescription.Tangent.xyz;
                        #endif //FEATURES GRAPH TANGENT
                    #endif //FEATURES_GRAPH_VERTEX

                        // TODO: Avoid path via VertexPositionInputs (Universal)
                        VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);

                        // Returns the camera relative position (if enabled)
                        float3 positionWS = TransformObjectToWorld(input.positionOS);

                    #ifdef ATTRIBUTES_NEED_NORMAL
                        float3 normalWS = TransformObjectToWorldNormal(input.normalOS);
                    #else
                        // Required to compile ApplyVertexModification that doesn't use normal.
                        float3 normalWS = float3(0.0, 0.0, 0.0);
                    #endif

                    #ifdef ATTRIBUTES_NEED_TANGENT
                        float4 tangentWS = float4(TransformObjectToWorldDir(input.tangentOS.xyz), input.tangentOS.w);
                    #endif

                        // TODO: Change to inline ifdef
                        // Do vertex modification in camera relative space (if enabled)
                    #if defined(HAVE_VERTEX_MODIFICATION)
                        ApplyVertexModification(input, normalWS, positionWS, _TimeParameters.xyz);
                    #endif

                    #ifdef VARYINGS_NEED_POSITION_WS
                        output.positionWS = positionWS;
                    #endif

                    #ifdef VARYINGS_NEED_NORMAL_WS
                        output.normalWS = normalWS;         // normalized in TransformObjectToWorldNormal()
                    #endif

                    #ifdef VARYINGS_NEED_TANGENT_WS
                        output.tangentWS = tangentWS;       // normalized in TransformObjectToWorldDir()
                    #endif

                    #if (SHADERPASS == SHADERPASS_SHADOWCASTER)
                        // Define shadow pass specific clip position for Universal
                        #if _CASTING_PUNCTUAL_LIGHT_SHADOW
                            float3 lightDirectionWS = normalize(_LightPosition - positionWS);
                        #else
                            float3 lightDirectionWS = _LightDirection;
                        #endif
                        output.positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, lightDirectionWS));
                        #if UNITY_REVERSED_Z
                            output.positionCS.z = min(output.positionCS.z, UNITY_NEAR_CLIP_VALUE);
                        #else
                            output.positionCS.z = max(output.positionCS.z, UNITY_NEAR_CLIP_VALUE);
                        #endif
                    #elif (SHADERPASS == SHADERPASS_META)
                        output.positionCS = UnityMetaVertexPosition(input.positionOS, input.uv1, input.uv2, unity_LightmapST, unity_DynamicLightmapST);
                    #else
                        output.positionCS = TransformWorldToHClip(positionWS);
                    #endif

                    #if defined(VARYINGS_NEED_TEXCOORD0) || defined(VARYINGS_DS_NEED_TEXCOORD0)
                        output.texCoord0 = input.uv0;
                    #endif
                    #ifdef EDITOR_VISUALIZATION
                        float2 VizUV = 0;
                        float4 LightCoord = 0;
                        UnityEditorVizData(input.positionOS, input.uv0, input.uv1, input.uv2, VizUV, LightCoord);
                    #endif
                    #if defined(VARYINGS_NEED_TEXCOORD1) || defined(VARYINGS_DS_NEED_TEXCOORD1)
                    #ifdef EDITOR_VISUALIZATION
                        output.texCoord1 = float4(VizUV, 0, 0);
                    #else
                        output.texCoord1 = input.uv1;
                    #endif
                    #endif
                    #if defined(VARYINGS_NEED_TEXCOORD2) || defined(VARYINGS_DS_NEED_TEXCOORD2)
                    #ifdef EDITOR_VISUALIZATION
                        output.texCoord2 = LightCoord;
                    #else
                        output.texCoord2 = input.uv2;
                    #endif
                    #endif
                    #if defined(VARYINGS_NEED_TEXCOORD3) || defined(VARYINGS_DS_NEED_TEXCOORD3)
                        output.texCoord3 = input.uv3;
                    #endif

                    #if defined(VARYINGS_NEED_COLOR) || defined(VARYINGS_DS_NEED_COLOR)
                        output.color = input.color;
                    #endif

                    #ifdef VARYINGS_NEED_VIEWDIRECTION_WS
                        // Need the unnormalized direction here as otherwise interpolation is incorrect.
                        // It is normalized after interpolation in the fragment shader.
                        output.viewDirectionWS = GetWorldSpaceViewDir(positionWS);
                    #endif

                    #ifdef VARYINGS_NEED_SCREENPOSITION
                        output.screenPosition = vertexInput.positionNDC;
                    #endif

                    #if (SHADERPASS == SHADERPASS_FORWARD) || (SHADERPASS == SHADERPASS_GBUFFER)
                        OUTPUT_LIGHTMAP_UV(input.uv1, unity_LightmapST, output.staticLightmapUV);
                    #if defined(DYNAMICLIGHTMAP_ON)
                        output.dynamicLightmapUV.xy = input.uv2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
                    #endif
                        OUTPUT_SH(normalWS, output.sh);
                    #endif

                    #ifdef VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                        half fogFactor = 0;
                    #if !defined(_FOG_FRAGMENT)
                            fogFactor = ComputeFogFactor(output.positionCS.z);
                    #endif
                        half3 vertexLight = VertexLighting(positionWS, normalWS);
                        output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
                    #endif

                    #if defined(VARYINGS_NEED_SHADOW_COORD) && defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                        output.shadowCoord = GetShadowCoord(vertexInput);
                    #endif

                return output;
            }

            PackedVaryings vert(Attributes input)
            {
                Varyings output = (Varyings)0;
                output = BuildVaryings(input);
                PackedVaryings packedOutput = (PackedVaryings)0;
                packedOutput = PackVaryings(output);
                return packedOutput;
            }

            half4 frag(PackedVaryings packedInput) : SV_TARGET
            {
                // vert로부터 전달받은 정보 언패킹
                Varyings unpacked = UnpackVaryings(packedInput);
                UNITY_SETUP_INSTANCE_ID(unpacked);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(unpacked);

                SurfaceDescriptionInputs v2f = BuildSurfaceDescriptionInputs(unpacked);

                // 메인라이트 가져오기
                InputData pbrInput;
                SurfaceDescription emptyDescription = (SurfaceDescription)0;
                InitializeInputData(unpacked, emptyDescription, pbrInput);
                half4 shadowMask = CalculateShadowMask(pbrInput);
                //AmbientOcclusionFactor aoFactor = CreateAmbientOcclusionFactor(pbrInput, surfaceData);
                // Light mainLight = GetMainLight(pbrInput, shadowMask, (AmbientOcclusionFactor)0);
                Light mainLight = GetMainLight();
                float3 color = mainLight.color;
                color = mainLight.distanceAttenuation * mainLight.shadowAttenuation;
                return (color.r, color.g, color.b, 1);

                // 텍스쳐 샘플링
                UnityTexture2D mainTex2D = UnityBuildTexture2DStructNoScale(Tex_Base);
                float4 albedo = SAMPLE_TEXTURE2D(mainTex2D.tex, mainTex2D.samplerstate, mainTex2D.GetTransformedUV(v2f.uv0.xy));
                UnityTexture2D normalTex2D = UnityBuildTexture2DStructNoScale(Tex_normal);
                float4 normalSample = SAMPLE_TEXTURE2D(normalTex2D.tex, normalTex2D.samplerstate, normalTex2D.GetTransformedUV(v2f.uv0.xy));
                UnityTexture2D maskTex2D = UnityBuildTexture2DStructNoScale(Tex_mask);
                float4 maskSample = SAMPLE_TEXTURE2D(maskTex2D.tex, maskTex2D.samplerstate, maskTex2D.GetTransformedUV(v2f.uv0.xy));

                // 음영 계산
                // float3 mainLightDir, mainLightColor;
                // MainLight_float(mainLightDir, mainLightColor);
                float3 mainLightDir = mainLight.direction;
                float3 mainLightColor = mainLight.color;
                float3 mainLightAttenuation = mainLight.shadowAttenuation * mainLight.distanceAttenuation;
                mainLightColor = mainLightColor * mainLightAttenuation;
                float dotResult = dot(mainLightDir, v2f.WorldSpaceNormal);
                float brightness = smoothstep(_ShadowThreshold, _ShadowThreshold + _LightSharpness, (dotResult + 1) * 0.5);


                // 틴트 적용
                float4 shadeTint = brightness * _Tint + abs(1-brightness) * _ShadowTint;
                float4 tintedAlbedo = (mainLightColor.xyz, 1) * albedo * shadeTint;
                // float4 tintedAlbedo = (brightness, brightness, brightness, 1) * albedo * shadeTint;
                //float4 tintedAlbedo = albedo * shadeTint;

                // 코드로 색상 조정 1
                float4 adjustedAlbedo = tintedAlbedo * _CodeMultiplyColor + _CodeAddColor;

                // 림라이팅
                float rim_base = pow((1.0 - saturate(dot(normalize(v2f.WorldSpaceNormal), normalize(v2f.WorldSpaceViewDirection)))), _RimAreaMultiplier);
                float4 rimlight = rim_base * _RimLight_Color * _RimStrength;

                // 코드로 색상 조정 2
                rimlight = rimlight * _CodeAddRimColor;
            
                // 최종 색상 조정 (GrayBrightness)
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
                float4 screenPos = v2f.ScreenPosition;
                float pesudoRandom = frac(sin(screenPos.y / screenPos.w) * 43758) + 0.01;
                clip(pesudoRandom - _DitherThreshold);
            
                return finalColor;
            }

        
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
        
            ENDHLSL
        }

        /// Shadow Caster
        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }
        
            // Render State
            Cull Back
            ZTest LEqual
            ZWrite On
            ColorMask 0
        
            // Debug
            // <None>
        
            // --------------------------------------------------
            // Pass
        
            HLSLPROGRAM
        
            // Pragmas
            #pragma target 4.5
            #pragma exclude_renderers gles gles3 glcore
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON
            #pragma vertex vert
            #pragma fragment frag
        
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
        
            // Keywords
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            // GraphKeywords: <None>
        
            // Defines
        
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
            #define _ALPHATEST_ON 1
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
            // --------------------------------------------------
            // Structs and Packing
        
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                #if UNITY_ANY_INSTANCING_ENABLED
                  uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS;
                float3 normalWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                  uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                  uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                  uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                  FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
                 float3 WorldSpacePosition;
                 float4 ScreenPosition;
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 ObjectSpacePosition;
            };
            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : INTERP0;
                float3 normalWS : INTERP1;
                #if UNITY_ANY_INSTANCING_ENABLED
                  uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                  uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                  uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                  FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
        
            PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                output.positionWS.xyz = input.positionWS;
                output.normalWS.xyz = input.normalWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                  output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                  output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                  output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                  output.cullFace = input.cullFace;
                #endif
                return output;
            }
        
            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.positionWS = input.positionWS.xyz;
                output.normalWS = input.normalWS.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                  output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                  output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                  output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                  output.cullFace = input.cullFace;
                #endif
                return output;
            }
        
        
            // --------------------------------------------------
            // Graph
        
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 Tex_Base_TexelSize;
            float4 Tex_normal_TexelSize;
            float4 Tex_mask_TexelSize;
            float4 _Tint;
            float4 _ShadowTint;
            float _RimAreaMultiplier;
            float4 _RimLight_Color;
            float _ShadowThreshold;
            float _RimStrength;
            float _LightSharpness;
            float _GrayBrightness;
            float4 _CodeMultiplyColor;
            float4 _CodeAddColor;
            float _DitherThreshold;
            CBUFFER_END
        
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(Tex_Base);
            SAMPLER(samplerTex_Base);
            TEXTURE2D(Tex_normal);
            SAMPLER(samplerTex_normal);
            TEXTURE2D(Tex_mask);
            SAMPLER(samplerTex_mask);
        
            // Graph Includes
            // GraphIncludes: <None>
        
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
        
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
        
            // Graph Functions
        
            void Unity_Sine_float(float In, out float Out)
            {
                Out = sin(In);
            }
        
            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
                Out = A * B;
            }
        
            void Unity_Fraction_float(float In, out float Out)
            {
                Out = frac(In);
            }
        
            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }
        
            void Unity_Comparison_Greater_float(float A, float B, out float Out)
            {
                Out = A > B ? 1 : 0;
            }
        
            void Unity_Branch_float(float Predicate, float True, float False, out float Out)
            {
                Out = Predicate ? True : False;
            }
        
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };
        
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
        
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
        
            // Graph Pixel
            struct SurfaceDescription
            {
                float Alpha;
                float AlphaClipThreshold;
            };
        
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float4 _ScreenPosition_86a0ae27e3ea45c1ab6ea19dbb939a2a_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                float _Split_1bab4bc6a1e044fa81b9570ac0abbef3_R_1 = _ScreenPosition_86a0ae27e3ea45c1ab6ea19dbb939a2a_Out_0[0];
                float _Split_1bab4bc6a1e044fa81b9570ac0abbef3_G_2 = _ScreenPosition_86a0ae27e3ea45c1ab6ea19dbb939a2a_Out_0[1];
                float _Split_1bab4bc6a1e044fa81b9570ac0abbef3_B_3 = _ScreenPosition_86a0ae27e3ea45c1ab6ea19dbb939a2a_Out_0[2];
                float _Split_1bab4bc6a1e044fa81b9570ac0abbef3_A_4 = _ScreenPosition_86a0ae27e3ea45c1ab6ea19dbb939a2a_Out_0[3];
                float _Sine_5691e7c61e0f41a8b2af41f951c30637_Out_1;
                Unity_Sine_float(_Split_1bab4bc6a1e044fa81b9570ac0abbef3_G_2, _Sine_5691e7c61e0f41a8b2af41f951c30637_Out_1);
                float _Multiply_6f5a2b90f41a45ea9bc6d1c802eb8402_Out_2;
                Unity_Multiply_float_float(_Sine_5691e7c61e0f41a8b2af41f951c30637_Out_1, 43758, _Multiply_6f5a2b90f41a45ea9bc6d1c802eb8402_Out_2);
                float _Fraction_9e9fdde9f29740848b8d44a850ce5bb1_Out_1;
                Unity_Fraction_float(_Multiply_6f5a2b90f41a45ea9bc6d1c802eb8402_Out_2, _Fraction_9e9fdde9f29740848b8d44a850ce5bb1_Out_1);
                float _Add_71aeb8dbb8024713bb99b6815fac3505_Out_2;
                Unity_Add_float(_Fraction_9e9fdde9f29740848b8d44a850ce5bb1_Out_1, float(0.01), _Add_71aeb8dbb8024713bb99b6815fac3505_Out_2);
                float _Property_a450f16c3014486abe1760bc5c02b006_Out_0 = _DitherThreshold;
                float _Comparison_5a3a6b93f8144181b2b404b4c0ac84ca_Out_2;
                Unity_Comparison_Greater_float(_Add_71aeb8dbb8024713bb99b6815fac3505_Out_2, _Property_a450f16c3014486abe1760bc5c02b006_Out_0, _Comparison_5a3a6b93f8144181b2b404b4c0ac84ca_Out_2);
                float _Branch_c903b8c6121540219803b0d8e1b25295_Out_3;
                Unity_Branch_float(_Comparison_5a3a6b93f8144181b2b404b4c0ac84ca_Out_2, float(1), float(0), _Branch_c903b8c6121540219803b0d8e1b25295_Out_3);
                surface.Alpha = _Branch_c903b8c6121540219803b0d8e1b25295_Out_3;
                surface.AlphaClipThreshold = float(0.5);
                return surface;
            }
        
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
                output.ObjectSpaceNormal =                          input.normalOS;
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.ObjectSpacePosition =                        input.positionOS;
        
                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
                #ifdef HAVE_VFX_MODIFICATION
                    // FragInputs from VFX come from two places: Interpolator or CBuffer.
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                #endif

                output.WorldSpacePosition = input.positionWS;
                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                  #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign = IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                  #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
            }
        
            // --------------------------------------------------
            // Main
        
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
        
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
        
            ENDHLSL
        }

        /// Depth Only
        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }
        
            // Render State
            Cull Back
            ZTest LEqual
            ZWrite On
            ColorMask 0
        
            // Debug
            // <None>
        
            // --------------------------------------------------
            // Pass
        
            HLSLPROGRAM
        
            // Pragmas
            #pragma target 4.5
            #pragma exclude_renderers gles gles3 glcore
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON
            #pragma vertex vert
            #pragma fragment frag
        
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
        
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
        
            // Defines
        
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            #define _ALPHATEST_ON 1
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
        
        
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
        
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
            // --------------------------------------------------
            // Structs and Packing
        
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
        
            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                #if UNITY_ANY_INSTANCING_ENABLED
                  uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                  uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                  uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                  uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                  FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
                float3 WorldSpacePosition;
                float4 ScreenPosition;
            };
            struct VertexDescriptionInputs
            {
                float3 ObjectSpaceNormal;
                float3 ObjectSpaceTangent;
                float3 ObjectSpacePosition;
            };
            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : INTERP0;
                #if UNITY_ANY_INSTANCING_ENABLED
                  uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                  uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                  uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                  FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
        
            PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                output.positionWS.xyz = input.positionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                  output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                  output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                  output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                  output.cullFace = input.cullFace;
                #endif
                return output;
            }
        
            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.positionWS = input.positionWS.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                  output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                  output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                  output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                  output.cullFace = input.cullFace;
                #endif
                return output;
            }
        
        
            // --------------------------------------------------
            // Graph
        
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 Tex_Base_TexelSize;
            float4 Tex_normal_TexelSize;
            float4 Tex_mask_TexelSize;
            float4 _Tint;
            float4 _ShadowTint;
            float _RimAreaMultiplier;
            float4 _RimLight_Color;
            float _ShadowThreshold;
            float _RimStrength;
            float _LightSharpness;
            float _GrayBrightness;
            float4 _CodeMultiplyColor;
            float4 _CodeAddColor;
            float _DitherThreshold;
            CBUFFER_END
        
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(Tex_Base);
            SAMPLER(samplerTex_Base);
            TEXTURE2D(Tex_normal);
            SAMPLER(samplerTex_normal);
            TEXTURE2D(Tex_mask);
            SAMPLER(samplerTex_mask);
        
            // Graph Includes
            // GraphIncludes: <None>
        
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
        
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
        
            // Graph Functions
        
            void Unity_Sine_float(float In, out float Out)
            {
                Out = sin(In);
            }
        
            void Unity_Multiply_float_float(float A, float B, out float Out)
            {
                Out = A * B;
            }
        
            void Unity_Fraction_float(float In, out float Out)
            {
                Out = frac(In);
            }
        
            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }
        
            void Unity_Comparison_Greater_float(float A, float B, out float Out)
            {
                Out = A > B ? 1 : 0;
            }
        
            void Unity_Branch_float(float Predicate, float True, float False, out float Out)
            {
                Out = Predicate ? True : False;
            }
        
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
        
            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };
        
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
        
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
              Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
              {
                  return output;
              }
              #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
        
            // Graph Pixel
            struct SurfaceDescription
            {
                float Alpha;
                float AlphaClipThreshold;
            };
        
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float4 _ScreenPosition_86a0ae27e3ea45c1ab6ea19dbb939a2a_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                float _Split_1bab4bc6a1e044fa81b9570ac0abbef3_R_1 = _ScreenPosition_86a0ae27e3ea45c1ab6ea19dbb939a2a_Out_0[0];
                float _Split_1bab4bc6a1e044fa81b9570ac0abbef3_G_2 = _ScreenPosition_86a0ae27e3ea45c1ab6ea19dbb939a2a_Out_0[1];
                float _Split_1bab4bc6a1e044fa81b9570ac0abbef3_B_3 = _ScreenPosition_86a0ae27e3ea45c1ab6ea19dbb939a2a_Out_0[2];
                float _Split_1bab4bc6a1e044fa81b9570ac0abbef3_A_4 = _ScreenPosition_86a0ae27e3ea45c1ab6ea19dbb939a2a_Out_0[3];
                float _Sine_5691e7c61e0f41a8b2af41f951c30637_Out_1;
                Unity_Sine_float(_Split_1bab4bc6a1e044fa81b9570ac0abbef3_G_2, _Sine_5691e7c61e0f41a8b2af41f951c30637_Out_1);
                float _Multiply_6f5a2b90f41a45ea9bc6d1c802eb8402_Out_2;
                Unity_Multiply_float_float(_Sine_5691e7c61e0f41a8b2af41f951c30637_Out_1, 43758, _Multiply_6f5a2b90f41a45ea9bc6d1c802eb8402_Out_2);
                float _Fraction_9e9fdde9f29740848b8d44a850ce5bb1_Out_1;
                Unity_Fraction_float(_Multiply_6f5a2b90f41a45ea9bc6d1c802eb8402_Out_2, _Fraction_9e9fdde9f29740848b8d44a850ce5bb1_Out_1);
                float _Add_71aeb8dbb8024713bb99b6815fac3505_Out_2;
                Unity_Add_float(_Fraction_9e9fdde9f29740848b8d44a850ce5bb1_Out_1, float(0.01), _Add_71aeb8dbb8024713bb99b6815fac3505_Out_2);
                float _Property_a450f16c3014486abe1760bc5c02b006_Out_0 = _DitherThreshold;
                float _Comparison_5a3a6b93f8144181b2b404b4c0ac84ca_Out_2;
                Unity_Comparison_Greater_float(_Add_71aeb8dbb8024713bb99b6815fac3505_Out_2, _Property_a450f16c3014486abe1760bc5c02b006_Out_0, _Comparison_5a3a6b93f8144181b2b404b4c0ac84ca_Out_2);
                float _Branch_c903b8c6121540219803b0d8e1b25295_Out_3;
                Unity_Branch_float(_Comparison_5a3a6b93f8144181b2b404b4c0ac84ca_Out_2, float(1), float(0), _Branch_c903b8c6121540219803b0d8e1b25295_Out_3);
                surface.Alpha = _Branch_c903b8c6121540219803b0d8e1b25295_Out_3;
                surface.AlphaClipThreshold = float(0.5);
                return surface;
            }
        
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
              #define VFX_SRP_ATTRIBUTES Attributes
              #define VFX_SRP_VARYINGS Varyings
              #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif

            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
        
                output.ObjectSpaceNormal =                          input.normalOS;
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.ObjectSpacePosition =                        input.positionOS;
        
                return output;
            }

            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
        
                #ifdef HAVE_VFX_MODIFICATION
                    // FragInputs from VFX come from two places: Interpolator or CBuffer.
                    /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
                #endif
        
                output.WorldSpacePosition = input.positionWS;
                output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                  #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                  #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        
                return output;
            }
        
            // --------------------------------------------------
            // Main
        
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
        
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
              #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
        
            ENDHLSL
        }
        
    }
    CustomEditorForRenderPipeline "UnityEditor.ShaderGraphLitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
    CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
    FallBack "Hidden/Shader Graph/FallbackError"
}