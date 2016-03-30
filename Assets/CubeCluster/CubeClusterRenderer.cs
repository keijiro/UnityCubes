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

        Vector4 _switch1;
        Vector4 _switch2;

        Vector4 RandomBinaryVector {
            get {
                return new Vector4(
                    Random.value > 0.5f ? 1 : 0,
                    Random.value > 0.5f ? 1 : 0,
                    Random.value > 0.5f ? 1 : 0,
                    Random.value > 0.5f ? 1 : 0
                );
            }
        }

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

        IEnumerator Start()
        {
            while (true)
            {
                _switch1 = RandomBinaryVector;
                _switch2 = RandomBinaryVector;
                yield return new WaitForSeconds(18);
            }
        }

        void Update()
        {
            _material.color = _color;
            _material.SetFloat("_Size", 1.0f / _mesh.columnCount);
            _material.mainTexture = _metallicMap;
            _material.SetTexture("_BumpMap", _normalMap);
            _material.SetFloat("_TextureScale", _textureScale);

            _material.SetVector("_Switch1", _switch1);
            _material.SetVector("_Switch2", _switch2);

            Graphics.DrawMesh(
                _mesh.sharedMesh, transform.localToWorldMatrix, _material,
                gameObject.layer
            );
        }
    }
}
