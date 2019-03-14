﻿// Copyright (c) Cragon. All rights reserved.

namespace Casinos
{
    using System;
    using System.Collections;
    using System.Collections.Generic;
    using System.Text;
    using UnityEngine;
    using UnityEngine.Networking;

    public class MbAsyncLoadAssets : MonoBehaviour
    {
        //---------------------------------------------------------------------
        Dictionary<string, AssetBundle> MapAssetBundle { get; set; } = new Dictionary<string, AssetBundle>();// 已加载的Ab
        HashSet<string> SetAssetBundleLoading { get; set; } = new HashSet<string>();// 正在加载中的Ab
        Dictionary<string, Texture2D> MapTexture2D { get; set; } = new Dictionary<string, Texture2D>();

        //---------------------------------------------------------------------
        public void SendUrl(string url, Action<string> cb)
        {
            StartCoroutine(_sendUrl(url, cb));
        }

        //---------------------------------------------------------------------
        public void PostUrl(string url, string post_data, Action<int, string> cb)
        {
            StartCoroutine(_postUrl(url, post_data, cb));
        }

        //---------------------------------------------------------------------
        public void PostUrlWithFormData(string url, WWWForm form_data, Action<int, string> cb)
        {
            StartCoroutine(_postUrlWithFormData(url, form_data, cb));
        }

        //---------------------------------------------------------------------
        public void LocalLoadAssetBundleAsync(string url, Action<AssetBundle> cb)
        {
            StartCoroutine(_localLoadAssetBundleAsync(url, cb));
        }

        //---------------------------------------------------------------------
        public void LocalLoadTextureFromAbAsync(string url, string name, Action<Texture> cb)
        {
            StartCoroutine(_localLoadTextureFromAbAsync(url, name, cb));
        }

        //---------------------------------------------------------------------
        public void WWWLoadTextAsync(string url, Action<string> cb)
        {
            StartCoroutine(_wwwLoadTextAsync(url, cb));
        }

        //---------------------------------------------------------------------
        public void WWWLoadTextListAsync(List<string> list_url, Action<List<string>> cb)
        {
            StartCoroutine(_wwwLoadTextListAsync(list_url, cb));
        }

        //---------------------------------------------------------------------
        public void WWWLoadTextureAsync(string url, Action<Texture> cb)
        {
            StartCoroutine(_wwwLoadTextureAsync(url, cb));
        }

        //---------------------------------------------------------------------
        public void WWWLoadAssetBundleAsync(string url, Action<AssetBundle> cb)
        {
            StartCoroutine(_wwwLoadAssetBundleAsync(url, cb));
        }

        //---------------------------------------------------------------------
        IEnumerator _localLoadAssetBundleAsync(string url, Action<AssetBundle> cb)
        {
            AssetBundle ab = null;

            using (UnityWebRequest www_request = UnityWebRequest.Get(url))
            {
                yield return www_request.SendWebRequest();

                if (www_request.isHttpError || www_request.isNetworkError)
                {
                    BuglyAgent.PrintLog(LogSeverity.LogError, www_request.error);
                }
                else
                {
                    if (www_request.responseCode == 200)
                    {
                        ab = DownloadHandlerAssetBundle.GetContent(www_request);
                    }
                }
            }

            if (cb != null) cb.Invoke(ab);
        }

        //---------------------------------------------------------------------
        IEnumerator _localLoadTextureFromAbAsync(string url, string name, Action<Texture> cb)
        {
            MapAssetBundle.TryGetValue(url, out AssetBundle ab);

            // 判定是否已加载Ab
            if (ab == null)
            {
                // 判定是否正在加载Ab
                bool b = SetAssetBundleLoading.Contains(url);

                if (b)
                {
                    while (true)
                    {
                        yield return 1;// 等1帧

                        if (!SetAssetBundleLoading.Contains(url))
                        {
                            ab = MapAssetBundle[url];
                            break;
                        }
                    }
                }
                else
                {
                    SetAssetBundleLoading.Add(url);

                    AssetBundleCreateRequest abcr = AssetBundle.LoadFromFileAsync(url);
                    yield return abcr;

                    ab = abcr.assetBundle;
                    MapAssetBundle[url] = ab;

                    SetAssetBundleLoading.Remove(url);
                }
            }

            string s = url + name;
            MapTexture2D.TryGetValue(s, out Texture2D t);
            if (t == null)
            {
                t = ab.LoadAsset<Texture2D>(name);
                MapTexture2D[s] = t;
            }

            if (cb != null) cb.Invoke(t);
        }

