﻿using System;
using System.IO;
using UnityEditor;
using UnityEngine;

public class EditorContext
{
    //-------------------------------------------------------------------------
    public static EditorContext Instance { get; internal set; }
    public string PathAssets { get; private set; }// Unity3D的Assets目录
    public string PathDataSrc { get; private set; }// 源数据资源根目录（未打包的）
    public string PathStreamingAssets { get; private set; }// 源数据资源根目录（未打包的）
    public string PathSettings { get; private set; }// Settings目录
    public string PathSettingsUser { get; private set; }// SettingsUser目录
    public EditorConfig Config { get; private set; }

    //-------------------------------------------------------------------------
    public EditorContext()
    {
        Instance = this;

        // PathAssets
        {
            string p = Path.Combine(Environment.CurrentDirectory, "./Assets/");
            var di = new DirectoryInfo(p);
            PathAssets = di.FullName;
        }

        // PathDataSrc
        {
            string p = Path.Combine(Environment.CurrentDirectory, "./Assets/Resources.KingTexas/");
            var di = new DirectoryInfo(p);
            PathDataSrc = di.FullName;
        }

        // PathStreamingAssets
        {
            string p = Path.Combine(Environment.CurrentDirectory, "./Assets/StreamingAssets/");
            var di = new DirectoryInfo(p);
            PathStreamingAssets = di.FullName;
        }

        //// PathDataPublishTarget
        //{
        //    string p = Path.Combine(Environment.CurrentDirectory, "../Cragon.Casinos.ClientPublish/");
        //    var di = new DirectoryInfo(p);
        //    PathDataPublishTarget = di.FullName;
        //}

        // PathSettings
        {
            string p = Path.Combine(Environment.CurrentDirectory, "./Assets/Settings/");
            var di = new DirectoryInfo(p);
            PathSettings = di.FullName;
        }

        // PathSettingsUser
        {
            string p = Path.Combine(Environment.CurrentDirectory, "./Assets/SettingsUser/");
            var di = new DirectoryInfo(p);
            PathSettingsUser = di.FullName;
        }

        Config = new EditorConfig();
    }

    //-------------------------------------------------------------------------
    [MenuItem("CasinosPublish/ProjectConfig", false, 101)]
    static void MenuItemProjectConfig()
    {
        if (Instance == null)
        {
            new EditorContext();
        }

        EditorViewProjectConfig editor = ScriptableObject.CreateInstance<EditorViewProjectConfig>();
        editor.titleContent = new GUIContent("项目配置", "用于项目运行时信息");
        editor.minSize = new Vector2(1024, 768);
        editor.maxSize = new Vector2(1024, 768);
        editor.Show();
    }

    //-------------------------------------------------------------------------
    [MenuItem("CasinosPublish/DataPublish", false, 102)]
    static void MenuItemDataPublish()
    {
        if (Instance == null)
        {
            new EditorContext();
        }

        EditorViewDataPublish editor = ScriptableObject.CreateInstance<EditorViewDataPublish>();
        editor.titleContent = new GUIContent("资源版本发布", "用于发布资源版本到指定的发布目录");
        editor.minSize = new Vector2(1024, 768);
        editor.maxSize = new Vector2(1024, 768);
        editor.Show();
    }

    //-------------------------------------------------------------------------
    [MenuItem("CasinosPublish/批处理", false, 103)]
    static void MenuItemSyc()
    {
        if (Instance == null)
        {
            new EditorContext();
        }

        Debug.Log("执行批处理，镜像同步StreamingAssets/Android目录和PersistentData/Android");
        ExecuteProgram("_SyncStreamingAssets2PersistentData.bat", "");
    }

    //-------------------------------------------------------------------------
    static bool ExecuteProgram(string exe_filename, string args)
    {
        System.Diagnostics.ProcessStartInfo info = new System.Diagnostics.ProcessStartInfo();
        info.FileName = exe_filename;
        info.WorkingDirectory = Environment.CurrentDirectory;
        info.UseShellExecute = true;
        info.Arguments = args;
        info.CreateNoWindow = true;
        info.WindowStyle = System.Diagnostics.ProcessWindowStyle.Normal;

        System.Diagnostics.Process task = null;
        bool rt = true;
        try
        {
            task = System.Diagnostics.Process.Start(info);
            if (task != null)
            {
                //task.WaitForExit();
                //task.WaitForExit(100000);
                //task.StandardOutput.ReadToEnd();
            }
            else
            {
                return false;
            }
        }
        catch (Exception e)
        {
            Debug.LogError("执行批处理: " + e.ToString());
            return false;
        }
        finally
        {
            if (task != null && task.HasExited)
            {
                rt = (task.ExitCode == 0);
            }
        }
        return rt;
    }
}