using UnityEngine;
using Renascer.World;
using Renascer.Player;
using Renascer.Gameplay;

namespace Renascer.Core
{
    public sealed class GameBootstrap : MonoBehaviour
    {
        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.AfterSceneLoad)]
        private static void StartGame()
        {
            if (FindFirstObjectByType<GameBootstrap>() != null) return;
            var go = new GameObject("RENASCER | Runtime");
            DontDestroyOnLoad(go);
            go.AddComponent<GameBootstrap>();
        }

        private void Awake()
        {
            Application.targetFrameRate = 60;
            QualitySettings.vSyncCount = 0;
            RenderSettings.fog = true;
            RenderSettings.fogMode = FogMode.ExponentialSquared;
            RenderSettings.fogDensity = 0.008f;
            RenderSettings.fogColor = new Color(0.56f, 0.78f, 0.85f);
            var sunObject = new GameObject("Sun");
            var sun = sunObject.AddComponent<Light>();
            sun.type = LightType.Directional;
            sun.intensity = 1.6f;
            sun.color = new Color(1f, 0.9f, 0.75f);
            sun.transform.rotation = Quaternion.Euler(42, -35, 0);
            RenderSettings.sun = sun;
            var world = new GameObject("Coastal World").AddComponent<IslandWorld>();
            world.Generate();
            var player = new GameObject("Explorer");
            player.transform.position = new Vector3(0, world.HeightAt(0, 0) + 2.5f, 0);
            player.AddComponent<CharacterController>();
            player.AddComponent<ExplorerController>();
            player.AddComponent<SurvivalInventory>();
            player.AddComponent<ExplorerHUD>();
            player.AddComponent<WorldResources>();
        }
    }
}
