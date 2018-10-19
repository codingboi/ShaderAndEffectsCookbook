using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class DepthEffect : MonoBehaviour {

    #region Variables
    public Shader curShader;
    private Material curMaterial;

    [Range(0,5)]
    public float depthPower = 1.0f;
    #endregion

    #region Properties
    Material material
    {
        get
        {
            if (curMaterial == null)
            {
                curMaterial = new Material(curShader);
                curMaterial.hideFlags = HideFlags.HideAndDontSave;
            }
            return curMaterial;
        }
    }
    #endregion

    void Start()
    {
        if (!SystemInfo.supportsImageEffects)
        {
            enabled = false;
            return;
        }

        if (!curShader || !curShader.isSupported)
        {
            enabled = false;
        }
    }

    private void OnRenderImage(RenderTexture sourceTexture, RenderTexture destinationTexture)
    {
        if(curShader != null)
        {
            material.SetFloat("_DepthPower", depthPower);
            Graphics.Blit(sourceTexture, material);
        }
        else
        {
            Graphics.Blit(sourceTexture, destinationTexture);
        }
    }

    private void Update()
    {
        Camera.main.depthTextureMode = DepthTextureMode.Depth;
        depthPower = Mathf.Clamp(depthPower, 0, 5);
    }

    private void OnDisable()
    {
        if (curMaterial)
        {
            DestroyImmediate(curMaterial);
        }
    }
}
