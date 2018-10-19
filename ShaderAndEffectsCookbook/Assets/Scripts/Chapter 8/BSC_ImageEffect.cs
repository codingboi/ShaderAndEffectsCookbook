using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class BSC_ImageEffect : MonoBehaviour
{

    #region Variables
    public Shader curShader;
    private Material curMaterial;

    [Range(0, 2)]
    public float brightnessAmount = 1.0f;
    [Range(0, 2)]
    public float saturationAmount = 1.0f;
    [Range(0, 3)]
    public float contrastAmount = 1.0f;
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
        if (curShader != null)
        {
            material.SetFloat("_BrightnessAmount", brightnessAmount);
            material.SetFloat("_satAmount", saturationAmount);
            material.SetFloat("_conAmount", contrastAmount);

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
        brightnessAmount = Mathf.Clamp(brightnessAmount, 0.0f, 2.0f);
        saturationAmount = Mathf.Clamp(saturationAmount, 0.0f, 2.0f);
        contrastAmount = Mathf.Clamp(contrastAmount, 0.0f, 3.0f);
    }

    private void OnDisable()
    {
        if (curMaterial)
        {
            DestroyImmediate(curMaterial);
        }
    }
}
