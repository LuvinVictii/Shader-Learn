Shader "Unlit/SeeThroughOutline"
{
    Properties
    {
        _MainTex ("Albedo", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _OutlineColor ("Outline Color", Color) = (1,0.5,0,1)
        _OutlineWidth ("Outline Width", Float) = 0.025
        _HiddenBoost ("Hidden Outline Scale", Float) = 1.5
    }
    SubShader
    {
        // Render after opaque geometry so depth contains occluders, but before transparents.
        Tags { "Queue"="Geometry+10" "RenderType"="Opaque" }
        Cull Back

        // Pass 1: depth-only prepass to ensure correct depth for this object
        Pass
        {
            Tags { "LightMode"="DepthOnly" }
            ZWrite On
            ColorMask 0
        }

        // Pass 2: normal unlit textured surface (opaque)
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
                col.a = 1;
                return col;
            }
            ENDCG
        }

        // Pass 3: outline when occluded (shows through other geometry)
        Pass
        {
            ZWrite Off
            ZTest Greater
            Cull Front
            Offset -1,-1
            Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata { float4 vertex:POSITION; float3 normal:NORMAL; float2 uv:TEXCOORD0; };
            struct v2f { float4 pos:SV_POSITION; };

            float _OutlineWidth;
            float _HiddenBoost;
            float4 _OutlineColor;

            v2f vert(appdata v)
            {
                v.vertex.xyz += v.normal * (_OutlineWidth * _HiddenBoost);
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target { return _OutlineColor; }
            ENDCG
        }

        // Pass 4: visible outline on top of mesh edges
        Pass
        {
            ZWrite Off
            ZTest LEqual
            Cull Front
            Offset -1,-1
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
                v.vertex.xyz += v.normal * _OutlineWidth;
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target { return _OutlineColor; }
            ENDCG
        }
    }
}
