using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.Networking;
using UnityEngine.UI;
using UnityEngine.SceneManagement;
using XLua;

[Hotfix]
public class StartGame : MonoBehaviour {

    private Button but;

    private void Awake()
    {
	    StartCoroutine(LoadLua());
    }

    // Use this for initialization
	void Start () {
        but = GetComponent<Button>();
        but.onClick.AddListener(StartGames);
        Cursor.lockState = CursorLockMode.None;
        Cursor.visible = true;
	}

    private void StartGames()
    {
        SceneManager.LoadScene(1);
    }

    IEnumerator LoadLua()
    {
	    UnityWebRequest request = UnityWebRequest.Get("http://localhost:8084/FishingLua.lua");
	    yield return request.SendWebRequest();
	    string str = request.downloadHandler.text;
	    File.WriteAllText(@"D:\learn\HotUpdate\FishingJoy\Assets\LuaText\FishingLua.lua",str);
	    
	    UnityWebRequest request1 = UnityWebRequest.Get("http://localhost:8084/Fishing_Dispose.lua");
	    yield return request1.SendWebRequest();
	    string str1 = request1.downloadHandler.text;
	    File.WriteAllText(@"D:\learn\HotUpdate\FishingJoy\Assets\LuaText\Fishing_Dispose.lua",str1);
    }

    // Update is called once per frame
	void Update () {
		
	}
}
