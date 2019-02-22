using System.Collections;
using System.Collections.Generic;
using UnityEngine;
//[ExecuteInEditMode]
public class ChangeRect : MonoBehaviour
{
    public RectTransform Rect;

    public Material Mat;
    public List<float> Pointx;

    public List<float> Pointy;

    public AnimationCurve curve;

    private int count = 0;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        Pointx[count] = Time.time%1;
        Pointy[count] = curve.Evaluate(Time.time);
        count++;
        if (count >= Pointx.Count)
        {
            count = 0;
        }
        Mat.SetFloat("_PointLength",100);
        Mat.SetFloatArray("_Pointx",Pointx);
        Mat.SetFloatArray("_Pointy",Pointy);
    }
}
