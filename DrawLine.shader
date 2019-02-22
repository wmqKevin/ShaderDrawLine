Shader "Unlit/DrawLine"
{
    Properties
    {
        _LineWidth("Line Width",float) = 5
        _LineColor("Line Color",Color) = (1,1,1,1)
        //_Antialias("Antialias Factor",float) = 3
        _BackgroundColor("Background Color",Color) = (1,1,1,0)
        _MainTex("MainTex",2D) = "white" {}
        _ObjWidth("Obj Width",float)=100
        _ObjHeight("Obj Height",float)=100
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM

            // Upgrade NOTE: excluded shader from DX11, OpenGL ES 2.0 because it uses unsized arrays
            //#pragma exclude_renderers d3d11 gles
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            //#include "ShaderToyDefines.cginc"
            #pragma target 3.0
            #define iResolution _ScreenParams

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 screenPos : TEXCOORD1;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            float _LineWidth;
            float4 _LineColor;
            //float _Antialias;
            float4 _BackgroundColor;
            float4 _Point_Width;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _ObjHeight;
            float _ObjWidth;
            float2 _ObjParam;
            uniform float _PointLength;
            uniform float _Pointx[100] ;
            uniform float _Pointy[100] ;
            v2f vert (appdata v)
            {
                
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //o.uv = v.uv;
                
                return o;
            }
            float4 main(float2 fragCoord);
            float4 frag (v2f i) : COLOR0
            {
                // sample the texture
                //fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                _ObjParam = float2(_ObjWidth,_ObjHeight);
                float2 gl_FragCoord = (i.uv*_ObjParam.xy);//片原uv点转换以长宽为基线的自身坐标点
                return main(gl_FragCoord);
                //return _BackgroundColor;
            }

            ///大于0在上侧，小于0在下侧，等于在线上
            float pointOrientationByLine(float k,float2 p,float2 position)
            {
                if(!isinf(k))
                    return position.y-p.y-k*(position.x-p.x);
                else
                    return p.x-position.x;
            }

            float4 drawLine(float2 pos,float2 point1,float2 point2,float width,float3 color,float antialias)
            {
                float k = (point1.y-point2.y)/(point1.x-point2.x);//计算斜率
                
                float b = point1.y-k*point1.x;//计算零点
                float d = point1.x==point2.x?abs(pos.x-point1.x):abs(k*pos.x-pos.y+b)/sqrt(k*k+1);//计算点与直线的间距
                float t = smoothstep(width/2.0,width/2.0+antialias,d);//小于最小宽返回0，大于返回1,antilalias抗锯齿
                float2 pos2point1 = point1-pos;
                float2 pos2point2 = point2-pos;
                //线段
                float minx = min(point1.x,point2.x);
                float maxx = max(point1.x,point2.x);
                float lefty = point1.x==minx?point1.y:point2.y;
                float righty = point1.x==minx?point2.y:point1.y;
                //x偏小的垂直于目标线的线方程
                //y-lefty-(-1/k)*(x-minx)=0;
                //x偏大的
                //y-righty-(-1/k)*(x-maxx)=0;
                float k2 = -1/k;
                float relationLeftPoint = pointOrientationByLine(k2,float2(minx,lefty),pos);
                float relationRightPoint = pointOrientationByLine(k2,float2(maxx,righty),pos);

                if(righty>lefty)
                {
                    if(relationLeftPoint<0)
                    {
                        float d = distance(pos,float2(minx,lefty));
                        t = smoothstep(width/2.0,width/2.0+antialias,d);
                    }
                    else if(relationRightPoint>0)
                    {
                        float d = distance(pos,float2(maxx,righty));
                        t = smoothstep(width/2.0,width/2.0+antialias,d);
                    }
                }
                else 
                {
                    if(relationLeftPoint>0)
                    {
                        float d = distance(pos,float2(minx,lefty));
                        t = smoothstep(width/2.0,width/2.0+antialias,d);
                    }
                    else if(relationRightPoint<0)
                    {
                        float d = distance(pos,float2(maxx,righty));
                        t = smoothstep(width/2.0,width/2.0+antialias,d);
                    }
                }
                
                return float4(color,1.0-t);//大于宽的范围alpha值为0，不绘制
            }
            

            float4 main(float2 fragCoord)
            {
                float2 pos = fragCoord;
                float4 layer1 = float4(_BackgroundColor.rgb,1.0);
                float4 layer2 = float4(1,1,1,0);
                float4 fragColor = lerp(layer1,layer2,layer2.a);
                float2 point1 = float2(0.0,0.0);
                float2 point2 = float2(0.0,0.0);
                for (int i = 0; i < _PointLength-1; i++)
		        {
                    point1 = float2(_Pointx[i],_Pointy[i])*_ObjParam.xy;
                    point2 = float2(_Pointx[i+1],_Pointy[i+1])*_ObjParam.xy;
                    layer2 = drawLine(pos,point1,point2,_LineWidth,_LineColor.rgb,3);
                    fragColor =lerp(fragColor,layer2,layer2.a);
                }
                
                return fragColor;
            }
            ENDCG
        }
    }
    //Fallback "Diffuse"
}
