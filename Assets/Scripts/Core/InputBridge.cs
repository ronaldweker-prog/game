using UnityEngine;
#if ENABLE_INPUT_SYSTEM
using UnityEngine.InputSystem;
#endif

namespace Renascer.Core
{
    /// <summary>Desktop inputs compatible with the old and modern Unity input backends.</summary>
    public static class InputBridge
    {
        public static Vector2 Movement
        {
            get
            {
#if ENABLE_INPUT_SYSTEM
                var k = Keyboard.current;
                if (k == null) return Vector2.zero;
                var input = new Vector2(
                    (k.dKey.isPressed || k.rightArrowKey.isPressed ? 1f : 0f) -
                    (k.aKey.isPressed || k.leftArrowKey.isPressed ? 1f : 0f),
                    (k.wKey.isPressed || k.upArrowKey.isPressed ? 1f : 0f) -
                    (k.sKey.isPressed || k.downArrowKey.isPressed ? 1f : 0f));
                return Vector2.ClampMagnitude(input, 1f);
#else
                return Vector2.ClampMagnitude(new Vector2(Input.GetAxisRaw("Horizontal"), Input.GetAxisRaw("Vertical")), 1f);
#endif
            }
        }

        public static Vector2 Look
        {
            get
            {
#if ENABLE_INPUT_SYSTEM
                return Mouse.current == null ? Vector2.zero : Mouse.current.delta.ReadValue() * 0.08f;
#else
                return new Vector2(Input.GetAxis("Mouse X"), Input.GetAxis("Mouse Y"));
#endif
            }
        }

        public static bool Down(KeyCode code)
        {
#if ENABLE_INPUT_SYSTEM
            var k = Keyboard.current;
            if (k == null) return false;
            switch (code)
            {
                case KeyCode.E: return k.eKey.wasPressedThisFrame;
                case KeyCode.F: return k.fKey.wasPressedThisFrame;
                case KeyCode.F5: return k.f5Key.wasPressedThisFrame;
                case KeyCode.F9: return k.f9Key.wasPressedThisFrame;
                case KeyCode.Tab: return k.tabKey.wasPressedThisFrame;
                case KeyCode.Space: return k.spaceKey.wasPressedThisFrame;
                case KeyCode.Escape: return k.escapeKey.wasPressedThisFrame;
                default: return false;
            }
#else
            return Input.GetKeyDown(code);
#endif
        }

        public static bool Held(KeyCode code)
        {
#if ENABLE_INPUT_SYSTEM
            if (Keyboard.current == null) return false;
            return code == KeyCode.LeftShift && Keyboard.current.leftShiftKey.isPressed;
#else
            return Input.GetKey(code);
#endif
        }

        public static bool MouseClick
        {
            get
            {
#if ENABLE_INPUT_SYSTEM
                return Mouse.current != null && Mouse.current.leftButton.wasPressedThisFrame;
#else
                return Input.GetMouseButtonDown(0);
#endif
            }
        }
    }
}
