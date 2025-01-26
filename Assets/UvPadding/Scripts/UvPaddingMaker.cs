using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[CreateAssetMenu(fileName = "UvPaddingMaker", menuName = "Util/UvPaddingMaker", order = 0)]
public class UvPaddingMaker : ScriptableObject
{
    //          REFERENCES
    [Header("Shaders")]
    public Shader SeedGenerationShader;
    public Shader SeedPrepShader;
    public Shader jfaShader;
    public Shader ColorLookupShader;


    //          PARAMETERS
    [Header("Parameters")]
    [Tooltip("Texture to apply UV padding to.")]
    public Texture2D inputTex;

    [Tooltip("The color that is considered 'inter-island'")]
    public Color interIslandColor = new Color(0f, 0f, 0f, 0f);

    [Tooltip("Threshold for determining if a color is 'inter-island'")]
    public float interIslandThreshold = 0.05f;

    [Tooltip("The path that the asset will be written to.")]
    public string assetPath;

    [Tooltip("If checked, will write out as a PNG instead of a general asset.")]
    public bool saveToPng = false;


    //          PROPERTIES
    private int readIndex { get { return this._rwTog ? 1 : 0; } }
    private int writeIndex { get { return this._rwTog ? 0 : 1; } }


    //          INTERNALS
    private bool _rwTog = false;


    //          BEHAVIORS
    public void CreateTexture()
    {
        // Guard; no texture provided
        if (this.inputTex == null)
        {
            Debug.LogError("Need to provide an input texture");
            return;
        }

        // Apply shader to produce Voronoi seed tex
        Material seedPrepMat = new Material(this.SeedGenerationShader);
        seedPrepMat.SetColor("_MaskColor", this.interIslandColor);
        seedPrepMat.SetFloat("_MaskThreshold", this.interIslandThreshold);

        RenderTexture seedTex = new RenderTexture(this.inputTex.width, this.inputTex.height, 32, RenderTextureFormat.ARGBFloat);
        Graphics.Blit(this.inputTex, seedTex, seedPrepMat);

        // Run JFA on the seed text
        RenderTexture vtTex = this.RunJFA(seedTex);

        // Run Color lookup shader on VT tex
        Material colorLookupMat = new Material(this.ColorLookupShader);
        colorLookupMat.SetTexture("_ColorTex", this.inputTex);
        RenderTexture colorTex = new RenderTexture(this.inputTex.width, this.inputTex.height, 32, RenderTextureFormat.ARGBFloat);
        Graphics.Blit(vtTex, colorTex, colorLookupMat);

        // Set
        RenderTexture prev = RenderTexture.active;
        RenderTexture.active = colorTex;

        // Copy back to CPU
        Texture2D output = new Texture2D(this.inputTex.width, this.inputTex.height, this.inputTex.format, false);
        output.ReadPixels(new Rect(0, 0, this.inputTex.width, this.inputTex.height), 0, 0);
        output.Apply();

        // Revert
        RenderTexture.active = prev;
        

#if UNITY_EDITOR

        // Write texture to file
        if (this.saveToPng)
        {
            byte[] pngBytes = output.EncodeToPNG();
            System.IO.File.WriteAllBytes(this.assetPath, pngBytes);
        }
        else
        {
            UnityEditor.AssetDatabase.CreateAsset(output, this.assetPath);
        }

        // Refresh DB
        UnityEditor.AssetDatabase.Refresh();
#endif
    }

    /*
     * 	This functions implements "JFA Variant 2" as described in
     * 	"Variants of Jump Flooding Algorithm for Computing Discrete Voronoi Diagrams"
     * 	by Guodong Rong and Tiow_Seng Tan
     * 
     * 	https://www.researchgate.net/publication/4263565_Variants_of_Jump_Flooding_Algorithm_for_Computing_Discrete_Voronoi_Diagrams
     */
    private RenderTexture RunJFA(Texture seedTex)
    {
        // Setup
        Material seedPrepMat = new Material(this.SeedPrepShader);
        Material jfaMat = new Material(this.jfaShader);

        // Setup Workspace
        int jump = 1;
        RenderTexture[] JFA_Workspace = new RenderTexture[2]
        {
            new RenderTexture(seedTex.width, seedTex.height, 0, RenderTextureFormat.ARGB64),
            new RenderTexture(seedTex.width, seedTex.height, 0, RenderTextureFormat.ARGB64)
        };

        JFA_Workspace[0].wrapMode = TextureWrapMode.Mirror;
        JFA_Workspace[1].wrapMode = TextureWrapMode.Mirror;

        // Blit into workspace, applying seed prep material
        Graphics.Blit(seedTex, JFA_Workspace[this.readIndex], seedPrepMat);

        // Run JFA
        do
        {
            // Set 'jump' and 'aspect ratio' parameters in shader
            jfaMat.SetFloat("_JumpDist", 1f / jump);
            jfaMat.SetFloat("_AspectRatio", ((float)JFA_Workspace[0].width) / ((float)JFA_Workspace[0].height));

            // Run one pass of JFA
            Graphics.Blit(JFA_Workspace[this.readIndex], JFA_Workspace[this.writeIndex], jfaMat);

            // Modify 'jump'
            jump *= 2;

            // Swap Read/Write index
            this._rwTog = !this._rwTog;

        } while ((jump * Mathf.Max(JFA_Workspace[0].width, JFA_Workspace[0].height)) > 1f);

        // Blit into an output RT
        RenderTexture output = new RenderTexture(seedTex.width, seedTex.height, 0, RenderTextureFormat.ARGB64);
        Graphics.Blit(JFA_Workspace[this.readIndex], output);

        return output;
    }
}
