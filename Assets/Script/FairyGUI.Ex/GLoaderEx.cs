﻿// Copyright (c) Cragon. All rights reserved.

namespace Casinos
{
    using System;
    using UnityEngine;
    using FairyGUI;

    public class GLoaderEx : GLoader
    {
        //---------------------------------------------------------------------
        internal static string HttpPrefix = "http://";
        internal static string HttpsPrefix = "https://";
        internal static string ABPostfix = ".ab";

        public Action<bool> LoaderDoneCallBack { get; set; }
        LoaderTicket LoaderTicket { get; set; }

        //---------------------------------------------------------------------
        public GLoaderEx()
        {
        }

        //---------------------------------------------------------------------
        protected override void LoadExternal()
        {
            Texture2D tex = null;
            string url = this.url.Replace('\\', '/');
            int index = url.LastIndexOf('/');
            string resource_name = url.Substring(index + 1);
            if (this.url.StartsWith(HttpPrefix) || this.url.StartsWith(HttpsPrefix))
            {
                var loader_ticket = HeadIconMgr.Instant.asyncLoadIcon(resource_name, this.url,
                    resource_name, null, _wwwCallBack);
                if (loader_ticket != null)
                {
                    LoaderTicket = loader_ticket;
                }
            }
            else
            {
                if (this.url.EndsWith(ABPostfix))
                {
                    var loader_ticket = TextureMgr.Instant.getTexture(resource_name.Replace(ABPostfix, ""), this.url, _loadTextureCallBackEx);
                    if (loader_ticket != null)
                    {
                        LoaderTicket = loader_ticket;
                    }
                }
                else
                {
                    tex = Resources.Load<Texture2D>(this.url);
                    _loadTextureCallBack(tex);
                }
            }
        }

        //---------------------------------------------------------------------
        void _loadTextureCallBackEx(LoaderTicket tick, Texture t)
        {
            if (LoaderTicket != tick)
            {
                return;
            }

            LoaderTicket = null;
            _loadTextureCallBack(t);
        }

        //---------------------------------------------------------------------
        void _loadTextureCallBack(Texture t)
        {
            if (this.displayObject.gameObject == null)
            {
                return;
            }

            bool load_success = false;
            if (t != null)
            {
                load_success = true;
                onExternalLoadSuccess(new NTexture(t));
            }
            else
            {
                onExternalLoadFailed();
            }

            if (LoaderDoneCallBack != null)
            {
                LoaderDoneCallBack(load_success);
            }
        }

        //---------------------------------------------------------------------
        void _wwwCallBack(UnityEngine.Object obj, LoaderTicket tick)
        {
            if (this.displayObject.gameObject == null)
            {
                return;
            }

            if (LoaderTicket != tick)
            {
                return;
            }

            LoaderTicket = null;
            bool load_success = false;
            Texture2D t = (Texture2D)obj;
            if (t != null)
            {
                var p = t.GetPixels();
                var p1 = new Texture2D(t.width, t.height, TextureFormat.ARGB32, false);
                p1.SetPixels(p);
                p1.Apply();
                load_success = true;
                onExternalLoadSuccess(new NTexture(p1));
            }
            else
            {
                onExternalLoadFailed();
            }

            if (LoaderDoneCallBack != null)
            {
                LoaderDoneCallBack(load_success);
            }
        }
    }
}