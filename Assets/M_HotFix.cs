using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;
using System.IO;
using System.Text;
using UnityEngine.Networking;

public class M_HotFix : MonoBehaviour
{
    private LuaEnv luaEnv;

    private Dictionary<string, GameObject> ObjDic = new Dictionary<string, GameObject>();

    private static Dictionary<string, AssetBundle> ABDic = new Dictionary<string, AssetBundle>();

    private void Awake()
    {
        luaEnv = new LuaEnv();
        luaEnv.AddLoader(M_Loader);
        luaEnv.DoString("require 'FishingLua'");
        
        // if (ABDic.Count==0)
        // {
        //     AssetBundle manifestAB = AssetBundle.LoadFromFile("AssetBundles/AssetBundles");
        //     AssetBundleManifest manifest = manifestAB.LoadAsset<AssetBundleManifest>("AssetBundleManifest");
        //     foreach (string ABName in manifest.GetAllAssetBundles())
        //     {
        //         AssetBundle ab = AssetBundle.LoadFromFile("AssetBundles/" + ABName);
        //         ABDic.Add(ABName, ab);
        //     }
        // }
    }

    private void Start()
    {
        
    }

    private byte[] M_Loader(ref string filePath)
    {
        string path = @"D:\learn\HotUpdate\FishingJoy\Assets\LuaText\" + filePath + ".lua";
        return Encoding.UTF8.GetBytes(File.ReadAllText(path));
    }

    private void OnDisable()
    {
        luaEnv.DoString("require 'Fishing_Dispose'");
    }

    private void OnDestroy()
    {
        luaEnv.Dispose();
    }
    
    public void LoadResources(string resName, string filePath)
    {
        //LoadAB(resName, filePath, resType);
        StartCoroutine(LoadAB1(resName, filePath));
    }
    
    IEnumerator LoadAB1(string reNAmae,string filePath)
    {
        UnityWebRequest request = UnityWebRequestAssetBundle.GetAssetBundle("http://localhost:8084/AssetBundles/" + filePath);
        yield return request.SendWebRequest();
        AssetBundle ab = (request.downloadHandler as DownloadHandlerAssetBundle).assetBundle;
        GameObject go = ab.LoadAsset<GameObject>(reNAmae);
        ObjDic.Add(reNAmae,go);

        ab.Unload(false);
    }

    // void LoadAB(string resName, string filePath,int resType)
    // {
    //     GameObject obj = ABDic[filePath].LoadAsset<GameObject>(resName);
    //     ObjDic.Add(resName, obj);
    // }

    public GameObject GetABObj(string resName)
    {
        return ObjDic[resName];
    }
}
