using UnityEngine;
using System.Collections;

public class ExplosionAnimator : MonoBehaviour
{
    [Header("Target")]
    public Material targetMaterial;
    public string explodeProperty = "_Explode";

    [Header("Timing")]
    public float minInterval = 5f;
    public float maxInterval = 10f;
    public float holdAtPeakSeconds = 2f;

    [Header("Motion")]
    public float maxDistance = 30f;
    public float explosionSpeed = 20f; // units per second

    private float _nextDelay;
    private float _timer;
    private Coroutine _activeRoutine;

    private void Start()
    {
        ScheduleNext();
    }

    private void Update()
    {
        if (targetMaterial == null)
            return;

        _timer += Time.deltaTime;
        if (_activeRoutine == null && _timer >= _nextDelay)
        {
            _activeRoutine = StartCoroutine(ExplosionRoutine());
        }
    }

    private IEnumerator ExplosionRoutine()
    {
        float value = 0f;
        SetExplode(value);

        // Rise to maxDistance
        while (value < maxDistance)
        {
            value = Mathf.MoveTowards(value, maxDistance, explosionSpeed * Time.deltaTime);
            SetExplode(value);
            yield return null;
        }

        // Hold at peak
        yield return new WaitForSeconds(holdAtPeakSeconds);

        // Snap back
        SetExplode(0f);

        // Reset timer and schedule next
        _timer = 0f;
        ScheduleNext();
        _activeRoutine = null;
    }

    private void ScheduleNext()
    {
        _nextDelay = Random.Range(minInterval, maxInterval);
    }

    private void SetExplode(float value)
    {
        targetMaterial.SetFloat(explodeProperty, value);
    }
}