        //---------------------------------------------------------------------
        IEnumerator _wwwLoadTextListAsync(List<string> list_url, Action<List<string>> cb)
        {
            List<string> list_string = new List<string>();

            foreach (var i in list_url)
            {
                using (UnityWebRequest www_request = UnityWebRequest.Get(i))
                {
                    yield return www_request.SendWebRequest();

                    if (www_request.isHttpError || www_request.isNetworkError)
                    {
                        BuglyAgent.PrintLog(LogSeverity.LogError, www_request.error);
                    }
                    else
                    {
                        if (www_request.responseCode == 200)
                        {
                            list_string.Add(www_request.downloadHandler.text);
                        }
                    }
                }
            }

            if (cb != null) cb.Invoke(list_string);
        }

        //---------------------------------------------------------------------
        IEnumerator _wwwLoadTextAsync(string url, Action<string> cb)
        {
            string s = string.Empty;

            using (UnityWebRequest www_request = UnityWebRequest.Get(url))
            {
                yield return www_request.SendWebRequest();

                if (www_request.isHttpError || www_request.isNetworkError)
                {
                    BuglyAgent.PrintLog(LogSeverity.LogError, www_request.error);
                }
                else
                {
                    if (www_request.responseCode == 200)
                    {
                        s = www_request.downloadHandler.text;
                    }
                }
            }

            if (cb != null) cb.Invoke(s);
        }

        //---------------------------------------------------------------------
        IEnumerator _wwwLoadTextureAsync(string url, Action<Texture> cb)
        {
            Texture texture = null;

            using (UnityWebRequest www_request = UnityWebRequest.Get(url))
            {
                www_request.downloadHandler = new DownloadHandlerTexture();
                yield return www_request.SendWebRequest();

                if (www_request.isHttpError || www_request.isNetworkError)
                {
                    BuglyAgent.PrintLog(LogSeverity.LogError, www_request.error);
                }
                else
                {
                    if (www_request.responseCode == 200)
                    {
                        texture = ((DownloadHandlerTexture)www_request.downloadHandler).texture;
                    }
                }
            }

            if (cb != null) cb.Invoke(texture);
        }

        //---------------------------------------------------------------------
        IEnumerator _wwwLoadAssetBundleAsync(string url, Action<AssetBundle> cb)
        {
            AssetBundle ab = null;

            using (UnityWebRequest www_request = UnityWebRequest.Get(url))
            {
                yield return www_request.SendWebRequest();

                if (www_request.isHttpError || www_request.isNetworkError)
                {
                    BuglyAgent.PrintLog(LogSeverity.LogError, www_request.error);
                }
                else
                {
                    if (www_request.responseCode == 200)
                    {
                        ab = DownloadHandlerAssetBundle.GetContent(www_request);
                    }
                }
            }

            if (cb != null) cb.Invoke(ab);
        }

        //---------------------------------------------------------------------
        IEnumerator _sendUrl(string url, Action<string> cb)
        {
            using (UnityWebRequest www_request = UnityWebRequest.Get(url))
            {
                yield return www_request.SendWebRequest();
                if (www_request.error != null)
                {
                    BuglyAgent.PrintLog(LogSeverity.LogError, www_request.error);
                }
                else
                {
                    if (www_request.responseCode == 200)
                    {
                        if (cb != null) cb.Invoke(www_request.downloadHandler.text);
                    }
                }
            }
        }

        //---------------------------------------------------------------------
        IEnumerator _postUrl(string url, string post_data, Action<int, string> cb)
        {
            using (UnityWebRequest www_request = new UnityWebRequest(url, "POST"))
            {
                byte[] post_bytes = System.Text.Encoding.UTF8.GetBytes(post_data);
                www_request.uploadHandler = new UploadHandlerRaw(post_bytes);
                www_request.downloadHandler = new DownloadHandlerBuffer();
                www_request.SetRequestHeader("Content-Type", "application/json");

                yield return www_request.SendWebRequest();

                int http_statuscode = (int)www_request.responseCode;
                if (www_request.isNetworkError)
                {
                    BuglyAgent.PrintLog(LogSeverity.LogError, www_request.error);
                }

                if (cb != null) cb.Invoke(http_statuscode, www_request.downloadHandler.text);
            }
        }

        //---------------------------------------------------------------------
        IEnumerator _postUrlWithFormData(string url, WWWForm form_data, Action<int, string> cb)
        {
            using (UnityWebRequest www_request = UnityWebRequest.Post(url, form_data))
            {
                www_request.downloadHandler = new DownloadHandlerBuffer();
                yield return www_request.SendWebRequest();

                int http_statuscode = (int)www_request.responseCode;
                if (www_request.isNetworkError)
                {
                    BuglyAgent.PrintLog(LogSeverity.LogError, www_request.error);
                }

                if (cb != null) cb.Invoke(http_statuscode, www_request.downloadHandler.text);
            }
        }
    }
}