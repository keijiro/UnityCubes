Shader "Hidden/UnityLogo/ScreenOverlay"
{
    Properties
    {
        _MainTex("", 2D) = "white"{}
        _MaskTex("", 2D) = "white"{}
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    sampler2D _MainTex;
    sampler2D _MaskTex;

    fixed4 frag (v2f_img i) : SV_Target
    {
        fixed4 c = tex2D(_MainTex, i.uv);
        fixed m = tex2D(_MaskTex, i.uv).r;
        return c * m;
    }

    ENDCG

    SubShader
    {
        Cull Off ZWrite Off ZTest Always
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag
            ENDCG
        }
    }
}
