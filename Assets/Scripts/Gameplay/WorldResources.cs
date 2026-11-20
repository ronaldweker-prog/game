using UnityEngine;
using Renascer.World;

namespace Renascer.Gameplay
{
    public sealed class WorldResources : MonoBehaviour
    {
        private Camera viewCamera;
        private SurvivalInventory inventory;
        private void Start()
        {
            viewCamera = GetComponentInChildren<Camera>();
            inventory = GetComponent<SurvivalInventory>();
            var world = FindFirstObjectByType<IslandWorld>();
            var random = new System.Random(371);
            for (int i = 0; i < 80; i++)
            {
                float x = (float)(random.NextDouble() * 180 - 90);
                float z = (float)(random.NextDouble() * 180 - 90);
                float y = world.HeightAt(x, z);
                if (y < 0.4f) continue;
                var node = new GameObject(i % 3 == 0 ? "Fibra coletavel" : "Pedra coletavel");
                node.transform.position = new Vector3(x, y + 0.4f, z);
                var collider = node.AddComponent<SphereCollider>();
                collider.radius = 0.5f;
                collider.isTrigger = true;
                var resource = node.AddComponent<ResourceNode>();
                resource.itemId = i % 3 == 0 ? "fibra" : "pedra";
                // Intentionally no fake cube/sphere render: art assets must be imported and assigned.
            }
        }
        private void Update()
        {
            if (!Input.GetKeyDown(KeyCode.E) || viewCamera == null) return;
            var ray = new Ray(viewCamera.transform.position, viewCamera.transform.forward);
            if (Physics.Raycast(ray, out RaycastHit hit, 3.5f, ~0, QueryTriggerInteraction.Collide))
            {
                var node = hit.collider.GetComponent<ResourceNode>();
                if (node == null) return;
                inventory.Add(node.itemId, 1);
                Destroy(node.gameObject);
            }
        }
    }
    public sealed class ResourceNode : MonoBehaviour { public string itemId; }
}
