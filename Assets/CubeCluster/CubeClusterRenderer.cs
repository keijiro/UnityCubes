using UnityEngine;
using System.Collections;

namespace UnityLogo
{
    [ExecuteInEditMode]
    public class CubeClusterRenderer : MonoBehaviour
    {
        #region Exposed properties

        [SerializeField, Range(0, 1)]
        float _phase;

        [Space]

        [SerializeField]
        float _transition = 0.1f;

        [Space]

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

        #endregion

        #region Private resources

        [SerializeField, HideInInspector] Shader _shader;
        Material _material;

        #endregion

        #region Private members

        float[] _randomParams = new float[8];
        Color _emissionColor;
        float _time;

        #endregion

        #region Public methods

        public void ResetParams()
        {
            for (var i = 0; i < 8; i++)
                _randomParams[i] = Random.value > 0.66f ? 1 : 0;

            _emissionColor = Color.HSVToRGB(Random.value, 0.5f, 1);

            _time = 0;
        }

        #endregion

        #region MonoBehaviour functions

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

        void Start()
        {
            ResetParams();
        }

        void Update()
        {
            _material.SetColor("_Color", _color);
            _material.SetTexture("_MainTex", _metallicMap);
            _material.SetTexture("_BumpMap", _normalMap);
            _material.SetFloat("_BumpScale", 1);
            _material.SetColor("_Emission", _emissionColor);

            _material.SetFloat("_Size", 1.0f / _mesh.columnCount);
            _material.SetFloat("_TextureScale", _textureScale);

            _material.SetFloat("_RTime", _time);
            _material.SetFloat("_Phase", _phase);
            _material.SetFloat("_Transition", _transition);

            _material.SetVector("_Params1", new Vector4(
                _randomParams[0],
                _randomParams[1],
                _randomParams[2],
                _randomParams[3]
            ));

            _material.SetVector("_Params2", new Vector4(
                _randomParams[4],
                _randomParams[5],
                _randomParams[6],
                _randomParams[7]
            ));

            Graphics.DrawMesh(
                _mesh.sharedMesh, transform.localToWorldMatrix, _material,
                gameObject.layer
            );

            _time += Time.deltaTime;
        }

        #endregion
    }
}
