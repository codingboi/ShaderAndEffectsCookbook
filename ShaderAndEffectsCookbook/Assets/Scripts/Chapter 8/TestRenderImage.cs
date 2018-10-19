using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class TestRenderImage : MonoBehaviour {

    #region Variables
    public Shader curShader;
    [Range(0,1)]
    public float grayScaleAmount = 1.0f;
    private Material curMaterial;
    #endregion

    #region Properties
    Material material
    {
        get
        {
            if(curMaterial == null)
            {
                curMaterial = new Material(curShader);
                curMaterial.hideFlags = HideFlags.HideAndDontSave;
            }
            return curMaterial;
        }
    }
    #endregion

    // Use this for initialization
    void Start () {
        if (!SystemInfo.supportsImageEffects)
        {
            enabled = false;
            return;
        }

        if(!curShader || !curShader.isSupported)
        {
            enabled = false;
        }
	}

    private void OnRenderImage(RenderTexture sourceTexture, RenderTexture destinationTexture)
    {
        if(curShader != null)
        {
            material.SetFloat("_LuminosityAmount", grayScaleAmount);
            Graphics.Blit(sourceTexture, destinationTexture, material);
        }
        else
        {
            Graphics.Blit(sourceTexture, destinationTexture);
        }
    }

    private void Update()
    {
        grayScaleAmount = Mathf.Clamp(grayScaleAmount, 0.0f, 1.0f);
    }

    private void OnDisable()
    {
        if (curMaterial)
        {
            DestroyImmediate(curMaterial);
        }
    }
}
