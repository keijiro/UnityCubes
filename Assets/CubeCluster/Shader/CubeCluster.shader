Shader "UnityLogo/CubeCluster"
{
    Properties
    {
        _Color("", Color) = (1, 1, 1, 1)
        _MainTex("", 2D) = "white" {}

        _Glossiness("", Range(0, 1)) = 0
        [Gamma] _Metallic("", Range(0, 1)) = 0

        _BumpMap("", 2D) = "bump"{}
        _BumpScale("", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM

        #pragma surface surf Standard vertex:vert nolightmap addshadow
        #pragma target 3.0

        #include "SimplexNoiseExt3D.cginc"

        fixed4 _Color;
        sampler2D _MainTex;

        half _Glossiness;
        half _Metallic;

        sampler2D _BumpMap;
        half _BumpScale;

        float _Size;
        float _TextureScale;

        struct Input {
            float2 uv_MainTex;
            float4 color : COLOR;
        };

        // PRNG
        float UVRand(float2 uv)
        {
            return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
        }

        // Quaternion multiplication
        // http://mathworld.wolfram.com/Quaternion.html
        float4 qmul(float4 q1, float4 q2)
        {
            return float4(
                    q2.xyz * q1.w + q1.xyz * q2.w + cross(q1.xyz, q2.xyz),
                    q1.w * q2.w - dot(q1.xyz, q2.xyz)
                    );
        }

        // Uniformaly distributed points on a unit sphere
        // http://mathworld.wolfram.com/SpherePointPicking.html
        float3 random_point_on_sphere(float2 uv)
        {
            float u = UVRand(uv) * 2 - 1;
            float theta = UVRand(uv + 0.333) * UNITY_PI * 2;
            float u2 = sqrt(1 - u * u);
            return float3(u2 * cos(theta), u2 * sin(theta), u);
        }

        // Vector rotation with a quaternion
        // http://mathworld.wolfram.com/Quaternion.html
        float3 rotate_vector(float3 v, float4 r)
        {
            float4 r_c = r * float4(-1, -1, -1, 1);
            return qmul(r, qmul(float4(v, 0), r_c)).xyz;
        }

        // A given angle of rotation about a given aixs
        float4 rotation_angle_axis(float angle, float3 axis)
        {
            float sn, cs;
            sincos(angle * 0.5, sn, cs);
            return float4(axis * sn, cs);
        }

        void vert(inout appdata_full v)
        {
            float3 vpos = v.vertex.xyz;
            float3 uvw = v.texcoord1.xyz;

            float ratio = pow(abs(sin(_Time.x * 4 + uvw.x * 0.4)), 2);

            v.color = saturate(1 - ratio * float4(3, 4.5, 5, 1)) * 2;

            float2 r_uv = uvw.xy + uvw.z * 0.1;
            float3 offs2 = float3(
                sin(_Time.y * (1 + UVRand(r_uv))),
                sin(_Time.y * (1 + UVRand(r_uv + 1))),
                sin(_Time.y * (1 + UVRand(r_uv + 2)))
            ) * 0.4;

            // base position
            float3 offs = _Size * 0.5 + uvw - 0.5;

            offs *= 1 - pow(ratio, 3) * 0.4;

            //offs = rotate_vector(offs, rotation_angle_axis(_Time.y, float3(0, 1, 0)));
            offs = lerp(offs, offs2, ratio);

            // rotation
            float3 rnoise = uvw + float3(23.1, 38.4, 15.3);
            rnoise += _Time.y * 0.2;
            float rangle = snoise(rnoise) * ratio;
            float4 rotation = rotation_angle_axis(rangle, random_point_on_sphere(uvw.xy + uvw.z));

            // scale
            float3 sn = uvw * 0.8 + float3(_Time.y, 0, 0);
            float scale = _Size * lerp(1, saturate(0.5 + snoise(sn) * 0.6), ratio);

            v.vertex.xyz = rotate_vector(vpos, rotation) * scale + offs;
            v.normal = rotate_vector(v.normal, rotation);

            v.texcoord.xy = v.texcoord.xy * _TextureScale;
            v.texcoord.xy += float2(UVRand(uvw.xy + uvw.z), UVRand(uvw.yz + uvw.x));
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            float2 uv = IN.uv_MainTex.xy;

            fixed4 c = tex2D(_MainTex, uv) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;

            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;

            fixed4 nrm = tex2D(_BumpMap, uv);
            o.Normal = UnpackScaleNormal(nrm, _BumpScale);

            o.Emission = IN.color;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
