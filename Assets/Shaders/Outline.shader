Shader "Custom/URP/OutlineOnlyAlways"
{
    Properties
    {
        _OutlineColor ("Outline Color", Color) = (1,0.5,0,1)
        _OutlineWidth ("Outline Width (World Units)", Float) = 0.08
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline"="UniversalRenderPipeline"
            "RenderType"="Transparent"
            "Queue"="Transparent+50"
        }

        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

        CBUFFER_START(UnityPerMaterial)
            float4 _OutlineColor;
            float  _OutlineWidth;
        CBUFFER_END

        struct Attributes
        {
            float3 positionOS : POSITION;
            float3 normalOS   : NORMAL;
        };

        struct Varyings
        {
            float4 positionHCS : SV_POSITION;
        };

        Varyings Vert(Attributes IN)
        {
            Varyings OUT;

            float3 posWS  = TransformObjectToWorld(IN.positionOS);
            float3 normWS = normalize(TransformObjectToWorldNormal(IN.normalOS));

            posWS += normWS * _OutlineWidth;

            OUT.positionHCS = TransformWorldToHClip(posWS);
            return OUT;
        }

        half4 Frag(Varyings IN) : SV_Target
        {
            return half4(_OutlineColor.rgb, _OutlineColor.a);
        }
        ENDHLSL

        Pass
        {
            Name "OutlineOnly"
            Tags { "LightMode"="SRPDefaultUnlit" }

            Cull Off
            ZWrite Off
            ZTest Always
            Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            ENDHLSL
        }
    }
}
