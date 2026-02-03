Shader "Unlit/ExplosionSlicer"
{
    Properties
    {
        _Explode ("Explosion Distance", Float) = 0.2
        _MainTex ("Albedo", 2D) = "white" {}
        _Color ("Color Tint", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "Queue"="Geometry" "RenderType"="Opaque" }
        Cull Off
        ZWrite On
        ZTest LEqual
        Blend Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv  : TEXCOORD0;
                float3 wNormal : TEXCOORD1;
            };

            float _Explode;
            sampler2D _MainTex; float4 _MainTex_ST; float4 _Color;

            v2f vert(appdata v)
            {
                // Push faces along their normals to "slice" the mesh outward.
                v.vertex.xyz += v.normal * _Explode;

                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.wNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 albedo = tex2D(_MainTex, i.uv) * _Color;
                albedo.a = 1;
                return albedo;
            }
            ENDCG
        }
    }
}
