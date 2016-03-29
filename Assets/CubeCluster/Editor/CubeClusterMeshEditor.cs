using UnityEngine;
using UnityEditor;
using System.IO;

namespace UnityLogo
{
    [CustomEditor(typeof(CubeClusterMesh))]
    public class CubeClusterMeshEditor : Editor
    {
        SerializedProperty _columnCount;
        SerializedProperty _originalMesh;

        void OnEnable()
        {
            _columnCount = serializedObject.FindProperty("_columnCount");
            _originalMesh = serializedObject.FindProperty("_originalMesh");
        }

        public override void OnInspectorGUI()
        {
            serializedObject.Update();

            EditorGUI.BeginChangeCheck();
            EditorGUILayout.PropertyField(_columnCount);
            EditorGUILayout.PropertyField(_originalMesh);
            var rebuild = EditorGUI.EndChangeCheck();

            serializedObject.ApplyModifiedProperties();

            if (rebuild)
                foreach (var t in targets)
                    ((CubeClusterMesh)t).RebuildMesh();
        }

        [MenuItem("Assets/Create/CubeClusterMesh")]
        public static void CreateCubeClusterMeshAsset()
        {
            // Make a proper path from the current selection.
            var path = AssetDatabase.GetAssetPath(Selection.activeObject);
            if (string.IsNullOrEmpty(path))
                path = "Assets";
            else if (Path.GetExtension(path) != "")
                path = path.Replace(Path.GetFileName(path), "");
            var assetPathName = AssetDatabase.GenerateUniqueAssetPath(path + "/CubeCluster.asset");

            // Create an asset.
            var asset = ScriptableObject.CreateInstance<CubeClusterMesh>();
            AssetDatabase.CreateAsset(asset, assetPathName);
            AssetDatabase.AddObjectToAsset(asset.sharedMesh, asset);

            // Build an initial mesh for the asset.
            asset.RebuildMesh();

            // Save the generated mesh asset.
            AssetDatabase.SaveAssets();

            // Tweak the selection.
            EditorUtility.FocusProjectWindow();
            Selection.activeObject = asset;
        }
    }
}
