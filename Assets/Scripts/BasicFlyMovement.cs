using System;
using UnityEngine;

public class BasicFlyMovement : MonoBehaviour
{
    [Header("Movement")]
    public float speed = 5f;
    public float rotationSpeed = 100f;
    public float sprintMultiplier = 2f;

    [Header("Mouse Look (Roblox-style hold)")]
    public bool holdRightMouseToLook = true;
    public float mouseSensitivity = 3f;
    public float maxPitch = 80f;
    public bool lockCursorWhileLooking = true;

    private float _yaw;
    private float _pitch;
    private bool _cursorLocked;

    private void Start()
    {
        Vector3 euler = transform.eulerAngles;
        _yaw = euler.y;
        _pitch = euler.x;
    }

    void Update()
    {
        HandleLook();
        HandleMove();
        UpdateCursorLock();
    }

    private void HandleLook()
    {
        bool shouldLook = holdRightMouseToLook ? Input.GetMouseButton(1) : true;

        if (shouldLook)
        {
            float mouseX = Input.GetAxis("Mouse X");
            float mouseY = Input.GetAxis("Mouse Y");

            _yaw += mouseX * mouseSensitivity;
            _pitch -= mouseY * mouseSensitivity;
            _pitch = Mathf.Clamp(_pitch, -maxPitch, maxPitch);
        }

        if (Input.GetKey(KeyCode.Q))
        {
            _yaw -= rotationSpeed * Time.deltaTime;
        }
        if (Input.GetKey(KeyCode.E))
        {
            _yaw += rotationSpeed * Time.deltaTime;
        }

        transform.rotation = Quaternion.Euler(_pitch, _yaw, 0f);

        _cursorLocked = shouldLook;
    }

    private void HandleMove()
    {
        float horizontal = Input.GetAxis("Horizontal");
        float vertical = Input.GetAxis("Vertical");

        float moveSpeed = speed * (Input.GetMouseButton(0) ? sprintMultiplier : 1f);

        Vector3 movement = new Vector3(horizontal, 0f, vertical) * moveSpeed * Time.deltaTime;
        transform.Translate(movement, Space.Self);

        if (Input.GetKey(KeyCode.LeftShift))
        {
            transform.Translate(Vector3.up * moveSpeed * Time.deltaTime, Space.World);
        }
        if (Input.GetKey(KeyCode.Space))
        {
            transform.Translate(Vector3.down * moveSpeed * Time.deltaTime, Space.World);
        }
    }

    private void UpdateCursorLock()
    {
        if (!lockCursorWhileLooking)
        {
            return;
        }

        if (_cursorLocked)
        {
            Cursor.lockState = CursorLockMode.Locked;
            Cursor.visible = false;
        }
        else
        {
            Cursor.lockState = CursorLockMode.None;
            Cursor.visible = true;
        }
    }
}
