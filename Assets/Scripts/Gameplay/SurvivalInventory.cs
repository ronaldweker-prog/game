using System;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

namespace Renascer.Gameplay
{
    [Serializable] public sealed class InventoryEntry { public string id; public int amount; }
    [Serializable] public sealed class SaveData { public float x, y, z; public List<InventoryEntry> items = new List<InventoryEntry>(); }
    public sealed class SurvivalInventory : MonoBehaviour
    {
        public readonly Dictionary<string, int> items = new Dictionary<string, int>();
        public string Status { get; private set; } = "Explore a ilha e colete recursos";
        private string SavePath => Path.Combine(Application.persistentDataPath, "renascer_save.json");
        public void Add(string id, int amount)
        {
            if (amount <= 0) return;
            items[id] = Count(id) + amount;
            Status = "+" + amount + " " + id;
        }
        public int Count(string id) => items.TryGetValue(id, out int count) ? count : 0;
        public bool CraftShelterKit()
        {
            if (Count("fibra") < 3 || Count("pedra") < 2)
            {
                Status = "Kit de abrigo: precisa 3 fibras e 2 pedras";
                return false;
            }
            items["fibra"] -= 3;
            items["pedra"] -= 2;
            Add("kit_abrigo", 1);
            Status = "Kit de abrigo fabricado";
            return true;
        }
        public void Save()
        {
            var p = transform.position;
            var data = new SaveData { x = p.x, y = p.y, z = p.z };
            foreach (var item in items) data.items.Add(new InventoryEntry { id = item.Key, amount = item.Value });
            File.WriteAllText(SavePath, JsonUtility.ToJson(data, true));
            Status = "Progresso salvo";
        }
        public void Load()
        {
            if (!File.Exists(SavePath)) { Status = "Nenhum save encontrado"; return; }
            var data = JsonUtility.FromJson<SaveData>(File.ReadAllText(SavePath));
            items.Clear();
            foreach (var item in data.items) items[item.id] = item.amount;
            var cc = GetComponent<CharacterController>();
            cc.enabled = false;
            transform.position = new Vector3(data.x, data.y, data.z);
            cc.enabled = true;
            Status = "Progresso carregado";
        }
        private void Update()
        {
            if (Input.GetKeyDown(KeyCode.F)) CraftShelterKit();
            if (Input.GetKeyDown(KeyCode.F5)) Save();
            if (Input.GetKeyDown(KeyCode.F9)) Load();
        }
    }
}
