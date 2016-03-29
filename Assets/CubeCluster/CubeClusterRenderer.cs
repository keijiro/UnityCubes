using UnityEngine;
using System.Collections;

namespace UnityLogo
{
    [ExecuteInEditMode]
    public class CubeClusterRenderer : MonoBehaviour
    {
        [SerializeField, ColorUsage(false)]
        Color _color;

        [SerializeField]
        CubeClusterMesh _mesh;

        [SerializeField]
        Texture _metallicMap;

        [SerializeField]
        Texture _normalMap;

        [SerializeField]
        float _textureScale = 1;

        [SerializeField]
        Shader _shader;

        Material _material;

        void OnEnable()
        {
            _material = new Material(Shader.Find("UnityLogo/CubeCluster"));
            _material.hideFlags = HideFlags.DontSave;
        }

        void OnDisable()
        {
            DestroyImmediate(_material);
            _material = null;
        }

        void Update()
        {
            _material.color = _color;
            _material.SetFloat("_Size", 1.0f / _mesh.columnCount);
            _material.mainTexture = _metallicMap;
            _material.SetTexture("_BumpMap", _normalMap);
            _material.SetFloat("_TextureScale", _textureScale);

            Graphics.DrawMesh(
                _mesh.sharedMesh, transform.localToWorldMatrix, _material,
                gameObject.layer
            );
        }
    }
}
