Shader "UnityLogo/CubeCluster"
{
    Properties
    {
        _Color("", Color) = (1, 1, 1, 1)
        _MainTex("", 2D) = "white" {}
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
        sampler2D _BumpMap;
        half _BumpScale;

        float _Size;
        float _TextureScale;

        float _RTime;
        float _Phase;
        float _Transition;

        float4 _Params1;
        float4 _Params2;

        struct Input
        {
            float2 uv_MainTex;
            float4 color : COLOR;
        };

        // PRNG
        float UVRand(float u, float v)
        {
            return frac(sin(dot(float2(u, v), float2(12.9898, 78.233))) * 43758.5453);
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
        float3 random_point_on_sphere(float seed1, float seed2)
        {
            float u = UVRand(seed1, seed2) * 2 - 1;
            float theta = UVRand(seed1 + 0.333, seed2) * UNITY_PI * 2;
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

        static const float kCycle = 18;
        static const float kTransition = 4;

        void vert(inout appdata_full v)
        {
            float3 vpos = v.vertex.xyz;
            float3 uvw = v.texcoord1.xyz;
            float id = dot(uvw, float3(24.13, 5.87, 1)) / 30;

            float phase = _Phase;
            phase *= 1 + _Transition * 2; // make transition margin
            phase -= id * _Transition;    // bias with object id
            phase = saturate(phase);      // clamp with 0-1

            const float eps = 1e-5;
            float dft1 = pow(max(eps, 1 - sin(phase * UNITY_PI)), 2);
            float dft2 = pow(max(eps, 1 - sin(phase * UNITY_PI)), 9);

            // base animations
            float3 offs = _Size * 0.5 + uvw - 0.5;
            float scale = (dft2 + 1) / 2 * _Size;
            float4 rot = float4(0, 0, 0, 1);

            {
                float dft = (1 - dft1) * (_Params1.x > 0.9);
                float3 crd = uvw * 1.6 + float3(0, 0, _RTime) * 1.2;
                scale *= 1 + snoise(crd) * 0.4 * dft;
            }
            {
                float dft = (1 - dft1) * (_Params1.y > 0.9);
                float3 crd = uvw * 1.4 + float3(0, 0, _RTime) * 0.5;
                offs += snoise_grad(crd) * 0.02 * dft;
            }
            {
                float dft = (1 - dft1) * (_Params1.z > 0.9);
                float3 axis = random_point_on_sphere(id, 0);
                float angle = UVRand(id, 1) * 3 + 1;
                rot = qmul(rot, rotation_angle_axis(angle * dft, axis));
            }
            {
                float dft = (1 - dft1) * (_Params1.w > 0.9);
                float3 axis = random_point_on_sphere(id, 13);
                float angle = snoise(uvw * 0.3 + float3(_RTime * 0.3, 0, 0)) * 5;
                rot = qmul(rot, rotation_angle_axis(angle * dft, axis));
            }
            {
                float dft = saturate(_Params1.x - dft1);
                float3 pt = float3(UVRand(id, 6), UVRand(id, 7), UVRand(id, 8));
                offs = lerp(offs, pt * 0.8 - 0.4, dft);
            }
            {
                float dft = saturate(_Params1.y - dft1);
                float3 orbit = float3(UVRand(id, 2), UVRand(id, 3), UVRand(id, 4));
                orbit = sin((orbit + 1) * (_RTime + 13)) * 0.4;
                offs = lerp(offs, orbit, dft);
            }
            {
                float dft = saturate(_Params1.z - dft1);
                float sn, cs;
                float r = _RTime * (0.5 + UVRand(id, 12) * 2);
                sincos(r, sn, cs);
                float3 pt = float3(offs.x, offs.y * cs - offs.z * sn, offs.y * sn + offs.z * cs);
                offs = lerp(offs, pt, dft);
                rot = lerp(rot, qmul(rot, rotation_angle_axis(r, float3(1, 0, 0))), dft);
                rot = normalize(rot);
            }

            // apply modification
            v.vertex.xyz = rotate_vector(vpos, rot) * scale + offs;
            v.normal = rotate_vector(v.normal, rot);
            v.color = dft2 * float4(3, 1.2, 1, 0);

            // texture coordnate
            v.texcoord.xy *= _TextureScale;
            v.texcoord.xy += float2(UVRand(id, 30), UVRand(id, 31));
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            float2 uv = IN.uv_MainTex.xy;

            o.Albedo = _Color.rgb;
            o.Alpha = _Color.a;

            float4 mt = tex2D(_MainTex, uv);
            o.Metallic = mt.r;
            o.Smoothness = mt.a;

            fixed4 nrm = tex2D(_BumpMap, uv);
            o.Normal = UnpackScaleNormal(nrm, _BumpScale);

            o.Emission = IN.color;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
