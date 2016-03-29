using UnityEngine;
using System.Collections.Generic;

namespace UnityLogo
{
    public class CubeClusterMesh : ScriptableObject
    {
        #region Public properties

        [SerializeField, Range(4, 10)]
        int _columnCount = 5;

        public int columnCount {
            get { return _columnCount; }
        }

        [SerializeField]
        Mesh _originalMesh;

        public Mesh originalMesh {
            get { return _originalMesh; }
        }

        [SerializeField, HideInInspector]
        Mesh _mesh;

        public Mesh sharedMesh {
            get { return _mesh; }
        }

        #endregion

        #region Public methods

        public void RebuildMesh()
        {
            if (_mesh == null)
            {
                Debug.LogError("Mesh asset is missing.");
                return;
            }

            _mesh.Clear();

            // Vertex and index arrays.
            var vtxList = new List<Vector3>();
            var nrmList = new List<Vector3>();
            var tanList = new List<Vector4>();
            var uv0List = new List<Vector2>();
            var uv1List = new List<Vector3>();
            var idxList = new List<int>();

            // Create the first instance.
            vtxList.AddRange(_originalMesh.vertices);
            nrmList.AddRange(_originalMesh.normals);
            tanList.AddRange(_originalMesh.tangents);
            uv0List.AddRange(_originalMesh.uv);
            idxList.AddRange(_originalMesh.GetIndices(0));

            var vcount = vtxList.Count;
            var icount = idxList.Count;

            for (var i = 0; i < vcount; i++)
                uv1List.Add(Vector3.zero);

            // Appends clones to the arrays.
            for (var u = 0; u < columnCount; u++)
            {
                for (var v = 0; v < columnCount; v++)
                {
                    for (var w = 0; w < columnCount; w++)
                    {
                        if (u == 0 && v == 0 && w == 0) continue;

                        var uv1 = new Vector3(
                            (float)u / columnCount,
                            (float)v / columnCount,
                            (float)w / columnCount
                        );

                        var idxoffs = vtxList.Count;

                        vtxList.AddRange(vtxList.GetRange(0, vcount));
                        nrmList.AddRange(nrmList.GetRange(0, vcount));
                        tanList.AddRange(tanList.GetRange(0, vcount));
                        uv0List.AddRange(uv0List.GetRange(0, vcount));

                        for (var i = 0; i < vcount; i++)
                            uv1List.Add(uv1);

                        for (var i = 0; i < icount; i++)
                            idxList.Add(idxList[i] + idxoffs);
                    }
                }
            }

            // Rebuild the mesh object.
            _mesh.SetVertices(vtxList);
            _mesh.SetNormals(nrmList);
            _mesh.SetTangents(tanList);
            _mesh.SetUVs(0, uv0List);
            _mesh.SetUVs(1, uv1List);
            _mesh.SetIndices(idxList.ToArray(), MeshTopology.Triangles, 0);

            _mesh.bounds = new Bounds(Vector3.zero, Vector3.one * 1000);

            _mesh.Optimize();
            _mesh.UploadMeshData(true);
        }

        #endregion

        #region ScriptableObject functions

        void OnEnable()
        {
            if (_mesh == null)
            {
                _mesh = new Mesh();
                _mesh.name = "CubeCluster";
            }
        }

        #endregion
    }
}
