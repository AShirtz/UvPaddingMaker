using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;


[CustomEditor(typeof(UvPaddingMaker))]
public class UvPaddingMakerEditor : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        UvPaddingMaker uvPd = (UvPaddingMaker)target;

        if (GUILayout.Button("Create Padded Texture", GUILayout.Height(40)))
        {
            uvPd.CreateTexture();
        }
    }
}
