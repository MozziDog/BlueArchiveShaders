using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class CharacterLight : MonoBehaviour
{
    [SerializeField] Material mat;
    int lightPropertyID;

    private void OnEnable()
    {
        lightPropertyID = Shader.PropertyToID("_ShadowLightDir");
        UpdateDirection();
    }

    private void OnDisable()
    {
        UpdateDirection();
    }

    private void Update()
    {
        UpdateDirection();
    }

    private void UpdateDirection()
    {
        mat.SetVector(lightPropertyID, transform.position);
    }

}
