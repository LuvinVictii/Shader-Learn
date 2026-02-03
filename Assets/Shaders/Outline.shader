Shader "Custom/AlwaysVisibleOutline"
{
    Properties
    {
        _MainTex ("Albedo", 2D) = "white" {}
        _Color ("Base Color", Color) = (1,1,1,1)
        _OutlineColor ("Outline Color", Color) = (1,0.5,0,1)
        _OutlineWidth ("Outline Width", Float) = 0.03
        _HiddenBoost ("Hidden Outline Scale", Float) = 1.5
    }

    SubShader
    {
        // Draw after opaques so outline can sit on top / peek through occluders.
        Tags { "Queue"="Geometry+10" "RenderType"="Opaque" }
        LOD 100

        CGINCLUDE
        #include "UnityCG.cginc"

        struct appdataBase { float4 vertex:POSITION; float2 uv:TEXCOORD0; };
        struct v2fBase { float2 uv:TEXCOORD0; float4 pos:SV_POSITION; };

        struct appdataOutline { float4 vertex:POSITION; float3 normal:NORMAL; };
        struct v2fPos { float4 pos:SV_POSITION; };

        sampler2D _MainTex; float4 _MainTex_ST; float4 _Color;
        float _OutlineWidth; float _HiddenBoost; float4 _OutlineColor;

        v2fBase vertBase(appdataBase v)
        {
            v2fBase o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = TRANSFORM_TEX(v.uv, _MainTex);
            return o;
        }

        fixed4 fragBase(v2fBase i) : SV_Target
        {
            fixed4 col = tex2D(_MainTex, i.uv) * _Color;
            col.a = 1;
            return col;
        }

        v2fPos vertOutlineHidden(appdataOutline v)
        {
            float3 wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
            float3 wNorm = normalize(UnityObjectToWorldNormal(v.normal));
            wPos += wNorm * (_OutlineWidth * _HiddenBoost);
            v2fPos o; o.pos = UnityWorldToClipPos(wPos); return o;
        }

        v2fPos vertOutline(appdataOutline v)
        {
            float3 wPos = mul(unity_ObjectToWorld, v.vertex).xyz;
            float3 wNorm = normalize(UnityObjectToWorldNormal(v.normal));
            wPos += wNorm * _OutlineWidth;
            v2fPos o; o.pos = UnityWorldToClipPos(wPos); return o;
        }

        fixed4 fragOutline(v2fPos i) : SV_Target { return _OutlineColor; }

        ENDCG

        // Pass 1: base mesh (opaque)
        Pass
        {
            Cull Back
            ZWrite On
            ZTest LEqual
            Blend Off
            CGPROGRAM
            #pragma vertex vertBase
            #pragma fragment fragBase
            ENDCG
        }

        // Pass 2: outline when occluded (boosted size)
        Pass
        {
            ZWrite Off
            ZTest Greater
            Cull Front
            Offset -1,-1
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vertOutlineHidden
            #pragma fragment fragOutline
            ENDCG
        }

        // Pass 3: visible outline
        Pass
        {
            ZWrite Off
            ZTest Always
            Cull Front
            Offset -1,-1
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vertOutline
            #pragma fragment fragOutline
            ENDCG
        }
    }
}
