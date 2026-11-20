using UnityEngine;

namespace Renascer.World
{
    public sealed class IslandWorld : MonoBehaviour
    {
        public const int Resolution = 128;
        public const float Extent = 160f;
        private const float SeaLevel = 0f;
        public float HeightAt(float x, float z)
        {
            float distance = new Vector2(x, z).magnitude / Extent;
            float shore = Mathf.Clamp01((1f - distance) * 3.5f);
            float hills = Mathf.PerlinNoise(x * 0.014f + 22, z * 0.014f + 42) * 15f;
            float detail = Mathf.PerlinNoise(x * 0.06f + 17, z * 0.06f + 30) * 2.8f;
            return -4f + shore * (5f + hills + detail);
        }
        public void Generate()
        {
            int n = Resolution;
            var vertices = new Vector3[(n + 1) * (n + 1)];
            var uv = new Vector2[vertices.Length];
            var triangles = new int[n * n * 6];
            for (int z = 0; z <= n; z++)
            for (int x = 0; x <= n; x++)
            {
                float px = (x / (float)n * 2f - 1f) * Extent;
                float pz = (z / (float)n * 2f - 1f) * Extent;
                int index = z * (n + 1) + x;
                vertices[index] = new Vector3(px, HeightAt(px, pz), pz);
                uv[index] = new Vector2(x / (float)n, z / (float)n);
                if (x == n || z == n) continue;
                int t = (z * n + x) * 6;
                triangles[t] = index;
                triangles[t + 1] = index + n + 1;
                triangles[t + 2] = index + 1;
                triangles[t + 3] = index + 1;
                triangles[t + 4] = index + n + 1;
                triangles[t + 5] = index + n + 2;
            }
            var mesh = new Mesh { indexFormat = UnityEngine.Rendering.IndexFormat.UInt32 };
            mesh.name = "Island Terrain";
            mesh.vertices = vertices;
            mesh.uv = uv;
            mesh.triangles = triangles;
            mesh.RecalculateNormals();
            mesh.RecalculateBounds();
            var land = new GameObject("Island terrain mesh");
            land.transform.SetParent(transform);
            land.AddComponent<MeshFilter>().sharedMesh = mesh;
            land.AddComponent<MeshCollider>().sharedMesh = mesh;
            var material = NewLit(new Color(0.38f, 0.55f, 0.31f));
            land.AddComponent<MeshRenderer>().sharedMaterial = material;
            var ocean = GameObject.CreatePrimitive(PrimitiveType.Plane);
            ocean.name = "Ocean (temporary material — replace with authored water shader)";
            ocean.transform.SetParent(transform);
            ocean.transform.position = new Vector3(0, SeaLevel, 0);
            ocean.transform.localScale = new Vector3(90, 1, 90);
            ocean.GetComponent<Renderer>().sharedMaterial = NewLit(new Color(0.05f, 0.44f, 0.62f));
            Destroy(ocean.GetComponent<Collider>());
        }
        public static Material NewLit(Color color)
        {
            var shader = Shader.Find("Universal Render Pipeline/Lit") ?? Shader.Find("Standard");
            var mat = new Material(shader);
            mat.color = color;
            return mat;
        }
    }
}
