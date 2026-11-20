using UnityEngine;
using Renascer.Core;

namespace Renascer.Player
{
    [RequireComponent(typeof(CharacterController))]
    public sealed class ExplorerController : MonoBehaviour
    {
        public float walkSpeed = 5f;
        public float sprintSpeed = 8f;
        public float mouseSensitivity = 1.8f;
        private CharacterController controller;
        private Transform cameraPivot;
        private float pitch;
        private float verticalVelocity;
        private void Awake()
        {
            controller = GetComponent<CharacterController>();
            controller.height = 1.85f;
            controller.radius = 0.35f;
            controller.center = new Vector3(0, 0.92f, 0);
            var cameraObject = new GameObject("First Person Camera");
            cameraObject.transform.SetParent(transform);
            cameraObject.transform.localPosition = new Vector3(0, 1.62f, 0);
            cameraPivot = cameraObject.transform;
            var cam = cameraObject.AddComponent<Camera>();
            cam.fieldOfView = 72f;
            cameraObject.AddComponent<AudioListener>();
            Cursor.lockState = CursorLockMode.Locked;
        }
        private void Update()
        {
            if (InputBridge.Down(KeyCode.Escape)) Cursor.lockState = CursorLockMode.None;
            if (InputBridge.MouseClick) Cursor.lockState = CursorLockMode.Locked;
            if (Cursor.lockState == CursorLockMode.Locked)
            {
                transform.Rotate(Vector3.up * InputBridge.Look.x * mouseSensitivity);
                pitch = Mathf.Clamp(pitch - InputBridge.Look.y * mouseSensitivity, -85f, 85f);
                cameraPivot.localRotation = Quaternion.Euler(pitch, 0, 0);
            }
            var movement = InputBridge.Movement;
            var input = new Vector3(movement.x, 0, movement.y);
            input = Vector3.ClampMagnitude(input, 1);
            float speed = InputBridge.Held(KeyCode.LeftShift) ? sprintSpeed : walkSpeed;
            var move = transform.TransformDirection(input) * speed;
            if (controller.isGrounded && verticalVelocity < 0) verticalVelocity = -2f;
            if (controller.isGrounded && InputBridge.Down(KeyCode.Space)) verticalVelocity = 6.5f;
            verticalVelocity += Physics.gravity.y * Time.deltaTime;
            move.y = verticalVelocity;
            controller.Move(move * Time.deltaTime);
        }
    }
}
