using UnityEngine;

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
            if (Input.GetKeyDown(KeyCode.Escape)) Cursor.lockState = CursorLockMode.None;
            if (Input.GetMouseButtonDown(0)) Cursor.lockState = CursorLockMode.Locked;
            if (Cursor.lockState == CursorLockMode.Locked)
            {
                transform.Rotate(Vector3.up * Input.GetAxis("Mouse X") * mouseSensitivity);
                pitch = Mathf.Clamp(pitch - Input.GetAxis("Mouse Y") * mouseSensitivity, -85f, 85f);
                cameraPivot.localRotation = Quaternion.Euler(pitch, 0, 0);
            }
            var input = new Vector3(Input.GetAxisRaw("Horizontal"), 0, Input.GetAxisRaw("Vertical"));
            input = Vector3.ClampMagnitude(input, 1);
            float speed = Input.GetKey(KeyCode.LeftShift) ? sprintSpeed : walkSpeed;
            var move = transform.TransformDirection(input) * speed;
            if (controller.isGrounded && verticalVelocity < 0) verticalVelocity = -2f;
            if (controller.isGrounded && Input.GetKeyDown(KeyCode.Space)) verticalVelocity = 6.5f;
            verticalVelocity += Physics.gravity.y * Time.deltaTime;
            move.y = verticalVelocity;
            controller.Move(move * Time.deltaTime);
        }
    }
}
