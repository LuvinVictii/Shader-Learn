Shader "Unlit/ExplosionSlicer"
{
    Properties
    {
        _Explode ("Explosion Distance", Float) = 0.2
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
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 wNormal : TEXCOORD0;
            };

            float _Explode;

            v2f vert(appdata v)
            {
                // Push faces along their normals to "slice" the mesh outward.
                v.vertex.xyz += v.normal * _Explode;

                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.wNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Visualize the original normal as color (remap -1..1 to 0..1)
                float3 n = normalize(i.wNormal);
                return fixed4(n * 0.5f + 0.5f, 1.0f);
            }
            ENDCG
        }
    }
}
