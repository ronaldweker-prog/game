using System;
using System.IO;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEditor.Build.Reporting;
using UnityEngine;

namespace Renascer.EditorTools
{
    /// <summary>
    /// Prepares a real Unity Scene for cloud and local builds.
    /// This is editor-only; runtime objects are created by GameBootstrap at launch.
    /// </summary>
    [InitializeOnLoad]
    public static class RenascerCloudBuild
    {
        private const string ScenePath = "Assets/Scenes/Renascer.unity";

        static RenascerCloudBuild()
        {
            EditorApplication.delayCall += PrepareSceneIfMissing;
        }

        [MenuItem("RENASCER/Preparar cena de jogo")]
        public static void PrepareSceneIfMissing()
        {
            if (EditorApplication.isCompiling || EditorApplication.isPlayingOrWillChangePlaymode)
                return;

            if (!File.Exists(ScenePath))
            {
                Directory.CreateDirectory("Assets/Scenes");
                var previous = UnityEngine.SceneManagement.SceneManager.GetActiveScene();
                if (previous.IsValid() && previous.isDirty)
                {
                    Debug.LogWarning("RENASCER: cena aberta com alterações não salvas. Execute RENASCER/Preparar cena após salvar.");
                    return;
                }
                var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
                var root = new GameObject("RENASCER | Entry Scene");
                EditorSceneManager.SaveScene(scene, ScenePath);
                UnityEngine.Object.DestroyImmediate(root);
                AssetDatabase.Refresh();
            }

            if (File.Exists(ScenePath))
            {
                var scenes = EditorBuildSettings.scenes;
                if (scenes.Length != 1 || scenes[0].path != ScenePath || !scenes[0].enabled)
                    EditorBuildSettings.scenes = new[] { new EditorBuildSettingsScene(ScenePath, true) };
            }
        }

        /// <summary>Set this as pre-export hook in Unity Build Automation's Advanced settings.</summary>
        public static void PreExport()
        {
            PrepareSceneIfMissing();
            if (!File.Exists(ScenePath))
                throw new InvalidOperationException("RENASCER: cena de entrada não foi criada.");
            PlayerSettings.companyName = "Renascer";
            PlayerSettings.productName = "RENASCER NOVO MUNDO";
            PlayerSettings.applicationIdentifier = "com.renascer.novomundo";
            PlayerSettings.bundleVersion = "0.1.0";
        }

        [MenuItem("RENASCER/Build Windows 64")]
        public static void BuildWindows()
        {
            Build(BuildTarget.StandaloneWindows64, "Builds/Windows/RENASCER.exe");
        }

        [MenuItem("RENASCER/Build Android APK")]
        public static void BuildAndroid()
        {
            EditorUserBuildSettings.buildAppBundle = false;
            Build(BuildTarget.Android, "Builds/Android/RENASCER.apk");
        }

        private static void Build(BuildTarget target, string output)
        {
            PreExport();
            Directory.CreateDirectory(Path.GetDirectoryName(output));
            var report = BuildPipeline.BuildPlayer(new BuildPlayerOptions
            {
                scenes = new[] { ScenePath },
                locationPathName = output,
                target = target,
                options = BuildOptions.None
            });
            if (report.summary.result != BuildResult.Succeeded)
                throw new InvalidOperationException("RENASCER build failed: " + report.summary.result);
            Debug.Log("RENASCER build OK: " + output);
        }
    }
}
