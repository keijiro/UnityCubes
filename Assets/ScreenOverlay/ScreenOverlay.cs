using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class ScreenOverlay : MonoBehaviour
{
    [SerializeField]
    Texture _mask;

    [SerializeField]
    Shader _shader;

    Material _material;

    void OnEnable()
    {
        _material = new Material(Shader.Find("Hidden/UnityLogo/ScreenOverlay"));
        _material.hideFlags = HideFlags.DontSave;
    }

    void OnDisable()
    {
        DestroyImmediate(_material);
        _material = null;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        _material.SetTexture("_MaskTex", _mask);
        Graphics.Blit(source, destination, _material, 0);
    }
}
