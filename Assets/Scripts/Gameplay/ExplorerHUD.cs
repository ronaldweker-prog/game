using UnityEngine;

namespace Renascer.Gameplay
{
    public sealed class ExplorerHUD : MonoBehaviour
    {
        private SurvivalInventory inventory;
        private bool showInventory;
        private GUIStyle textStyle;
        private void Awake() { inventory = GetComponent<SurvivalInventory>(); }
        private void Update() { if (Input.GetKeyDown(KeyCode.Tab)) showInventory = !showInventory; }
        private void OnGUI()
        {
            if (textStyle == null)
            {
                textStyle = new GUIStyle(GUI.skin.label) { fontSize = 18, wordWrap = true };
                textStyle.normal.textColor = Color.white;
            }
            GUI.Box(new Rect(12, 12, 420, 104), "RENASCER: NOVO MUNDO | Unity 6");
            GUI.Label(new Rect(24, 40, 400, 75), "WASD mover | Mouse olhar | E coletar | F criar abrigo\nTab inventario | F5 salvar | F9 carregar", textStyle);
            GUI.Box(new Rect(12, Screen.height - 72, 520, 58), inventory.Status);
            if (!showInventory) return;
            GUI.Box(new Rect(Screen.width - 330, 12, 310, 260), "INVENTARIO");
            int y = 46;
            foreach (var item in inventory.items)
            {
                GUI.Label(new Rect(Screen.width - 310, y, 270, 25), item.Key + ": " + item.Value, textStyle);
                y += 27;
            }
        }
    }
}
