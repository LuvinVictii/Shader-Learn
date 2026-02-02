using UnityEngine;

public class GlitchingObject : MonoBehaviour
{
    [Header("Rotation Settings")]
    public float rotationSpeed = 100f;
    
    [Header("Glitch Settings")]
    public Material hologramMaterial;
    public float glitchIntensity = 1.0f;    
    public float glitchDuration = 0.1f;
    public float minInterval = 0.5f;
    public float maxInterval = 2.0f;
    private float lastGlitchTime = 0f;
    private float nextGlitchInterval;

    void Update()
    {
        if (Time.time - lastGlitchTime > nextGlitchInterval)
        {
            StartCoroutine(ApplyGlitch());
            lastGlitchTime = Time.time;
            nextGlitchInterval = Random.Range(minInterval, maxInterval);
        }
        transform.Rotate(Vector3.up, rotationSpeed * Time.deltaTime);
    }

    private System.Collections.IEnumerator ApplyGlitch()
    {
        hologramMaterial.SetFloat("_Amount", glitchIntensity);
        yield return new WaitForSeconds(glitchDuration);
        hologramMaterial.SetFloat("_Amount", 0f);
    }
}
