Shader "Unlit/SeeThroughOutline"
{
    Properties
    {
        _MainTex ("Albedo", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _OutlineColor ("Outline Color", Color) = (0,1,1,1)
        _OutlineWidth ("Outline Width", Float) = 0.02
    }
    SubShader
    {
        // Draw as transparent+outline but keep base opaque
        Tags { "Queue"="Transparent+10" "RenderType"="Opaque" }
        Cull Back

        // Pass 1: outline always drawn (even when occluded)
        Pass
        {
            ZWrite Off
            ZTest Always
            Cull Front                           // flip faces so normal extrude works
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata { float4 vertex:POSITION; float3 normal:NORMAL; float2 uv:TEXCOORD0; };
            struct v2f { float4 pos:SV_POSITION; };

            float _OutlineWidth;
            float4 _OutlineColor;

            v2f vert(appdata v)
            {
                // expand along normals in object space
                v.vertex.xyz += v.normal * _OutlineWidth;
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target { return _OutlineColor; }
            ENDCG
        }

        // Pass 2: normal unlit textured surface (respects depth)
        Pass
        {
            ZWrite On
            ZTest LEqual
            Blend Off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata { float4 vertex:POSITION; float2 uv:TEXCOORD0; };
            struct v2f { float2 uv:TEXCOORD0; float4 pos:SV_POSITION; };

            sampler2D _MainTex; float4 _MainTex_ST; float4 _Color;

            v2f vert(appdata v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv,_MainTex);
                return o;
            }

            fixed4 frag(v2f i):SV_Target{
                fixed4 col = tex2D(_MainTex,i.uv) * _Color;
                col.a = 1; // force opaque so the mesh is always visible
                return col;
            }
            ENDCG
        }
    }
}
